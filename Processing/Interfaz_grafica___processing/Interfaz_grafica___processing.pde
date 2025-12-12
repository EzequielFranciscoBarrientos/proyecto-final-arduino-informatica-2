// =================================================================================
// ARCHIVO PRINCIPAL: INTERFAZ GRÁFICA Y CONTROL CENTRAL
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. IMPORTACIÓN DE LIBRERÍAS
// ---------------------------------------------------------------------------------
import processing.serial.*;       // Comunicación Serial con Arduino
import java.io.FileWriter;        // Escritura de archivos de texto
import java.io.IOException;       // Manejo de errores de entrada/salida
import java.util.Date;            // Manejo de fechas
import java.text.SimpleDateFormat; // Formateo de fechas (ej: dd-MM-yyyy)
import java.util.ArrayList;       // Listas dinámicas para memoria de datos

// ---------------------------------------------------------------------------------
// 2. DEFINICIÓN DE VARIABLES GLOBALES
// ---------------------------------------------------------------------------------

// --- Comunicación Serial ---
Serial myPort;
String mensaje = "";
String[] mensajes = new String[20]; // Buffer circular para mensajes de control

// --- Navegación y UI ---
int pantalla = 0;           // Controla qué pantalla se muestra actualmente
int rectX, rectY;           // Coordenadas base para elementos UI relativos
int tiempoInicio = 0;       // Para control de tiempos (timers)

// --- Lógica de Productos y Precios ---
int productoSeleccionado = 0;
int stockActual1 = 0;
int stockActual2 = 0;
int precioProd1 = 2000;     // Precio inicial por defecto
int precioProd2 = 1000;     // Precio inicial por defecto
boolean editandoPrecio = false;

// --- Lógica de Entrada de Datos (Teclado) ---
String cantidadIngresada = ""; // Almacena temporalmente lo que el usuario escribe

// --- Gestión de Usuarios y Saldos ---
int usuarioSeleccionadoParaSaldo = -1; // Índice del usuario seleccionado en la lista
int ingresaruid;            // Estado para saber si estamos ingresando Nombre o UID
String nombre = "";         // Buffer para nombre nuevo usuario
String UID = "";            // Buffer para UID nuevo usuario
String indiceEliminar = ""; // Buffer para índice a eliminar
ArrayList<Usuario> usuarios = new ArrayList<Usuario>(); // Lista en memoria de usuarios

// --- Gestión de Archivos ---
String nombreArchivo = "registro_ventas.txt";
String archivoUsuarios = "usuarios_db.txt";
String archivoConfig = "config_vending.txt";
boolean archivoCargado = false; // Bandera para evitar recargas constantes
ArrayList<String> registrosEnMemoria = new ArrayList<String>(); // Historial de ventas

// ---------------------------------------------------------------------------------
// 3. FUNCIONES AUXILIARES GLOBALES
// ---------------------------------------------------------------------------------

// Devuelve un array con los nombres y precios formateados para mostrar en UI
String[] obtenerNombresProductos() {
  return new String[] {"Producto 1 - $" + precioProd1, "Producto 2 - $" + precioProd2};
}

// =================================================================================
// 4. SETUP (CONFIGURACIÓN INICIAL)
// =================================================================================
void setup() {
  size(1000, 500);          // Tamaño de la ventana
  frameRate(60);            // 60 cuadros por segundo
  
  // Definición de coordenadas base responsivas
  rectX = width/8;
  rectY = height/8;
  background(200, 200, 200);
  
  // Inicialización de Serial (Descomentar si tienes el Arduino conectado)
  // println(Serial.list());
  // myPort = new Serial(this, "COM5", 9600);
  
  tiempoInicio = millis();
  
  // --- Carga de Datos Persistentes ---
  delay(2000); // Pequeña espera para asegurar estabilidad al inicio
  cargarUsuariosDesdeArchivo(); // Lee usuarios_db.txt
  cargarConfiguracion();        // Lee config_vending.txt (stock y precios)
}

// =================================================================================
// 5. DRAW (BUCLE PRINCIPAL DE DIBUJO)
// =================================================================================
void draw() {
  // --- Fondo con degradado (Estética) ---
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    int gris = int(lerp(220, 30, inter));
    stroke(gris);
    line(0, y, width, y);
  }
  
  // --- Máquina de Estados (Gestión de Pantallas) ---
  // Dependiendo del valor de 'pantalla', se ejecuta una función de dibujo distinta
  if (pantalla == 0) {
    botones();                  // Menú Principal
  } else if (pantalla == 1) {
    stock();                    // Selección de producto para stock
  } else if (pantalla == 2) {
    pantallaIngresostock();     // Teclado numérico para stock
  } else if (pantalla == 3) {
    seleccionarUsuarioSaldo();  // Lista de usuarios para cargar saldo
  } else if (pantalla == 4) {
    pantallaIngresosaldo();     // Teclado numérico para saldo
  } else if (pantalla == 5) {
    archivo();                  // Tabla de Transacciones (Sesión actual)
  } else if (pantalla == 6) {
    pantallaCargarArchivo();    // Carga historial completo
  } else if (pantalla == 7) {
    usuarios();                 // Tabla de Gestión de Usuarios
  } else if (pantalla == 8) {
    añadirusuario();            // Formulario nuevo usuario
  } else if (pantalla == 9) {
    eliminarusuario();          // Formulario eliminar usuario
  } else if (pantalla == 10){
    stockcuadro();              // Tabla resumen de Stock y Precios
  } else if (pantalla == 11){
    pantallaIngresoPrecio();    // Teclado numérico para cambiar precio
  } else if (pantalla == 12){
    seleccionProductoPrecio();  // Selección de producto para cambiar precio
  }
}

// =================================================================================
// 6. ELEMENTOS DE LA UI PRINCIPAL
// =================================================================================

// Dibuja los botones del menú principal
void botones() {
  int i;
  // Dibuja 5 botones alineados horizontalmente
  for (i = 0; i <= 4; i++) { 
    fill(251, 251, 251);
    rect(rectX + (i * 150), rectY + 110, 130, 40); 
  }
  
  // Etiquetas de texto para los botones
  fill(0, 0, 0);
  textSize(15);
  textAlign(CENTER, CENTER); 
  
  text("CARGAR SALDO", (rectX + (0 * 150)) + 65, rectY + 20 + 110);
  text("STOCK/PRECIO ", (rectX + (1 * 150)) + 65, rectY + 20 + 110);
  text("TRANSACCIONES", (rectX + (2 * 150)) + 65, rectY + 20 + 110);
  text("CARGAR ARCHIVO", (rectX + (3 * 150)) + 65, rectY + 20 + 110);
  text("USUARIOS", (rectX + (4 * 150)) + 65, rectY + 20 + 110);
}

// =================================================================================
// 7. MANEJO DE EVENTOS: MOUSE (Navegación)
// =================================================================================
void mousePressed() {
  
  // --- PANTALLA 0: MENÚ PRINCIPAL ---
  if (pantalla == 0) {
    // Botón 1: Ir a Cargar Saldo
    if (mouseX > rectX + (0 * 150) && mouseX < rectX + (0 * 150) + 130 && mouseY > rectY + 110 && mouseY < rectY + 150) { 
      usuarioSeleccionadoParaSaldo = -1;
      cantidadIngresada = "";
      pantalla = 3;
    }
    // Botón 2: Ir a Stock/Precios (Tabla Resumen)
    if (mouseX > rectX + (1 * 150) && mouseX < rectX + (1 * 150) + 130 && mouseY > rectY + 110 && mouseY < rectY + 150) {
      stock(); // Llama función auxiliar
      pantalla = 10;
    }
    // Botón 3: Ir a Ventas (Buffer actual)
    if (mouseX > rectX + (2 * 150) && mouseX < rectX + (2 * 150) + 130 && mouseY > rectY + 110 && mouseY < rectY + 150) {
      pantalla = 5;
    }
    // Botón 4: Ir a Cargar Archivo (Histórico)
    if (mouseX > rectX + (3 * 150) && mouseX < rectX + (3 * 150) + 130 && mouseY > rectY + 110 && mouseY < rectY + 150) {
      pantalla = 6;
    }
    // Botón 5: Ir a Gestión de Usuarios
    if (mouseX > rectX + (4 * 150) && mouseX < rectX + (4 * 150) + 130 && mouseY > rectY + 110 && mouseY < rectY + 150) {
      pantalla = 7;
    }
  } 
  
  // --- PANTALLA 1: SELECCIÓN DE PRODUCTO PARA STOCK ---
  else if (pantalla == 1) { 
    // Seleccionar Prod 1
    if (mouseX > rectX && mouseX < rectX + 130 && mouseY > rectY + 100 && mouseY < rectY + 140) {
      productoSeleccionado = 1;
      cantidadIngresada = "";
      pantalla = 2; // Ir a ingresar cantidad
    }
    // Seleccionar Prod 2
    if (mouseX > rectX && mouseX < rectX + 130 && mouseY > rectY + 200 && mouseY < rectY + 240) {
      productoSeleccionado = 2;
      cantidadIngresada = "";
      pantalla = 2; // Ir a ingresar cantidad
    }
    // Volver
    if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
      pantalla = 0;
    }
  } 
  
  // --- PANTALLA 2: INGRESO CANTIDAD STOCK ---
  else if (pantalla == 2) { 
    // Volver
    if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
      pantalla = 0;
    }
  } 
  
  // --- PANTALLA 3: SELECCIONAR USUARIO SALDO ---
  else if (pantalla == 3) { 
    // Detectar clic en la lista dinámica de usuarios
    for (int i = 0; i < usuarios.size(); i++) {
      int yBoton = 100 + (i * 40);
      if (mouseX > 100 && mouseX < 500 && mouseY > yBoton && mouseY < yBoton + 35) {
        usuarioSeleccionadoParaSaldo = i; // Guardamos índice
        cantidadIngresada = "";
        pantalla = 4; // Pasamos a ingresar monto
        break;
      }
    }
    // Volver
    if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
      pantalla = 0;
    }
  } 
  
  // --- PANTALLA 4: INGRESO CANTIDAD SALDO ---
  else if (pantalla == 4) { 
    if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
      pantalla = 0;
    }
  } 
  
  // --- PANTALLA 5: TABLA VENTAS ---
  else if (pantalla == 5) { 
    // Volver (Botón abajo derecha)
    if (mouseX > width - 150 && mouseX < width - 20 && mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
  } 
  
  // --- PANTALLA 6: LOGICA DE CARGA (Sin botones, auto) ---
  else if (pantalla == 6) { 
      pantallaCargarArchivo();
  }
  
  // --- PANTALLA 7: GESTIÓN USUARIOS (Tabla) ---
  else if (pantalla == 7) { 
    // Volver
     if (mouseX > width - 150 && mouseX < width - 20 && mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
    // Botón Añadir Usuario
    if (mouseX > width - 170 && mouseX < width - 50 && mouseY > 150 && mouseY < 200) {
      pantalla = 8;
    }
    // Botón Eliminar Usuario
    if (mouseX > width - 170 && mouseX < width - 50 && mouseY > 220 && mouseY < 270) {
      pantalla = 9;
    }
  }
  
  // --- PANTALLA 8: AÑADIR USUARIO ---
  else if (pantalla == 8) {
     if (mouseX > width - 150 && mouseX < width - 20 && mouseY > height - 50 && mouseY < height - 10) { 
      nombre = "";
      UID = "";
      pantalla = 0;
    }
  }
  
  // --- PANTALLA 9: ELIMINAR USUARIO ---
  else if (pantalla == 9) {
    if (mouseX > width - 150 && mouseX < width - 20 && mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
  }
  
  // --- PANTALLA 10: TABLA STOCK Y PRECIOS ---
  else if(pantalla == 10){
    // Volver
    if (mouseX > width - 150 && mouseX < width - 20 && mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
    // Botón Ir a Cambiar Precio
    if (mouseX > width - 220 && mouseX < width - 40 && mouseY > 220 && mouseY < 270) {
      pantalla = 12; 
    }
    // Botón Ir a Añadir Stock
    if (mouseX > width - 220 && mouseX < width - 40 && mouseY > 150 && mouseY < 200) {
      pantalla = 1;
    }  
  }
  
  // --- PANTALLA 11: TECLADO PRECIO ---
  else if (pantalla == 11){
    // Volver / Cancelar
    if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
        pantalla = 10;
        cantidadIngresada = "";
    }
  }
  
  // --- PANTALLA 12: SELECCIÓN PRODUCTO PARA PRECIO ---
  else if (pantalla == 12) { 
     // Seleccionar Prod 1
     if (mouseX > rectX && mouseX < rectX + 130 && mouseY > rectY + 100 && mouseY < rectY + 140) {
        productoSeleccionado = 1;
        cantidadIngresada = "";
        pantalla = 11 ; // Ir a escribir precio
     }
     // Seleccionar Prod 2
     if (mouseX > rectX && mouseX < rectX + 130 && mouseY > rectY + 200 && mouseY < rectY + 240) {
        productoSeleccionado = 2;
        cantidadIngresada = "";
        pantalla = 11; // Ir a escribir precio
     }
     // Cancelar
     if (mouseX > 500 && mouseX < 630 && mouseY > 300 && mouseY < 340) {
        pantalla = 10;
     }
  }
}

// =================================================================================
// 8. MANEJO DE EVENTOS: TECLADO (Inputs de texto)
// =================================================================================
void keyPressed() {
  
  // --- PANTALLA 2: INGRESO DE STOCK ---
  if (pantalla == 2) { 
    if (key >= '0' && key <= '9') {
      cantidadIngresada += key; // Concatenar números
    } else if (key == BACKSPACE) {
      if (cantidadIngresada.length() > 0) {
        cantidadIngresada = cantidadIngresada.substring(0, cantidadIngresada.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      // Enviar comando STOCK al Arduino
      if (cantidadIngresada.length() > 0) {
        String datos = cantidadIngresada + "\n";
        if (productoSeleccionado == 1) {
          myPort.write("STOCK1:" + datos);
        } else if (productoSeleccionado == 2) {
          myPort.write("STOCK2:" + datos);
        }
        pantalla = 0; // Volver al inicio
      }
    } else if (key == ESC) {
      pantalla = 0;
      cantidadIngresada = "";
    }
  }
  
  // --- PANTALLA 4: INGRESO DE SALDO ---
  else if (pantalla == 4) { 
    if (key >= '0' && key <= '9') {
      cantidadIngresada += key;
    } else if (key == BACKSPACE) {
      if (cantidadIngresada.length() > 0) {
        cantidadIngresada = cantidadIngresada.substring(0, cantidadIngresada.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      // Validar monto y usuario seleccionado
      if (cantidadIngresada.length() > 0 && usuarioSeleccionadoParaSaldo != -1 && usuarioSeleccionadoParaSaldo < usuarios.size()) {
        String uid = usuarios.get(usuarioSeleccionadoParaSaldo).uid;
        uid = uid.replace(" ", "").toUpperCase(); // Formatear UID
        String monto = cantidadIngresada;
        
        // Enviar comando ADDSALDO al Arduino
        String mensajeFinal = "ADDSALDO:" + uid + ":" + monto + "\n";
        myPort.write(mensajeFinal);
        println("Enviando comando de saldo: " + mensajeFinal);
        
        pantalla = 0;
        cantidadIngresada = "";
        usuarioSeleccionadoParaSaldo = -1;
      }
    } else if (key == ESC) {
      pantalla = 0;
      cantidadIngresada = "";
      usuarioSeleccionadoParaSaldo = -1;
    }
  }
  
  // --- PANTALLA 8: AÑADIR USUARIO ---
  else if (pantalla == 8) { 
    // ETAPA 1: INGRESAR NOMBRE
    if (ingresaruid == 0) {  
      if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z') || key == ' ') {
        nombre += key;
      } else if (key == BACKSPACE && nombre.length() > 0) {
        nombre = nombre.substring(0, nombre.length() - 1);
      } else if (key == ENTER || key == RETURN) {
        ingresaruid = 1; // Cambiar a Etapa 2 (UID)
      }
    } 
    // ETAPA 2: INGRESAR UID (Hexadecimal)
    else {  
      if ((key >= '0' && key <= '9' ||(key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z') || key == ' '))  {
        UID += key;
      } else if (key == BACKSPACE && UID.length() > 0) {
        UID = UID.substring(0, UID.length() - 1);
      } else if (key == ENTER || key == RETURN) {
        // Crear Usuario, guardar en lista, enviar a Arduino y guardar en archivo
        usuarios.add(new Usuario(nombre, UID));
        myPort.write("UID:" + UID + "\n");
        println("Enviando UID: " + UID);   
        
        guardarUsuariosEnArchivo();
        
        // Reset variables
        nombre = "";
        UID = "";
        ingresaruid = 0;
        pantalla = 7; // Volver a lista usuarios
      }
    }
  }
 
  // --- PANTALLA 9: ELIMINAR USUARIO (Por índice) ---
  else if (pantalla == 9) { 
    if (key >= '0' && key <= '9') {
      indiceEliminar += key;
    } else if (key == BACKSPACE && indiceEliminar.length() > 0) {
      indiceEliminar = indiceEliminar.substring(0, indiceEliminar.length() - 1);
    } else if ((key == ENTER || key == RETURN) && indiceEliminar.length() > 0) {
      
      int numero = int(indiceEliminar);
      int i = numero - 1;  // Convertir a índice de array (0-based)
      
      if (i >= 0 && i < usuarios.size()) {
        String uidAEliminar = usuarios.get(i).uid;
        usuarios.remove(i); // Borrar de memoria
        
        // Avisar a Arduino para borrar de EEPROM/Memoria
        uidAEliminar = uidAEliminar.replace(" ", "").toUpperCase();
        myPort.write("DELUID:" + uidAEliminar + "\n");
        
        guardarUsuariosEnArchivo(); // Actualizar archivo
        println("UID eliminada: " + uidAEliminar);
        
        indiceEliminar = "";
        pantalla = 7;
      } else {
        println("Número inválido");
        indiceEliminar = "";
      }
    }
  }
  
  // --- PANTALLA 11: CAMBIAR PRECIO (Teclado) ---
  else if (pantalla == 11) { 
    if (key >= '0' && key <= '9') {
      cantidadIngresada += key;
    } else if (key == BACKSPACE) {
      if (cantidadIngresada.length() > 0) {
        cantidadIngresada = cantidadIngresada.substring(0, cantidadIngresada.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      if (cantidadIngresada.length() > 0) {
        int nuevoPrecio = int(cantidadIngresada);
        
        // A) Actualizar variable local
        if (productoSeleccionado == 1) precioProd1 = nuevoPrecio;
        else if (productoSeleccionado == 2) precioProd2 = nuevoPrecio;
        
        // B) Enviar comando CAMBIAR_PRECIO al Arduino
        String mensaje = "CAMBIAR_PRECIO:" + productoSeleccionado + ":" + nuevoPrecio + "\n";
        myPort.write(mensaje);
        println("Enviado: " + mensaje);
        
        // C) Guardar en archivo configuración y volver
        guardarConfiguracion();
        pantalla = 10;
        cantidadIngresada = "";
      }
    } else if (key == ESC) {
      pantalla = 10;
      cantidadIngresada = "";
    }
  }
}
