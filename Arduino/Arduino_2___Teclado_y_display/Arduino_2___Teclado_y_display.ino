// =================================================================================
// ARDUINO 2: INTERFAZ DE USUARIO (TECLADO Y PANTALLA)
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. LIBRERÍAS Y COMUNICACIÓN
// ---------------------------------------------------------------------------------
#include <Keypad.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>

// Comunicación serie con el otro Arduino (Arduino 1 - Motores/RFID)
// Pines: A0 (RX), A1 (TX)
SoftwareSerial mySerial(A0, A1); 

// Pantalla LCD I2C (Dirección 0x27, 16 columnas, 2 filas)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ---------------------------------------------------------------------------------
// 2. CONFIGURACIÓN DEL TECLADO MATRICIAL
// ---------------------------------------------------------------------------------
const byte FILAS = 4;
const byte COLUMNAS = 4;

// Mapa de caracteres del teclado
char teclas[FILAS][COLUMNAS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};

// Pines de conexión del teclado
byte pinesFilas[FILAS] = {9, 8, 7, 6};
byte pinesColumnas[COLUMNAS] = {5, 4, 3, 2};

// Inicialización del objeto Keypad
Keypad teclado = Keypad(makeKeymap(teclas), pinesFilas, pinesColumnas, FILAS, COLUMNAS);

// ---------------------------------------------------------------------------------
// 3. VARIABLES GLOBALES Y LÓGICA
// ---------------------------------------------------------------------------------

// Base de datos de códigos válidos (Productos/Selecciones)
const int N_CODIGOS = 3;
String codigos[N_CODIGOS] = {"1234", "2580", "9876"};

// Variables de control de entrada
String entrada = "";          // Almacena lo que el usuario está escribiendo
String mensaje = "";          // Almacena mensajes recibidos del otro Arduino
const int MAX_LEN = 6;        // Longitud máxima permitida

// Variables de tiempo (Timers)
unsigned long ultimaActividad = 0;
const unsigned long TIMEOUT_MS = 10000UL; // 10 segundos de espera antes de reiniciar

// =================================================================================
// 4. SETUP (CONFIGURACIÓN INICIAL)
// =================================================================================
void setup() {
  // Inicialización de comunicación
  Serial.begin(9600);   // Puerto Hardware (Para depuración con PC si fuera necesario)
  mySerial.begin(9600); // Puerto Software (Comunicación con Arduino 1)

  // Inicialización de pantalla LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistema listo");
  lcd.setCursor(0, 1);
  lcd.print("Ingrese codigo");
  
  delay(3000);
  lcd.clear(); // Limpia mensaje de bienvenida

  // Configuración de sensibilidad del teclado
  teclado.setDebounceTime(50); // Evita rebotes mecánicos
  teclado.setHoldTime(1000);
}

// =================================================================================
// 5. LOOP (BUCLE PRINCIPAL - MÁQUINA DE ESTADOS)
// =================================================================================
void loop() {
  
  // --- A. GESTIÓN DE TIEMPO (TIMEOUT) ---
  // Si el usuario deja de escribir por 10 segundos, se reinicia la pantalla.
  if (entrada.length() > 0 && (millis() - ultimaActividad) > TIMEOUT_MS) {
    lcd.clear();
    lcd.print("Tiempo terminado");
    
    // Resetear variables y volver al inicio
    entrada = "";
    delay(1000);
    lcd.clear();
    lcd.print("Ingrese codigo");
  }

  // --- B. LECTURA DEL TECLADO ---
  char k = teclado.getKey();

  if (k) {
    ultimaActividad = millis(); // Actualizamos el tiempo de actividad

    // CASO 1: CONFIRMAR (Tecla '#')
    if (k == '#') {
      verificarCodigo(); // Llama a la función de validación
    } 
    // CASO 2: BORRAR / CANCELAR (Tecla '*')
    else if (k == '*') {
      entrada = "";
      lcd.clear();
      lcd.print("Codigo borrado");
      delay(1000);
      lcd.clear();
      lcd.print("Ingrese codigo");
    } 
    // CASO 3: ESCRIBIR NÚMEROS/LETRAS
    else if ((k >= '0' && k <= '9') || (k >= 'A' && k <= 'D')) {
      if (entrada.length() < MAX_LEN) {
        entrada += k;
        // Mostrar visualmente lo que se escribe en la segunda fila
        lcd.setCursor(0, 1);
        lcd.print(entrada);
      }
    }
  }
}

// =================================================================================
// 6. FUNCIONES AUXILIARES
// =================================================================================

// Función que verifica si el código ingresado existe en la lista 'codigos'
void verificarCodigo() {      
  lcd.clear();
  lcd.print("Verificando...");
  delay(500);

  if (entrada.length() == 0) return; // Si no escribió nada, sale.

  bool encontrado = false;
  int codigoID = -1;

  // 1. Buscar en el array de códigos
  for (int i = 0; i < N_CODIGOS; ++i) {
    if (entrada == codigos[i]) {
      encontrado = true;
      codigoID = i; // Guardamos el índice (0, 1 o 2)
      break;
    }
  }

  lcd.clear();

  // 2. Acciones según resultado
  if (encontrado) {
    lcd.print("Codigo Correcto");
    
    // Limpiar buffer serial antes de enviar
    while (mySerial.available()) mySerial.read();

    // ENVIAR SELECCIÓN AL ARDUINO 1 (Motores)
    mySerial.write(codigoID);

    // --- ESTADO: ESPERA DE TARJETA RFID ---
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Aproxime tarjeta");
    lcd.setCursor(0, 1);
    lcd.print("o llavero");

    unsigned long inicio = millis();
    mensaje = "";
    
    // Esperar respuesta del Arduino 1 durante 10 segundos
    while (millis() - inicio < 10000) {
      if (mySerial.available()) {
        mensaje = mySerial.readStringUntil('\n');
        
        // Interpretar respuesta del Arduino 1
        if (mensaje.startsWith("Pago") || mensaje.startsWith("Saldo")|| mensaje.startsWith("No")|| mensaje.startsWith("sin")) {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(mensaje); // Muestra el error o éxito
          delay(2000);
          break; // Salir del while
        }
      }
    }

  } else {
    // Código no encontrado
    lcd.print("Codigo Incorrecto");
    delay(1500);
  }

  // 3. Volver al estado inicial
  lcd.clear();
  lcd.print("Ingrese codigo");
  entrada = "";
}