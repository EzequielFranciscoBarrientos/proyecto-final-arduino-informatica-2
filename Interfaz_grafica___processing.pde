import processing.serial.*;    // 1. Importa la librería de comunicación serial de Processing.
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
// 6. Importa ArrayList para el buffer de ventas en memoria.


Serial myPort;
String mensaje = "";
String[] mensajes = new String[20];  // Arreglo para mensajes de control (Pantalla 5 original, ya no se usa para ventas)
int indice = 0;
int tiempoInicio=0;

int rectX = 100;
int rectY = 150;
int pantalla=0;
// 0:Principal, 1:Stock, 2:Ingreso Stock, 3:Saldo, 4:Ingreso Saldo, 5:Ventas (Tabla), 6:Cargar Archivo

int productoSeleccionado = 0;
String cantidadIngresada = "";
// int tarjetadesignada=0; // ELIMINADO
int usuarioSeleccionadoParaSaldo = -1; // NUEVO

//Usuarios registrados
int ingresaruid;
String nombre = "";
String UID = "";
String indiceEliminar = "";

// 🔄 CAMBIO CLAVE: Reemplazo de los ArrayLists de nombres y uids
ArrayList<Usuario> usuarios = new ArrayList<Usuario>();


int stockActual1=0;
int stockActual2=0;
// Nombre del archivo de registro
String nombreArchivo = "registro_ventas.txt";
// Define los nombres de los productos para el registro
final String[] PRODUCTOS = {"Producto 1 - $2000", "Producto 2 - $1000"};
// === NUEVAS VARIABLES PARA EL FLUJO DE DATOS SOLICITADO ===
// Este ArrayList mantiene las ventas de la sesión actual O el historial cargado.
ArrayList<String> registrosEnMemoria = new ArrayList<String>();
boolean archivoCargado = false; // Bandera para la pantalla 6.


// ===============================================
// FUNCIÓN setup()
// ===============================================

void setup() {
  size(1000, 500);
  frameRate(60);
  rectX = width/8;
  rectY = height/8;
  background(200, 200, 200);

  println(Serial.list());
  myPort = new Serial(this, "COM5", 9600);
 
  tiempoInicio = millis();
}


// ===============================================
// FUNCIÓN draw()
// ===============================================

void draw() {
  // Dibuja el fondo con degradado
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    int gris = int(lerp(220, 30, inter));
    stroke(gris);
    line(0, y, width, y);
  }
  
  // Lógica de navegación entre pantallas
  if (pantalla == 0) {
    botones();
  } else if (pantalla == 1) {
    stock();
  } else if (pantalla == 2) {
    pantallaIngresostock();
  } else if (pantalla==3) {
    seleccionarUsuarioSaldo();
// CAMBIO
  } else if (pantalla==4) {
    pantallaIngresosaldo();
  } else if (pantalla==5) {
    archivo();
  // Pantalla de VENTAS (Tabla de registrosEnMemoria)
  } else if (pantalla==6) {
    pantallaCargarArchivo();
// Pantalla de CARGAR ARCHIVO
  }
   else if (pantalla==7) {
    usuarios();
  }
   else if (pantalla==8) {
    añadirusuario();
  }
  else if (pantalla==9) {
    eliminarusuario();
  }
  else if (pantalla==10){
  stockcuadro();
  }
}

// ===============================================
// PANTALLA PRINCIPAL (BOTONES uno al lado del otro)
// ===============================================

void botones() {
  int i;
// Dibuja 4 botones
  for (i=0; i<=4; i++) { 
    fill(251, 251, 251);
// Posición original: uno al lado del otro
    rect(rectX+(i*150), rectY+110, 130, 40); 
  }
  fill(0, 0, 0);
  textSize(15);
  textAlign(CENTER, CENTER); 
  
  text("CARGAR SALDO", (rectX+(0*150))+65, rectY+20+110);
  text("STOCK", (rectX+(1*150))+65, rectY+20+110);
  text("TRANSACCIONES", (rectX+(2*150))+65, rectY+20+110);
  text("CARGAR ARCHIVO", (rectX+(3*150))+65, rectY+20+110);
  text("USUARIOS", (rectX+(4*150))+65, rectY+20+110);
}

// ===============================================
// MANEJO DE CLICS
// ===============================================

void mousePressed() {
  if (pantalla==0) {
    // Botón 1: CARGAR SALDO (i=0)
    if (mouseX > rectX + (0 * 150) && mouseX < rectX + (0 * 150) + 130 &&
      mouseY > rectY+110 && mouseY < rectY + 40+110) {
      
      usuarioSeleccionadoParaSaldo = -1;
      cantidadIngresada = "";
      pantalla=3;
    }

    // Botón 2: STOCK (i=1)
    
    if (mouseX > rectX + (1 * 150) && mouseX < rectX + (1 * 150) + 130 &&
      mouseY > rectY+110 && mouseY < rectY + 40+110) {
      stock();
      pantalla=10;
    }
   
    // Botón 3: VENTAS (i=2) -> Muestra el buffer actual
    if (mouseX > rectX + (2 * 150) && mouseX < rectX + (2 * 150) + 130 &&
      mouseY > rectY+110 && mouseY < rectY+110 + 40) {
      pantalla=5;
    }
    
    // Botón 4: CARGAR ARCHIVO (i=3) -> Carga el historial
    if (mouseX > rectX + (3 * 150) && mouseX < rectX + (3 * 150) + 130 &&
      mouseY > rectY+110 && mouseY < rectY+110 + 40) {
      pantalla=6;
    }
    // Botón 5: USUARIOS (i=4) 
    if (mouseX > rectX + (4 * 150) && mouseX < rectX + (4 * 150) + 130 &&
      mouseY > rectY+110 && mouseY < rectY+110 + 40) {
      pantalla=7;
    }
    
    
  } else if (pantalla==1) { // STOCK
    
    if (mouseX > rectX && mouseX < rectX + 130 &&
      mouseY > rectY + (1*100) && mouseY < rectY + (1*100) + 40) {
      productoSeleccionado = 1;
      cantidadIngresada = "";
      pantalla = 2;
    }
    if (mouseX > rectX && mouseX < rectX + 130 &&
      mouseY > rectY + (2*100) && mouseY < rectY + (2*100) + 40) {
      productoSeleccionado = 2;
      cantidadIngresada = "";
      pantalla = 2;
    }
    if (mouseX > 500 && mouseX < 500 + 130 &&
      mouseY > 300 && mouseY < 300 + 40) {
      pantalla = 0;
    }
  } else if (pantalla==2) { // INGRESO STOCK
    
    if (mouseX > 500 && mouseX < 500 + 130 &&
      mouseY > 300 && mouseY < 300 + 40) {
      pantalla = 0;
    }
  } else if (pantalla==3) { 
    
    // Revisar clics en la lista de usuarios
// 🔄 CAMBIO: Uso de usuarios.size()
    for (int i = 0; i < usuarios.size(); i++) {
      int yBoton = 100 + (i * 40);
      if (mouseX > 100 && mouseX < 100 + 400 &&
          mouseY > yBoton && mouseY < yBoton + 35) {
            
        usuarioSeleccionadoParaSaldo = i;
// Guardamos el índice del usuario
        cantidadIngresada = "";
        pantalla = 4;
// Vamos a la pantalla de ingreso de monto
        break;
// Salimos del loop
      }
    }
    
    // Botón Volver
    if (mouseX > 500 && mouseX < 500 + 130 &&
      mouseY > 300 && mouseY < 300 + 40) {
      pantalla = 0;
    }
  } else if (pantalla==4) { // INGRESO SALDO
    
    if (mouseX > 500 && mouseX < 500 + 130 &&
      mouseY > 300 && mouseY < 300 + 40) {
      pantalla = 0;
    }
  } else if (pantalla==5) { // VENTAS (TABLA)
    
    if (mouseX > width - 150 && mouseX < width - 20 &&
        mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
  } 
  
  else if (pantalla==6) { 
      
  }
  else if (pantalla==7) { 
     if (mouseX > width - 150 && mouseX < width - 20 &&
        mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
     
   // Botón Añadir
  if (mouseX > width - 170 && mouseX < width - 170 + 120 &&
      mouseY > 150 && mouseY < 150 + 50) {
    pantalla = 8;
    }

  // Botón Eliminar
  if (mouseX > width - 170 && mouseX < width - 170 + 120 &&
      mouseY > 220 && mouseY < 220 + 50) {
    pantalla = 9;
    }
  }
   else if (pantalla==8) {
     if (mouseX > width - 150 && mouseX < width - 20 &&
        mouseY > height - 50 && mouseY < height - 10) { 
      nombre = "";
      UID = "";
      pantalla = 0;
    }
   }
  else if (pantalla==9) {
   if (mouseX > width - 150 && mouseX < width - 20 &&
        mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
  }
  else if(pantalla==10){
  if (mouseX > width - 150 && mouseX < width - 20 &&
        mouseY > height - 50 && mouseY < height - 10) { 
      pantalla = 0;
    }
     
   // Botón Añadir
  if (mouseX > width - 170 && mouseX < width - 170 + 120 &&
      mouseY > 150 && mouseY < 150 + 50) {
    pantalla = 1;
    }  
  }
}

// ===============================================
// MANEJO DE TECLAS (Stock, Saldo, Usuario, UID)
// ===============================================

void keyPressed() {
  
  if (pantalla == 2) { // INGRESO STOCK
    if (key >= '0' && key <= '9') {
      cantidadIngresada += key;
    } else if (key == BACKSPACE) {
      if (cantidadIngresada.length() > 0) {
        cantidadIngresada = cantidadIngresada.substring(0, cantidadIngresada.length() - 1);
      }
    } 
    else if (key == ENTER || key == RETURN) {
      if (cantidadIngresada.length() > 0) {
        String datos =cantidadIngresada + "\n";
        if (productoSeleccionado == 1) {
          String mensajeFinal = "STOCK1:" + datos;
          myPort.write(mensajeFinal);
        } else if (productoSeleccionado == 2) {
          String mensajeFinal = "STOCK2:" + datos;
          myPort.write(mensajeFinal);
        }
        pantalla = 0;
      }
    } else if (key == ESC) {
      pantalla = 0;
      cantidadIngresada = "";
    }
  }
  
  else if (pantalla==4) { // INGRESO SALDO
    if (key >= '0' && key <= '9') {
      cantidadIngresada += key;
    } else if (key == BACKSPACE) {
      if (cantidadIngresada.length() > 0) {
        cantidadIngresada = cantidadIngresada.substring(0, cantidadIngresada.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      
      // Solo enviar si hay un monto y un usuario seleccionado
//  CAMBIO: Uso de usuarios.size()
      if (cantidadIngresada.length() > 0 && usuarioSeleccionadoParaSaldo != -1 && usuarioSeleccionadoParaSaldo < usuarios.size()) {
        
        // Obtenemos la UID del usuario seleccionado
//  CAMBIO: Acceso a la propiedad 'uid' del objeto Usuario
        String uid = usuarios.get(usuarioSeleccionadoParaSaldo).uid;
        uid = uid.replace(" ", "").toUpperCase(); // Limpiamos la UID
        
        String monto = cantidadIngresada;
// Formato del comando: "ADDSALDO:UID:MONTO\n"
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
  
   

else if (pantalla == 8) { // AÑADIR USUARIO
  // --- Lógica para ingresar el NOMBRE ---
  if (ingresaruid == 0) {  
    if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z') || key == ' ') {
      nombre += key;
    } else if (key == BACKSPACE && nombre.length() > 0) {
   
      nombre = nombre.substring(0, nombre.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      ingresaruid = 1;
// Pasa a la etapa de ingresar UID
    }
  } 
  // --- Lógica para ingresar la UID ---
  else {  
    // Esta línea es la original y permite letras y números
    if ((key >= '0' && key <= '9' ||(key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z') || key == ' '))  {
      UID += key;
    } else if (key == BACKSPACE && UID.length() > 0) {
      UID = UID.substring(0, UID.length() - 1);
    } 
    
    else if (key == ENTER || key == RETURN) {
  
//  CAMBIO CLAVE: Se crea un objeto Usuario y se añade a la lista
      usuarios.add(new Usuario(nombre, UID));
      
      // CAMBIO: Esta es la forma correcta de enviar el comando
      myPort.write("UID:" + UID + "\n");
      println("Enviando UID: " + UID);
      
      nombre = "";
      UID = "";
      ingresaruid = 0;
      pantalla = 7;
    }
    
  }
 }
 
else if (pantalla == 9) { // ELIMINAR USUARIO
  if (key >= '0' && key <= '9') {
    indiceEliminar += key;
  } 
  else if (key == BACKSPACE && indiceEliminar.length() > 0) {
    indiceEliminar = indiceEliminar.substring(0, indiceEliminar.length() - 1);
  } 
  
  else if ((key == ENTER || key == RETURN) && indiceEliminar.length() > 0) {
    int numero = int(indiceEliminar);
    int i = numero - 1;  // índice real (0-based)
    
//  CAMBIO: Uso de usuarios.size()
    if (i >= 0 && i < usuarios.size()) {
      // Obtenemos la UID que vamos a eliminar
//  CAMBIO: Acceso a la propiedad 'uid' antes de eliminar
      String uidAEliminar = usuarios.get(i).uid;
//  CAMBIO CLAVE: Solo se elimina un elemento de la lista 'usuarios'
      usuarios.remove(i);
      
// Enviar UID al Arduino para que la borre
      uidAEliminar = uidAEliminar.replace(" ", "").toUpperCase();
// limpieza por si acaso
      
      // CAMBIO: Añadimos el "\n" (salto de línea) al final.
      myPort.write("DELUID:" + uidAEliminar + "\n");
      
      println("UID eliminada localmente y enviada al Arduino: " + uidAEliminar);
// Volver al menú principal de usuarios
      indiceEliminar = "";
      pantalla = 7;
    } 
    else {
      println("Número inválido");
      indiceEliminar = "";
    }
  }
  
}

}
