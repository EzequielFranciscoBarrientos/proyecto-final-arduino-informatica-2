//ARDUINO 1
//LIBRERIAS
#include <SPI.h>  
#include <MFRC522.h>
#include <SoftwareSerial.h>
#include "lib_expendedora.h"   

#define RST_PIN  9
#define SS_PIN  10

MFRC522 mfrc522(SS_PIN, RST_PIN);  //Se declara objeto de la clase MFRC522
SoftwareSerial mySerial(A0, A1);


LibExpendedora manager;


byte UID[4];
int nroventa = 1000;
int producto;
String mensaje = "";

int op = -1;
int enablePin = 7;
int in1 = 6;
int in2 = 5;
int enablePin1 = 2;
int in3 = 4;
int in4 = 3;

void setup() {
  //Pines motores
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(enablePin1, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

//Inicio de comunicacion serie
  Serial.begin(9600);  //Processing
  mySerial.begin(9600); //Arduino

  SPI.begin();
  mfrc522.PCD_Init();
}


void checkSerialFromPC() {
  if (Serial.available()) {

    // EVENTO: llegada de un mensaje
    String mensajePC = Serial.readStringUntil('\n'); 
    mensajePC.trim();
    if (mensajePC.length() == 0) return;

    // Cada condición de abajo desencadenada por un tipo de evento.
    
    if (mensajePC.startsWith("STOCK1:")) {
      int cantidad = mensajePC.substring(7).toInt();
      manager.agregarStock(1, cantidad); 
    }
    else if (mensajePC.startsWith("STOCK2:")) {
      int cantidad = mensajePC.substring(7).toInt();
      manager.agregarStock(2, cantidad); 
    }

    else if (mensajePC.startsWith("UID:")) {
      // EVENTO: registro de usuario =>  actualiza estado interno
      String uidHex = mensajePC.substring(4);
      uidHex.trim();
      manager.agregarUsuario(uidHex);
    }

    else if (mensajePC.startsWith("DELUID:")) {
      // EVENTO: eliminar usuario =>  cambia el conjunto de estados válidos
      String uidHex = mensajePC.substring(7);
      uidHex.trim();
      manager.eliminarUsuario(uidHex);
    }

    else if (mensajePC.startsWith("ADDSALDO:")) {
      String datos = mensajePC.substring(9);
      int separador = datos.indexOf(':');
      if (separador != -1) {
        String uidHex = datos.substring(0, separador);
        long monto = datos.substring(separador + 1).toInt();
        manager.agregarSaldo(uidHex, monto);
      }
    }
  }
}

void loop() {
  // ------------------------------------------
  // Estados del void loop
  // 1) ESPERA_EVENTOS_PC
  // 2) ESPERA_PRODUCTO
  // 3) ESPERA_TARJETA
  // 4) PROCESAR_COMPRA
  // 5) EJECUTAR_ACCION
  // ------------------------------------------

  // ESTADO: ESPERA_EVENTOS_PC
  checkSerialFromPC();

  // ESTADO: ESPERA_PRODUCTO
  if (!mySerial.available()) {
    return; 
  }

  // ESTADO: ESPERA_TARJETA
  if (!mfrc522.PICC_IsNewCardPresent()) return;
  if (!mfrc522.PICC_ReadCardSerial()) return;

  // Si llega acá, el sistema recibe EVENTO_PRODUCTO + EVENTO_TARJETA
  // y cambia al estado PROCESAR_COMPRA
  
  op = mySerial.read();

  
  if(op == 0){
     producto = 2000;
     if(manager.getStock(1) == 0){ 
      mySerial.println("sin stock");
      mfrc522.PICC_HaltA(); //finalizar comunicacion, el lector deja de emitir radiofrecuencia
      return;   
      // Cambio al estado: ERROR_STOCK
     }
  }
  else {
    producto = 1000;
    if(manager.getStock(2) == 0){
      mySerial.println("sin stock");
      mfrc522.PICC_HaltA();
      return;   
      // Cambio al estado: ERROR_STOCK
    }
  }
  
  printUID();

  // EVENTO interno: verificar compra.
  // El resultado es un cambio a uno de estos estados:
  // COMPRA_OK, ERROR_SALDO_INSUFICIENTE o ERROR_USUARIO_NO_ENCONTRADO
  int estadoCompra = manager.verificarCompra(UID, producto);

  // ESTADO: PROCESAR_COMPRA
  switch (estadoCompra) {

    case COMPRA_OK:
      // TRANSICIÓN al estado: REALIZAR_PAGO
      manager.realizarPago(UID, producto);
      mySerial.println("Pago realizado");
      nroventa++;
      Serial.println("Exitoso");
      Serial.println(nroventa);

      // TRANSICIÓN al estado: EJECUTAR_ACCION
      ejecutarAccion(op);
      Serial.println("Registro:" + String(op) + ":" + String(producto));
      break;

    case ERROR_SALDO_INSUFICIENTE:
      // Estado: ERROR_SALDO
      mySerial.println("Saldo insuficiente");
      Serial.println("No exitoso");
      break;

    case ERROR_USUARIO_NO_ENCONTRADO:
      // Estado: ERROR_USUARIO
      mySerial.println("No registrado");
      Serial.println("No exitoso");
      break;
  }
  
  // EVENTO: fin de lectura de tarjeta =>  vuelve al estado inicial
  mfrc522.PICC_HaltA();
}
//Funcion que selecciona y activa cada motor
void ejecutarAccion(int idCodigo) {
  
  // estado = tipoDeProducto =>  acción de motor
  switch (idCodigo) {
    case 0:
      Serial.println("Producto 1");
      Serial.println(producto);
      manager.reducirStock(1);

      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(enablePin, HIGH);
      delay(1000);
      digitalWrite(enablePin, LOW);
      break;

    case 1:
      Serial.println("Producto 2");
      Serial.println(producto);
         manager.reducirStock(1);

      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
      digitalWrite(enablePin1, HIGH);
      delay(1000);
      digitalWrite(enablePin1, LOW);
      break;
  }
}
//Funcion que almacena la UID leida y la almacena en un arreglo
void printUID() {
  Serial.print("UID leido: ");

  // Copia del UID => parte de la
  // lógica que alimenta la máquina de estados
  // para identificar el "estado del usuario".
  for (byte i = 0; i < 4; i++) {
    UID[i] = mfrc522.uid.uidByte[i];

    if (UID[i] < 0x10) Serial.print(" 0");
    else Serial.print(" ");

    Serial.print(UID[i], HEX);
  }
  Serial.println();

  for (byte i = 0; i < 4; i++) {
    if (UID[i] < 0x10) Serial.print("0");
    Serial.print(UID[i], HEX);
  }
  Serial.println();
}
