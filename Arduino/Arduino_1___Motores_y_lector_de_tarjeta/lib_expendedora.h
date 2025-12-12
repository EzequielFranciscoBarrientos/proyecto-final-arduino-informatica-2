#ifndef LIB_EXPENDEDORA_H
#define LIB_EXPENDEDORA_H

#include <Arduino.h>

// =========================================================
// DEFINICIONES DE ESTRUCTURAS Y CONSTANTES
// =========================================================

// Estructura para almacenar datos de cada usuario en RAM
struct Usuario {
	byte uid[4];   // Identificador único de la tarjeta
	long saldo;    // Dinero disponible
	bool activo;   // true = usuario registrado, false = espacio vacío
};

// Códigos de respuesta para validar compras
#define COMPRA_OK 0
#define ERROR_SALDO_INSUFICIENTE 1
#define ERROR_USUARIO_NO_ENCONTRADO 2

// =========================================================
// CLASE PRINCIPAL
// =========================================================
class LibExpendedora {
public:
	// Constructor
	LibExpendedora();
	
	// -- MÉTODOS DE STOCK --
	void agregarStock(int producto, int cantidad);
	void reducirStock(int producto);
	int getStock(int producto);
	
	// -- MÉTODOS DE PRECIOS --
	void setPrecio(int producto, int nuevoPrecio);
	int getPrecio(int producto);
	
	// -- MÉTODOS DE USUARIOS Y SALDOS --
	
	// Añade un nuevo usuario usando el String Hexadecimal (ej: "AABBCCDD")
	bool agregarUsuario(String uidHex);
	
	// Elimina un usuario buscando su String Hexadecimal
	bool eliminarUsuario(String uidHex);
	
	// Carga saldo a un usuario específico
	bool agregarSaldo(String uidHex, long monto);
	
	// Verifica lógica de negocio: ¿Existe el usuario? ¿Tiene saldo >= precio?
	int verificarCompra(byte uid[4], int precio);
	
	// Ejecuta la resta del saldo (cobro)
	void realizarPago(byte uid[4], int precio);
	
private:
	// --- VARIABLES PRIVADAS (BASE DE DATOS INTERNA) ---
	Usuario _usuarios[10]; // Array fijo para máximo 10 usuarios
	int _totalUsuarios;
	
	int _stock1;
	int _stock2;
	
	int _precio1;
	int _precio2;
	
	// -- FUNCIONES AUXILIARES PRIVADAS --
	int encontrarUsuario(byte uid[4]);      // Busca usuario y devuelve su posición (índice)
	int encontrarSlotVacio();               // Busca un espacio libre en el array
	void hexStringToByteArray(String hex, byte* byteArray); // Convierte texto a bytes
	
	void _reportarStock();                  // Envía el stock actualizado por Serial
};

#endif
