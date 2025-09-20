//proyecto final de arduino //
#include <stdio.h>
//Bibliotecas lector RFID
#include <SPI.h>
#include <MFRC522.h>

#define RST_PIN  9      // constante para referenciar pin de reset
#define SS_PIN  10      // constante para referenciar pin de slave select

MFRC522 mfrc522(SS_PIN, RST_PIN); // crea objeto mfrc522 enviando pines de slave select y reset

void setup() {
  Serial.begin(9600);     // inicializa comunicacion por monitor serie a 9600 bps
  SPI.begin();        // inicializa bus SPI
  mfrc522.PCD_Init();     // inicializa modulo lector
}

void loop() {
  if ( ! mfrc522.PICC_IsNewCardPresent()) // si no hay una tarjeta presente
    return;         
  if ( ! mfrc522.PICC_ReadCardSerial())   // si no puede obtener datos de la tarjeta
    return; 
    Serial.print("Hola");
    mfrc522.PICC_HaltA();                   // detiene comunicacion con tarjeta     
}

