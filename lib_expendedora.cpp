
#include "lib_expendedora.h"

// Constructor: Inicializa todas las variables
LibExpendedora::LibExpendedora() {
	_stock1 = 0;
	_stock2 = 0;
	_totalUsuarios = 0;
	// Inicializa todos los usuarios como inactivos
	for (int i = 0; i < 10; i++) {
		_usuarios[i].activo = false;
		_usuarios[i].saldo = 0;
	}
}

// -- M�TODOS DE STOCK --

void LibExpendedora::agregarStock(int producto, int cantidad) {
	if (producto == 1) {
		_stock1 += cantidad;
	} else if (producto == 2) {
		_stock2 += cantidad;
	}
	_reportarStock();
}

void LibExpendedora::reducirStock(int producto) {
	if (producto == 1 && _stock1 > 0) {
		_stock1--;
	} else if (producto == 2 && _stock2 > 0) {
		_stock2--;
	}
	_reportarStock();
}

int LibExpendedora::getStock(int producto) {
	if (producto == 1) {
		return _stock1;
	} else if (producto == 2) {
		return _stock2;
	}
	return 0;
}

// -- M�TODOS DE USUARIOS Y SALDOS --

bool LibExpendedora::agregarUsuario(String uidHex) {
	if (_totalUsuarios >= 10) {
		Serial.println("Memoria llena (10 usuarios).");
		return false; // Memoria llena
	}
	
	int slot = encontrarSlotVacio();
	if (slot == -1) return false; // No deber�a pasar si totalUsuarios < 10
	
	// Guardar usuario
	_usuarios[slot].activo = true;
	_usuarios[slot].saldo = 0; // Saldo inicial 0
	hexStringToByteArray(uidHex, _usuarios[slot].uid);
	_totalUsuarios++;
	
	Serial.print("UID guardada en slot #");
	Serial.print(slot);
	return true;
}

bool LibExpendedora::eliminarUsuario(String uidHex) {
	byte uidTemp[4];
	hexStringToByteArray(uidHex, uidTemp);
	
	int indice = encontrarUsuario(uidTemp);
	
	if (indice != -1) {
		// Encontrado, marcar como inactivo
		_usuarios[indice].activo = false;
		_totalUsuarios--;
		Serial.println("UID eliminada.");
		return true;
	}
	
	Serial.println("UID no encontrada para eliminar.");
	return false;
}

bool LibExpendedora::agregarSaldo(String uidHex, long monto) {
	byte uidTemp[4];
	hexStringToByteArray(uidHex, uidTemp);
	
	int indice = encontrarUsuario(uidTemp);
	
	if (indice != -1) {
		// Usuario encontrado, agregar saldo
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

void LibExpendedora::realizarPago(byte uid[4], int precio) {
	int indice = encontrarUsuario(uid);
	if (indice != -1) {
		_usuarios[indice].saldo -= precio;
	}
}

// -- FUNCIONES PRIVADAS DE AYUDA --

int LibExpendedora::encontrarUsuario(byte uid[4]) {
	for (int i = 0; i < 10; i++) {
		if (!_usuarios[i].activo) continue; // Slot vac�o
		
		bool match = true;
		for (int j = 0; j < 4; j++) {
			if (_usuarios[i].uid[j] != uid[j]) {
				match = false;
				break;
			}
		}
		if (match) return i; // Devuelve el �ndice
	}
	return -1; // No encontrado
}

int LibExpendedora::encontrarSlotVacio() {
	for (int i = 0; i < 10; i++) {
		if (!_usuarios[i].activo) {
			return i;
		}
	}
	return -1; // No hay slots vac�os
}

// Convierte "AABBCCDD" a {0xAA, 0xBB, 0xCC, 0xDD}
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

	// Esta es la funci�n que env�a el mensaje a Processing
	void LibExpendedora::_reportarStock() {
		// Env�a el stock a Processing con el formato: "STOCK_UPDATE:stock1:stock2"
		// Usa _stock1 y _stock2 que son las variables privadas de la librer�a
		Serial.println("STOCK_UPDATE:" + String(_stock1) + ":" + String(_stock2));	
}
