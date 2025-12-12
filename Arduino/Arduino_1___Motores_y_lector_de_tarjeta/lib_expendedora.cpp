#include "lib_expendedora.h"

// =========================================================
// CONSTRUCTOR E INICIALIZACIÓN
// =========================================================
LibExpendedora::LibExpendedora() {
	_stock1 = 0;
	_stock2 = 0;
	_precio1 = 2000; // Precio por defecto prod 1
	_precio2 = 1000; // Precio por defecto prod 2
	_totalUsuarios = 0;
	
	// Inicializamos todos los slots de usuarios como vacíos
	for (int i = 0; i < 10; i++) {
		_usuarios[i].activo = false;
		_usuarios[i].saldo = 0;
	}
}

// =========================================================
// MÉTODOS DE STOCK
// =========================================================

// Sumar stock a un producto
void LibExpendedora::agregarStock(int producto, int cantidad) {
	if (producto == 1) {
		_stock1 += cantidad;
	} else if (producto == 2) {
		_stock2 += cantidad;
	}
	_reportarStock(); // Avisar cambios
}

// Restar stock (al vender)
void LibExpendedora::reducirStock(int producto) {
	if (producto == 1 && _stock1 > 0) {
		_stock1--;
	} else if (producto == 2 && _stock2 > 0) {
		_stock2--;
	}
	_reportarStock(); // Avisar cambios
}

// Consultar stock actual
int LibExpendedora::getStock(int producto) {
	if (producto == 1) {
		return _stock1;
	} else if (producto == 2) {
		return _stock2;
	}
	return 0;
}

// =========================================================
// MÉTODOS DE PRECIOS
// =========================================================

void LibExpendedora::setPrecio(int producto, int nuevoPrecio) {
	if (producto == 1) _precio1 = nuevoPrecio;
	else if (producto == 2) _precio2 = nuevoPrecio;
}

int LibExpendedora::getPrecio(int producto) {
	if (producto == 1) return _precio1;
	else if (producto == 2) return _precio2;
	return 0;
}

// =========================================================
// GESTIÓN DE USUARIOS (CRUD)
// =========================================================

// Agregar Usuario
bool LibExpendedora::agregarUsuario(String uidHex) {
	if (_totalUsuarios >= 10) {
		Serial.println("Memoria llena (10 usuarios).");
		return false;
	}
	
	int slot = encontrarSlotVacio();
	if (slot == -1) return false;
	
	// Guardamos datos en el slot encontrado
	_usuarios[slot].activo = true;
	_usuarios[slot].saldo = 0;
	hexStringToByteArray(uidHex, _usuarios[slot].uid); // Convertimos String a Bytes
	_totalUsuarios++;
	
	Serial.print("UID guardada en slot #");
	Serial.print(slot);
	return true;
}

// Eliminar Usuario
bool LibExpendedora::eliminarUsuario(String uidHex) {
	byte uidTemp[4];
	hexStringToByteArray(uidHex, uidTemp);
	
	int indice = encontrarUsuario(uidTemp);
	
	if (indice != -1) {
		_usuarios[indice].activo = false; // Marcamos como inactivo (borrado lógico)
		_totalUsuarios--;
		Serial.println("UID eliminada.");
		return true;
	}
	
	Serial.println("UID no encontrada para eliminar.");
	return false;
}

// =========================================================
// GESTIÓN DE SALDOS Y PAGOS
// =========================================================

// Cargar saldo
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

// Verificar si se puede comprar (Lógica de negocio central)
int LibExpendedora::verificarCompra(byte uid[4], int precio) {
	int indice = encontrarUsuario(uid);
	
	// Caso 1: Usuario no existe
	if (indice == -1) {
		return ERROR_USUARIO_NO_ENCONTRADO;
	}
	
	// Caso 2: Saldo suficiente
	if (_usuarios[indice].saldo >= precio) {
		return COMPRA_OK;
	} else {
		// Caso 3: Saldo insuficiente
		return ERROR_SALDO_INSUFICIENTE;
	}
}

// Descontar saldo
void LibExpendedora::realizarPago(byte uid[4], int precio) {
	int indice = encontrarUsuario(uid);
	if (indice != -1) {
		_usuarios[indice].saldo -= precio;
	}
}

// =========================================================
// FUNCIONES PRIVADAS (HELPERS)
// =========================================================

// Buscar índice en el array de usuarios comparando UIDs byte por byte
int LibExpendedora::encontrarUsuario(byte uid[4]) {
	for (int i = 0; i < 10; i++) {
		if (!_usuarios[i].activo) continue; // Saltar usuarios borrados
		
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

// Encontrar primera posición libre
int LibExpendedora::encontrarSlotVacio() {
	for (int i = 0; i < 10; i++) {
		if (!_usuarios[i].activo) {
			return i;
		}
	}
	return -1;
}

// Convertir String Hex ("AABB") a Array de Bytes ({0xAA, 0xBB})
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

// Reportar estado actual al monitor serial (Formato para Processing)
void LibExpendedora::_reportarStock() {
	Serial.println("STOCK_UPDATE:" + String(_stock1) + ":" + String(_stock2));  
}
