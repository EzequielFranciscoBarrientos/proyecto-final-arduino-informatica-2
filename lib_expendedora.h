
#ifndef LIB_EXPENDEDORA_H
#define LIB_EXPENDEDORA_H

#include <Arduino.h>

// Estructura para almacenar cada usuario
struct Usuario {
	byte uid[4];
	long saldo;
	bool activo; // true si el slot está en uso
};

// Códigos de estado para la compra
#define COMPRA_OK 0
#define ERROR_SALDO_INSUFICIENTE 1
#define ERROR_USUARIO_NO_ENCONTRADO 2

class LibExpendedora {
public:
	// Constructor
	LibExpendedora();
	
	// -- MÉTODOS DE STOCK --
	void agregarStock(int producto, int cantidad);
	void reducirStock(int producto);
	int getStock(int producto);
	
	// -- MÉTODOS DE USUARIOS Y SALDOS --
	
	// Añade un nuevo usuario a partir de un String Hex (ej: "AABBCCDD")
	bool agregarUsuario(String uidHex);
	
	// Elimina un usuario a partir de un String Hex
	bool eliminarUsuario(String uidHex);
	
	// Agrega saldo a un usuario a partir de un String Hex
	bool agregarSaldo(String uidHex, long monto);
	
	// Verifica si un usuario (por byte[] de RFID) puede comprar
	int verificarCompra(byte uid[4], int precio);
	
	// Realiza el pago (resta el saldo)
	void realizarPago(byte uid[4], int precio);
	
private:
	// Almacenamiento de usuarios
	Usuario _usuarios[10];
	int _totalUsuarios;
	
	// Almacenamiento de stock
	int _stock1;
	int _stock2;
	
	// -- Funciones privadas de ayuda --
	int encontrarUsuario(byte uid[4]); // Devuelve el índice del usuario
	int encontrarSlotVacio(); // Devuelve el índice de un slot libre
	void hexStringToByteArray(String hex, byte* byteArray); // Convierte String a byte[]
	
	void _reportarStock();
};

#endif
