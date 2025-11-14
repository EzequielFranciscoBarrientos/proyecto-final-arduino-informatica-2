#include <Keypad.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>

const byte FILAS = 4;
const byte COLUMNAS = 4;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Comunicación serie por A0 y A1
SoftwareSerial mySerial(A0, A1); // RX, TX

String mensaje = "";

char teclas[FILAS][COLUMNAS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte pinesFilas[FILAS] = {9, 8, 7, 6};
byte pinesColumnas[COLUMNAS] = {5, 4, 3, 2};

Keypad teclado = Keypad(makeKeymap(teclas), pinesFilas, pinesColumnas, FILAS, COLUMNAS);

const int MAX_LEN = 6;
const unsigned long TIMEOUT_MS = 10000UL;

String entrada = "";
unsigned long ultimaActividad = 0;

const int N_CODIGOS = 3;
String codigos[N_CODIGOS] = {"1234", "2580", "9876"};

void setup() {
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistema listo");
  lcd.setCursor(0, 1);
  lcd.print("Ingrese codigo");
  delay(3000);
  lcd.clear();

  Serial.begin(9600);   // Para depuración opcional
  mySerial.begin(9600); // Comunicación entre Arduinos

  teclado.setDebounceTime(50);
  teclado.setHoldTime(1000);
}

void loop() {
  if (entrada.length() > 0 && (millis() - ultimaActividad) > TIMEOUT_MS) {
    lcd.clear();
    lcd.print("Tiempo terminado");
    entrada = "";
    delay(1000);
    lcd.clear();
    lcd.print("Ingrese codigo");
  }

  char k = teclado.getKey();

  if (k) {
    ultimaActividad = millis();

    if (k == '#') {
      verificarCodigo();
    } 
    else if (k == '*') {
      entrada = "";
      lcd.clear();
      lcd.print("Codigo borrado");
      delay(1000);
      lcd.clear();
      lcd.print("Ingrese codigo");
    } 
    else if ((k >= '0' && k <= '9') || (k >= 'A' && k <= 'D')) {
      if (entrada.length() < MAX_LEN) {
        entrada += k;
        lcd.setCursor(0, 1);
        lcd.print(entrada);
      }
    }
  }
}

void verificarCodigo() {
  lcd.clear();
  lcd.print("Verificando...");
  delay(500);

  if (entrada.length() == 0) return;

  bool encontrado = false;
  int codigoID = -1;

  for (int i = 0; i < N_CODIGOS; ++i) {
    if (entrada == codigos[i]) {
      encontrado = true;
      codigoID = i;
      break;
    }
  }

  lcd.clear();

  if (encontrado) {
    lcd.print("Codigo Correcto");

    // Limpieza de buffer
    while (mySerial.available()) mySerial.read();

    // Envía el código al otro Arduino
    mySerial.write(codigoID);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Aproxime tarjeta");
    lcd.setCursor(0, 1);
    lcd.print("o llavero");

    // Espera respuesta hasta 10 segundos
    unsigned long inicio = millis();
    mensaje = "";
   
    while (millis() - inicio < 10000) {
      if (mySerial.available()) {
        mensaje = mySerial.readStringUntil('\n');
        if (mensaje.startsWith("Pago") || mensaje.startsWith("Saldo")|| mensaje.startsWith("No")) {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(mensaje);
          delay(2000);
          break;
        }
      }
    }

  } else {
    lcd.print("Codigo Incorrecto");
    delay(1500);
  }

  lcd.clear();
  lcd.print("Ingrese codigo");
  entrada = "";
}
