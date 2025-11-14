//ARDUINO 1
#include <SPI.h>
#include <MFRC522.h>
#include <SoftwareSerial.h>
// CAMBIO: Incluimos la nueva librería
#include "lib_expendedora.h" 

#define RST_PIN  9
#define SS_PIN  10

MFRC522 mfrc522(SS_PIN, RST_PIN);
SoftwareSerial mySerial(A0, A1);
// RX, TX

// NUEVO: Creamos una instancia global de nuestra librería
LibExpendedora manager;



// Todas las variables de usuario, saldo y stock
// ahora están dentro del objeto 'manager'.

// Variables de la transacción actual
byte UID[4]; // Almacena la UID de la tarjeta escaneada
int nroventa=1000;
int producto ; 
String mensaje ="";

int op = -1;
int enablePin = 7;
int in1 = 6;
int in2 = 5;
int enablePin1 = 2;
int in3 = 4;
int in4 = 3;

void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(enablePin1, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  Serial.begin(9600);     // Para depuración
  mySerial.begin(9600);
  // Comunicación con el otro Arduino

  SPI.begin();
  mfrc522.PCD_Init();
}

// Esta función lee los comandos de Processing (PC)
// y los pasa a la librería.
void checkSerialFromPC() {
  if (Serial.available()) {
    String mensajePC = Serial.readStringUntil('\n'); // Leemos el mensaje UNA SOLA VEZ
    mensajePC.trim(); // Limpiamos espacios

    if (mensajePC.length() == 0) return;

    // --- COMANDO DE STOCK ---
    if (mensajePC.startsWith("STOCK1:")) {
      int cantidad = mensajePC.substring(7).toInt();
      Serial.print("Recibido STOCK1 = ");
      Serial.println(cantidad);
      manager.agregarStock(1, cantidad); 
    }
    else if (mensajePC.startsWith("STOCK2:")) {
      int cantidad = mensajePC.substring(7).toInt();
      Serial.print("Recibido STOCK2 = ");
      Serial.println(cantidad);
      manager.agregarStock(2, cantidad); 
    }

    // --- COMANDO AÑADIR USUARIO ---
    else if (mensajePC.startsWith("UID:")) {
      String uidHex = mensajePC.substring(4);
      uidHex.trim();
      manager.agregarUsuario(uidHex);
    }

    // --- COMANDO ELIMINAR USUARIO ---
    else if (mensajePC.startsWith("DELUID:")) {
      String uidHex = mensajePC.substring(7);
      uidHex.trim();
      manager.eliminarUsuario(uidHex);
    }

    // --- NUEVO COMANDO: AÑADIR SALDO ---
    else if (mensajePC.startsWith("ADDSALDO:")) {
      String datos = mensajePC.substring(9); // Ej: "AABBCCDD:5000"
      
      int separador = datos.indexOf(':');
      if (separador != -1) {
        String uidHex = datos.substring(0, separador);
        long monto = datos.substring(separador + 1).toInt();
        
        Serial.print("Recibido Saldo: ");
        Serial.print(monto);
        Serial.print(" para UID: ");
        Serial.println(uidHex);
        
        manager.agregarSaldo(uidHex, monto);
      }
    }
  }
}


void loop() {
  
  // 1. Revisa si hay comandos nuevos desde el PC
  checkSerialFromPC();

  // 2. Espera a que el Arduino 1 (keypad) envíe un producto
  if (!mySerial.available()) {
    return; // Si no hay producto seleccionado, no hace nada
  }

  // 3. Espera a que se presente una tarjeta
  if (!mfrc522.PICC_IsNewCardPresent()) return;
  if (!mfrc522.PICC_ReadCardSerial()) return;

  // Si llegamos aquí, tenemos AMBAS cosas: un producto y una tarjeta.
  
  // Leemos el producto que envió el Arduino 1
  op = mySerial.read();
  
  // Asigna precio y revisa stock
  if(op==0){
     producto=2000;
     if(manager.getStock(1) == 0){ 
      mySerial.println("sin stock");
      mfrc522.PICC_HaltA(); // Detiene la lectura de la tarjeta
      return;
     }
     }
    else
    {
    producto=1000;
     if(manager.getStock(2) == 0){
      mySerial.println("sin stock");
      mfrc522.PICC_HaltA(); // Detiene la lectura de la tarjeta
      return;
     }
    }
  
  printUID(); // Almacena la UID escaneada en la variable global 'UID'
  
  // Verificamos la compra usando la librería
  int estadoCompra = manager.verificarCompra(UID, producto);

  if (estadoCompra == COMPRA_OK) {
      Serial.println("Usuario n°"); //Mensaje a processing
      
      // Realiza el pago
      manager.realizarPago(UID, producto);
      
      mySerial.println("Pago realizado"); // Mensaje para Arduino 1
      nroventa++;
      
      //Mensajes a processing 
      Serial.println("Exitoso");
      Serial.println(nroventa);
 
      ejecutarAccion(op); // Mueve el motor
      Serial.println("Registro:" + String(op) + ":" + String(producto));
  }
  else if (estadoCompra == ERROR_SALDO_INSUFICIENTE) {
       mySerial.println("Saldo insuficiente"); // Mensaje para Arduino 1
       Serial.println("No exitoso"); //Mensaje a processing
  }
  else if (estadoCompra == ERROR_USUARIO_NO_ENCONTRADO) {
       mySerial.println("No registrado"); // Mensaje para Arduino 1
       Serial.println("No exitoso"); //Mensaje a processing
  }
  
  mfrc522.PICC_HaltA(); // Detiene la lectura de la tarjeta actual
}

void ejecutarAccion(int idCodigo) {
  switch (idCodigo) {
    case 0:
    //Mensajes a processing
    Serial.println("Coca de vidrio");
    Serial.println(producto);
   
    manager.reducirStock(1); // Usa la librería
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(enablePin, HIGH);
      delay(5000);
      digitalWrite(enablePin, LOW);
      break;
    case 1:
      //Mensajes a processing
      Serial.println("Fanta de vidrio");
  }
}

void printUID() {
  Serial.print("UID leido: ");
  
  // Copia el UID (los primeros 4 bytes) a la variable global 'UID'
  for (byte i = 0; i < 4; i++) {
    UID[i] = mfrc522.uid.uidByte[i];
    
    // Imprime el UID en el Monitor Serial (para depuración)
    if (UID[i] < 0x10) {
      Serial.print(" 0");
    } else {
      Serial.print(" ");
    }
    Serial.print(UID[i], HEX);
  }
  Serial.println(); // Salto de línea
  
  // Convierte el UID a mayúsculas para imprimirlo
  // (Esto es solo para depuración, no afecta la lógica)
  for (byte i = 0; i < 4; i++) {
    if (UID[i] < 0x10) {
      Serial.print("0");
    }
    Serial.print(UID[i], HEX);
  }
  Serial.println();
}