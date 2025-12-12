// =================================================================================
// ARDUINO 1: CONTROL DE HARDWARE (MOTORES, RFID) Y LÓGICA DE NEGOCIO
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. LIBRERÍAS Y OBJETOS
// ---------------------------------------------------------------------------------
#include <SPI.h>              // Protocolo SPI para el lector RFID
#include <MFRC522.h>          // Librería para el lector RFID RC522
#include <SoftwareSerial.h>   // Comunicación serie por software
#include "lib_expendedora.h"  // LIBRERÍA PROPIA (Gestión de usuarios y stock)

// Definición de pines para RFID
#define RST_PIN  9
#define SS_PIN  10

// Instancia del lector RFID
MFRC522 mfrc522(SS_PIN, RST_PIN);

// Comunicación con Arduino 2 (Teclado/Pantalla)
SoftwareSerial mySerial(A0, A1); 

// Gestor de la lógica de negocio (Base de datos en RAM)
LibExpendedora manager;

// ---------------------------------------------------------------------------------
// 2. PINES DE MOTORES (PUENTE H)
// ---------------------------------------------------------------------------------
// Motor 1 (Producto 1)
int enablePin = 7;
int in1 = 6;
int in2 = 5;

// Motor 2 (Producto 2)
int enablePin1 = 2;
int in3 = 4;
int in4 = 3;

// ---------------------------------------------------------------------------------
// 3. VARIABLES GLOBALES
// ---------------------------------------------------------------------------------
byte UID[4];             // Almacena la tarjeta leída actualmente
int nroventa = 1000;     // Contador de ventas (ID de transacción)
int producto;            // Precio del producto seleccionado temporalmente
String mensaje = "";     // Buffer de mensajes
int op = -1;             // Opción recibida del Arduino 2

// =================================================================================
// 4. SETUP (CONFIGURACIÓN INICIAL)
// =================================================================================
void setup() {
  // Configuración de pines de Motores como SALIDA
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(enablePin1, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  // Inicialización de comunicaciones
  Serial.begin(9600);   // Comunicación con PC (Processing)
  mySerial.begin(9600); // Comunicación con Arduino 2

  // Inicialización del Hardware RFID
  SPI.begin();
  mfrc522.PCD_Init();
}

// =================================================================================
// 5. LOOP (BUCLE PRINCIPAL)
// =================================================================================
void loop() {
  
  // PASO 1: ESCUCHAR COMANDOS DE LA PC (Processing)
  // Aquí se carga stock, cambian precios o registran usuarios.
  checkSerialFromPC();

  // PASO 2: ESCUCHAR SELECCIÓN DEL ARDUINO 2 (Teclado)
  // Si no hay datos en mySerial, el bucle vuelve a empezar.
  if (!mySerial.available()) {
    return; 
  }

  // PASO 3: DETECTAR TARJETA RFID
  // Si hay una selección de producto, esperamos una tarjeta.
  if (!mfrc522.PICC_IsNewCardPresent()) return;
  if (!mfrc522.PICC_ReadCardSerial()) return;

  // --- LÓGICA DE PROCESAMIENTO DE VENTA ---
  
  // 1. Leer qué producto seleccionó el usuario en el teclado
  op = mySerial.read();
  
  // 2. Verificar Stock y obtener Precio según la opción
  if(op == 0){ // Producto 1
     producto = manager.getPrecio(1);
     if(manager.getStock(1) == 0){ 
        mySerial.println("sin stock"); // Avisar a Arduino 2
        mfrc522.PICC_HaltA();          // Detener lectura RFID
        return;
     }
  }
  else {       // Producto 2 (asumiendo op != 0 es prod 2)
    producto = manager.getPrecio(2);
    if(manager.getStock(2) == 0){
      mySerial.println("sin stock");
      mfrc522.PICC_HaltA();
      return;
    }
  }
  
  // Imprimir UID para depuración
  printUID();

  // 3. VERIFICAR SALDO Y USUARIO
  // La librería comprueba si la tarjeta existe y tiene dinero
  int estadoCompra = manager.verificarCompra(UID, producto);

  // 4. EJECUTAR RESULTADO
  switch (estadoCompra) {

    case COMPRA_OK:
      // A) Cobrar
      manager.realizarPago(UID, producto);
      
      // B) Notificar éxito
      mySerial.println("Pago realizado"); // A Arduino 2 (LCD)
      nroventa++;
      Serial.println("Exitoso");          // A PC (Log)
      Serial.println(nroventa);
      
      // C) Mover Motor
      ejecutarAccion(op);
      
      // D) Registrar venta para Processing
      Serial.println("Registro:" + String(op) + ":" + String(producto));
      break;

    case ERROR_SALDO_INSUFICIENTE:
      mySerial.println("Saldo insuficiente");
      Serial.println("No exitoso");
      break;

    case ERROR_USUARIO_NO_ENCONTRADO:
      mySerial.println("No registrado");
      Serial.println("No exitoso");
      break;
  }
  
  // Detener comunicación con la tarjeta actual
  mfrc522.PICC_HaltA();
}

// =================================================================================
// 6. FUNCIONES AUXILIARES
// =================================================================================

// --- COMUNICACIÓN CON PROCESSING ---
void checkSerialFromPC() {
  if (Serial.available()) {
    String mensajePC = Serial.readStringUntil('\n');
    mensajePC.trim();
    if (mensajePC.length() == 0) return;

    // A. Actualizar Stock
    if (mensajePC.startsWith("STOCK1:")) {
      int cantidad = mensajePC.substring(7).toInt();
      manager.agregarStock(1, cantidad);
    }
    else if (mensajePC.startsWith("STOCK2:")) {
      int cantidad = mensajePC.substring(7).toInt();
      manager.agregarStock(2, cantidad);
    }
    // B. Gestión de Usuarios (Alta/Baja)
    else if (mensajePC.startsWith("UID:")) {
      String uidHex = mensajePC.substring(4);
      uidHex.trim();
      manager.agregarUsuario(uidHex);
    }
    else if (mensajePC.startsWith("DELUID:")) {
      String uidHex = mensajePC.substring(7);
      uidHex.trim();
      manager.eliminarUsuario(uidHex);
    }
    // C. Cargar Saldo
    else if (mensajePC.startsWith("ADDSALDO:")) {
      String datos = mensajePC.substring(9);
      int separador = datos.indexOf(':');
      if (separador != -1) {
        String uidHex = datos.substring(0, separador);
        long monto = datos.substring(separador + 1).toInt();
        manager.agregarSaldo(uidHex, monto);
      }
    }
    // D. Cambiar Precios
    else if (mensajePC.startsWith("CAMBIAR_PRECIO:")) {
      String datos = mensajePC.substring(15);
      int separador = datos.indexOf(':');
      if (separador != -1) {
          int idProd = datos.substring(0, separador).toInt();
          int precioNuevo = datos.substring(separador + 1).toInt();
          manager.setPrecio(idProd, precioNuevo);
        }
    }
  }
}

// --- CONTROL DE MOTORES ---
void ejecutarAccion(int idCodigo) {
  switch (idCodigo) {
    case 0: // Producto 1
      Serial.println("Producto 1");
      Serial.println(producto);
      manager.reducirStock(1); // Descontar stock lógico

      // Activar Motor 1
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(enablePin, HIGH);
      delay(1000);
      digitalWrite(enablePin, LOW);
      break;

    case 1: // Producto 2
      Serial.println("Producto 2");
      Serial.println(producto);
      manager.reducirStock(1);

      // Activar Motor 2
      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
      digitalWrite(enablePin1, HIGH);
      delay(1000);
      digitalWrite(enablePin1, LOW);
      break;
  }
}

// --- DEBUG RFID ---
void printUID() {
  Serial.print("UID leido: ");
  // Copiar UID al array global
  for (byte i = 0; i < 4; i++) {
    UID[i] = mfrc522.uid.uidByte[i];
    if (UID[i] < 0x10) Serial.print(" 0");
    else Serial.print(" ");
    Serial.print(UID[i], HEX);
  }
  Serial.println();
  
  // Imprimir formato compacto
  for (byte i = 0; i < 4; i++) {
    if (UID[i] < 0x10) Serial.print("0");
    Serial.print(UID[i], HEX);
  }
  Serial.println();
}