#include "lib_expendedora.h"

// Constructor: inicializa stock, usuarios y saldos
LibExpendedora::LibExpendedora() {
  _stock1 = 0;
  _stock2 = 0;
  _totalUsuarios = 0;
  for (int i = 0; i < 10; i++) {
    _usuarios[i].activo = false;
    _usuarios[i].saldo = 0;
  }
}

// Funcion que agrega stock al producto indicado
void LibExpendedora::agregarStock(int producto, int cantidad) {
  if (producto == 1) {
    _stock1 += cantidad;
  } else if (producto == 2) {
    _stock2 += cantidad;
  }
  _reportarStock();
}

// Funcion que reduce el stock del producto si es mayor a cero
void LibExpendedora::reducirStock(int producto) {
  if (producto == 1 && _stock1 > 0) {
    _stock1--;
  } else if (producto == 2 && _stock2 > 0) {
    _stock2--;
  }
  _reportarStock();
}

// Funcion que devuelve el stock disponible de un producto
int LibExpendedora::getStock(int producto) {
  if (producto == 1) {
    return _stock1;
  } else if (producto == 2) {
    return _stock2;
  }
  return 0;
}

// Funcion que agrega un usuario nuevo con saldo cero
bool LibExpendedora::agregarUsuario(String uidHex) {
  if (_totalUsuarios >= 10) {
    Serial.println("Memoria llena (10 usuarios).");
    return false;
  }
  
  int slot = encontrarSlotVacio();
  if (slot == -1) return false;
  
  _usuarios[slot].activo = true;
  _usuarios[slot].saldo = 0;
  hexStringToByteArray(uidHex, _usuarios[slot].uid);
  _totalUsuarios++;
  
  Serial.print("UID guardada en slot #");
  Serial.print(slot);
  return true;
}

// Funcion que elimina un usuario existente por UID
bool LibExpendedora::eliminarUsuario(String uidHex) {
  byte uidTemp[4];
  hexStringToByteArray(uidHex, uidTemp);
  
  int indice = encontrarUsuario(uidTemp);
  
  if (indice != -1) {
    _usuarios[indice].activo = false;
    _totalUsuarios--;
    Serial.println("UID eliminada.");
    return true;
  }
  
  Serial.println("UID no encontrada para eliminar.");
  return false;
}

// Funcion que agrega saldo a un usuario si existe
bool LibExpendedora::agregarSaldo(String uidHex, long monto) {
  byte uidTemp[4];
  hexStringToByteArray(uidHex, uidTemp);
  
  int indice = encontrarUsuario(uidTemp);
  
  if (indice != -1) {
    _usuarios[indice].saldo += monto;
    Serial.print("Nuevo saldo para slot #");
    Serial.print(indice);
    Serial.print(": ");
    Serial.println(_usuarios[indice].saldo);
    return true;
  }
  
  Serial.println("UID no encontrada para saldo.");
  return false;
}

// Funcion que verifica si la compra puede realizarse según saldo
int LibExpendedora::verificarCompra(byte uid[4], int precio) {
  int indice = encontrarUsuario(uid);
  
  if (indice == -1) {
    return ERROR_USUARIO_NO_ENCONTRADO;
  }
  
  if (_usuarios[indice].saldo >= precio) {
    return COMPRA_OK;
  } else {
    return ERROR_SALDO_INSUFICIENTE;
  }
}

// Funcion que descuenta el precio del saldo del usuario
void LibExpendedora::realizarPago(byte uid[4], int precio) {
  int indice = encontrarUsuario(uid);
  if (indice != -1) {
    _usuarios[indice].saldo -= precio;
  }
}

// Funcion que busca un usuario por su UID y devuelve su índice
int LibExpendedora::encontrarUsuario(byte uid[4]) {
  for (int i = 0; i < 10; i++) {
    if (!_usuarios[i].activo) continue;
    
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (_usuarios[i].uid[j] != uid[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

// Funcion que busca un slot disponible para registrar un usuario
int LibExpendedora::encontrarSlotVacio() {
  for (int i = 0; i < 10; i++) {
    if (!_usuarios[i].activo) {
      return i;
    }
  }
  return -1;
}

// Funcion que convierte un string hexadecimal a un arreglo de 4 bytes
void LibExpendedora::hexStringToByteArray(String hex, byte* byteArray) {
  hex.trim();
  int j = 0;
  for (int i = 0; i < hex.length(); i += 2) {
    if (j >= 4) break;
    String byteString = hex.substring(i, i + 2);
    byteArray[j] = (byte) strtol(byteString.c_str(), NULL, 16);
    j++;
  }
}

// Funcion que reporta el stock actual a Processing
void LibExpendedora::_reportarStock() {
  Serial.println("STOCK_UPDATE:" + String(_stock1) + ":" + String(_stock2));  
}
