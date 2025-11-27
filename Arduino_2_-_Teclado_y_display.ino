//ARDUINO 2
//LIBRERIAS
#include <Keypad.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>

const byte FILAS = 4;
const byte COLUMNAS = 4;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Comunicación serie por A0 y A1
SoftwareSerial mySerial(A0, A1); 

String mensaje = ""; //Almacena mensaje recibido

// Mapa del teclado
char teclas[FILAS][COLUMNAS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte pinesFilas[FILAS] = {9, 8, 7, 6};
byte pinesColumnas[COLUMNAS] = {5, 4, 3, 2};

// -------------------------------
// El Keypad actúa como "generador de eventos".
// -------------------------------
Keypad teclado = Keypad(makeKeymap(teclas), pinesFilas, pinesColumnas, FILAS, COLUMNAS);

const int MAX_LEN = 6;
const unsigned long TIMEOUT_MS = 10000UL;   // Esto funciona como transición automática por timeout

String entrada = "";
unsigned long ultimaActividad = 0;

const int N_CODIGOS = 3;
String codigos[N_CODIGOS] = {"1234", "2580", "9876"};

void setup() {
  //Inicializacion de pantalla lcd
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistema listo");
  lcd.setCursor(0, 1);
  lcd.print("Ingrese codigo");
  delay(3000);
  lcd.clear();
  //Inicio de comunicacion serie
  Serial.begin(9600);  //Processing
  mySerial.begin(9600); //Arduino

  teclado.setDebounceTime(50);
  teclado.setHoldTime(1000);
}

void loop() {

  // LISTA ESTADOS:
  // 1) ESPERA_INPUT
  // 2) MOSTRAR_ENTRADA
  // 3) VALIDAR_CODIGO
  // 4) ESPERA_RFID
  // 5) MOSTRAR_MENSAJE
  
  // Cada acción depende de eventos:
  // - Tecla presionada
  // - Timeout
  // - Recepción de mensaje por serial


  // ESTADO: TIMEOUT => transición automática por inactividad
  if (entrada.length() > 0 && (millis() - ultimaActividad) > TIMEOUT_MS) {
    lcd.clear();
    lcd.print("Tiempo terminado");

    // Transición al estado inicial
    entrada = "";
    delay(1000);
    lcd.clear();
    lcd.print("Ingrese codigo");
  }

  // EVENTO: tecla presionada
  char k = teclado.getKey();

  if (k) {
    ultimaActividad = millis();

    // EVENTO: tecla '#' = transiciona al estado VALIDAR_CODIGO
    if (k == '#') {
      verificarCodigo();
    } 
    // EVENTO: tecla '*' = reinicia FSM al estado ESPERA_INPUT
    else if (k == '*') {
      entrada = "";
      lcd.clear();
      lcd.print("Codigo borrado");
      delay(1000);
      lcd.clear();
      lcd.print("Ingrese codigo");
    } 
    else 
    // EVENTO: dígito válido = transiciona al estado MOSTRAR_ENTRADA
    if ((k >= '0' && k <= '9') || (k >= 'A' && k <= 'D')) {
      if (entrada.length() < MAX_LEN) {
        entrada += k;
        lcd.setCursor(0, 1);
        lcd.print(entrada);
      }
    }
  }
}
 //La funcion "verificarCodigo", verifica si el codigo recibido es el correcto o no para trabajar con la pantalla
void verificarCodigo() {      
  // ESTADO VALIDAR CODIGO
  lcd.clear();
  lcd.print("Verificando...");
  delay(500);

  if (entrada.length() == 0) return;

  bool encontrado = false;
  int codigoID = -1;

  // Búsqueda del código => determina una transición:
  // (CÓDIGO_CORRECTO) vs (CÓDIGO_INCORRECTO)
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

    // Transición al estado "ENVIO_CODIGO"
    while (mySerial.available()) mySerial.read();

    mySerial.write(codigoID);

    // Pasamos a un nuevo estado:
    // ESTADO: ESPERA_RFID => el otro Arduino nos responderá
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Aproxime tarjeta");
    lcd.setCursor(0, 1);
    lcd.print("o llavero");

    unsigned long inicio = millis();
    mensaje = "";
   
    // ESTADO: ESPERA_RFID con timeout de 10s
    while (millis() - inicio < 10000) {

      // EVENTO: mensaje recibido => decide transición
      if (mySerial.available()) {
        mensaje = mySerial.readStringUntil('\n');

        // Si el mensaje inicia con estas palabras, se considera
        // un EVENTO válido que dispara una transición a MOSTRAR_MENSAJE.
        if (mensaje.startsWith("Pago") || mensaje.startsWith("Saldo")|| mensaje.startsWith("No")|| mensaje.startsWith("sin")) {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(mensaje);
          delay(2000);
          break;
        }
      }
    }

  } else {
    // ESTADO ERROR_CODIGO
    lcd.print("Codigo Incorrecto");
    delay(1500);
  }

  // Transición final => vuelve al estado ESPERA_INPUT
  lcd.clear();
  lcd.print("Ingrese codigo");
  entrada = "";
}
