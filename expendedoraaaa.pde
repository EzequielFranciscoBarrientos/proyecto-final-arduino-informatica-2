import processing.serial.*;    // 1. Importa la librería de comunicación serial de Processing.
import java.io.FileWriter;
// 2. Importa la clase para escribir datos en archivos.
import java.io.IOException;
// 3. Importa la clase para manejar errores de entrada/salida.
import java.util.Date;
// 4. Importa la clase para obtener la fecha y hora actual.
import java.text.SimpleDateFormat;
// 5. Importa la clase para dar formato a la fecha y hora.
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
ArrayList<String> nombres = new ArrayList<String>();
ArrayList<String> uids = new ArrayList<String>();


int stockActual1=0;
int stockActual2=0;
// Nombre del archivo de registro
String nombreArchivo = "registro_ventas.txt";
// Define los nombres de los productos para el registro
final String[] PRODUCTOS = {"Coca de vidrio - $2000", "Fanta de vidrio - $1000"};
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
  myPort = new Serial(this, "COM3", 9600);
 
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
    seleccionarUsuarioSaldo(); // CAMBIO
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
    // ... (resto de botones de pantalla 0 sin cambios) ...
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
    for (int i = 0; i < nombres.size(); i++) {
      int yBoton = 100 + (i * 40);
      if (mouseX > 100 && mouseX < 100 + 400 &&
          mouseY > yBoton && mouseY < yBoton + 35) {
            
        usuarioSeleccionadoParaSaldo = i; // Guardamos el índice del usuario
        cantidadIngresada = "";
        pantalla = 4; // Vamos a la pantalla de ingreso de monto
        break; // Salimos del loop
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
// PANTALLAS (stock, saldo, etc.)
// ===============================================

void stockcuadro(){
  fill(0);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Stock Actual", width/2, 30);

  // Definiciones de la tabla
  int xInicio = 100;
  int yInicio = 100;
  int anchoTotal = width - 300;
  // int altoTotal = height - 200; // ELIMINADO: Ya no usamos la altura total de la pantalla
  
  // Definición de columnas
  int col1 = xInicio + 30;     // N° 
  int col2 = xInicio + 300;    // Producto
  // int col3 = xInicio + 700; // ELIMINADO: Esta columna [cite: 11] estaba fuera del 'anchoTotal'

  // Definición de filas
  int filaAltura = 30;  // altura de cada fila
  int yCabecera = yInicio + 40; // Esto es y = 140 (línea bajo el título)

  // CAMBIO: Calcular la altura EXACTA para Header (40px) + 2 filas (30px c/u)
  int altoTabla = (yCabecera - yInicio) + (2 * filaAltura); // 40 + (2 * 30) = 100px
  
  // CAMBIO: Cuadro grande con la altura exacta
  fill(255);
  stroke(0);
  rect(xInicio, yInicio, anchoTotal, altoTabla); // Dibuja el borde exterior

  // CAMBIO: Líneas verticales con la altura exacta
  line(col1, yInicio, col1, yInicio + altoTabla);
  line(col2, yInicio, col2, yInicio + altoTabla);

  // Líneas horizontales (Filas)
  // Dibuja la línea DEBAJO DE LOS TÍTULOS (Crea el espacio para la Fila 1)
  line(xInicio, yCabecera, xInicio + anchoTotal, yCabecera);

  // Dibuja la línea DEBAJO DE LA FILA 1 (Crea el espacio para la Fila 2)
  line(xInicio, yCabecera + filaAltura, xInicio + anchoTotal, yCabecera + filaAltura);
  
  // ELIMINADO: Ya no necesitamos la tercera línea[cite: 22], 
  // porque el borde inferior del 'rect()' la dibuja.
  // line(xInicio, yCabecera + (2 * filaAltura), xInicio + anchoTotal, yCabecera + (2 * filaAltura));

  // Títulos de columnas
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("N°", xInicio + 10, yInicio + 20);
  text("Producto", col1 + 20, yInicio + 20);
  text("Cantidad", col2 + 20, yInicio + 20);

  // --- NUEVO: AÑADIR DATOS A LAS FILAS ---
  // (Asumo que tienes las variables 'stockActual1' y 'stockActual2'
  // de la implementación en tiempo real que hicimos antes)
  
  // Fila 1
  textAlign(CENTER, CENTER); // Centrar el N°
  text("1", xInicio + (col1 - xInicio) / 2, yCabecera + (filaAltura / 2));
  textAlign(LEFT, CENTER); // Alinear Producto a la izquierda
  text("Producto 1", col1 + 20, yCabecera + (filaAltura / 2));
  text(stockActual1, col2 + 20, yCabecera + (filaAltura / 2)); // Muestra el stock
  
  // Fila 2
  textAlign(CENTER, CENTER); // Centrar el N°
  text("2", xInicio + (col1 - xInicio) / 2, yCabecera + filaAltura + (filaAltura / 2));
  textAlign(LEFT, CENTER); // Alinear Producto a la izquierda
  text("Producto 2", col1 + 20, yCabecera + filaAltura + (filaAltura / 2));
  text(stockActual2, col2 + 20, yCabecera + filaAltura + (filaAltura / 2)); // Muestra el stock
  
  // --- FIN DE LOS DATOS ---

  // Botón Añadir
  fill(251, 251, 251);
  stroke(0);
  rect(width - 170, 150, 120, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Añadir", width - 110, 175);

  //BOTON VOLVER
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}

void stock() {
  int i;
  for (i=1; i<=2; i++) {
    fill(251, 251, 251);
    rect(rectX, rectY+(i*100), 130, 40);
  }
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
 
  text("1° Producto", rectX+12, rectY+(1*100)+25);
  text("2° Producto", rectX+12, rectY+(2*100)+25);
  text("Volver", 515, 325);
}


void pantallaIngresostock() {
  fill(0);
  textSize(20);
  text("Ingrese cantidad para Producto N° " + productoSeleccionado + ":", rectX, rectY);
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  fill(0);
  text(cantidadIngresada, rectX + 10, rectY + 70);
  textSize(16);

  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  text("Volver", 515, 325);
}


void seleccionarUsuarioSaldo() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Seleccione un usuario para cargar saldo:", 100, 50);

  
  if (nombres.isEmpty()) {
    fill(200, 0, 0); // Texto en rojo
    textAlign(CENTER, CENTER);
    textSize(18);
    text("No hay usuarios registrados.", width/2, 150);
    text("Vaya a la sección 'USUARIOS' para agregar uno.", width/2, 180);
  } else {
    // Dibuja la lista de usuarios
    for (int i = 0; i < nombres.size(); i++) {
      fill(251, 251, 251);
      stroke(0);
      int yBoton = 100 + (i * 40);
      rect(100, yBoton, 400, 35); // Botón más ancho
      
      fill(0);
      textAlign(LEFT, CENTER);
      textSize(16);
      text(nombres.get(i) + " (UID: " + uids.get(i) + ")", 110, yBoton + 17);
    }
  }

  
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", 565, 325);
}


void pantallaIngresosaldo() {
  fill(0);
  textSize(20);
  textAlign(LEFT, TOP);
  
  if (usuarioSeleccionadoParaSaldo != -1 && usuarioSeleccionadoParaSaldo < nombres.size()) {
    text("Ingrese saldo a cargar para: " + nombres.get(usuarioSeleccionadoParaSaldo), rectX, rectY);
  } else {
    text("Error: Usuario no seleccionado", rectX, rectY);
  }
  
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  fill(0);
  textAlign(LEFT, CENTER);
  text(cantidadIngresada, rectX + 10, rectY + 60);
  textSize(16);

  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("volver", 565, 325);
}

// ===============================================
// PANTALLA 5: VENTAS (Tabla de registrosEnMemoria)
// ===============================================
void archivo() {
  
  // --- CONFIGURACIÓN DE LA TABLA ---
  fill(255);
  int margen = 20;
  int cuadroX = margen;
  int cuadroY = margen;
  int cuadroAncho = width - 2 * margen;
  int cuadroAlto = height - 2 * margen;

  rect(cuadroX, cuadroY, cuadroAncho, cuadroAlto);

  // Define las columnas (6 como en tu imagen)
  int columnas = 6;
  float anchoCelda = float(cuadroAncho) / columnas;
  float altoCelda = 30;

  textSize(12);
  fill(0);
  textAlign(CENTER, CENTER);
  
  // Encabezados de la tabla
  text("Fecha y horario", cuadroX + anchoCelda/2, cuadroY + altoCelda/2);
  text("Metodo de pago", cuadroX + anchoCelda * 1.5, cuadroY + altoCelda/2);
  text("Resultado", cuadroX + anchoCelda * 2.5, cuadroY + altoCelda/2);
  text("N°Transaccion", cuadroX + anchoCelda * 3.5, cuadroY + altoCelda/2);
  text("Producto", cuadroX + anchoCelda * 4.5, cuadroY + altoCelda/2);
  text("Monto de Ventas", cuadroX + anchoCelda * 5.5, cuadroY + altoCelda/2);

  // Línea separadora de encabezado y líneas verticales
  line(cuadroX, cuadroY + altoCelda, cuadroX + cuadroAncho, cuadroY + altoCelda);
  for (int i = 1; i < columnas; i++) {
    float x = cuadroX + i * anchoCelda;
    line(x, cuadroY, x, cuadroY + cuadroAlto);
  }

  // --- MOSTRAR DATOS DE VENTA (REGISTROS EN MEMORIA) ---
      int y_inicio_datos = (int)(cuadroY + altoCelda);
  
  // Mostrar datos del más reciente al más antiguo (reversa)
  for (int i = registrosEnMemoria.size() - 1; i >= 0; i--) {
      float y_actual = y_inicio_datos + (registrosEnMemoria.size() - 1 - i) * altoCelda;
      
      if (y_actual + altoCelda > cuadroY + cuadroAlto) break; // Límite de la tabla

      String linea = registrosEnMemoria.get(i);
      String[] partes = split(linea, ','); // Fecha, Hora, Producto, Precio

      // Valores para las columnas no guardadas en el CSV (Metodo, Resultado, Transaccion)
      String metodoPago = "N/D";
      String resultado = "N/D";
      String nroTransaccion = "N/A";
      
      // Simulación: Si el Arduino envía estos datos, deberías procesarlos en serialEvent.
      // Por ahora, usamos valores genéricos y el último dígito del tiempo como NroTransacción
      metodoPago = (i % 2 == 0) ? "Tarjeta" : "Llavero";
      resultado = "Exitoso";
      nroTransaccion = String.valueOf(i + 1000); 
      
      String nombreProducto = partes.length >= 3 ? partes[2].substring(0, partes[2].indexOf('-')).trim() : "N/D";
      String precioVenta = partes.length >= 4 ? partes[3] : "N/D";

      line(cuadroX, y_actual, cuadroX + cuadroAncho, y_actual); 

      // Columna 1: Fecha y Hora
      if (partes.length >= 2) {
          textAlign(LEFT, CENTER);
          text(partes[0] + " " + partes[1], cuadroX + 5, y_actual + altoCelda/2);
      }
      // Columna 2: Metodo de pago 
      textAlign(CENTER, CENTER);
      text(metodoPago, cuadroX + anchoCelda * 1.5, y_actual + altoCelda/2);
      // Columna 3: Resultado
      text(resultado, cuadroX + anchoCelda * 2.5, y_actual + altoCelda/2);
      // Columna 4: N°Transaccion
      text(nroTransaccion, cuadroX + anchoCelda * 3.5, y_actual + altoCelda/2);
      // Columna 5: Producto
      text(nombreProducto, cuadroX + anchoCelda * 4.5, y_actual + altoCelda/2);
      // Columna 6: Monto de Ventas
      text(precioVenta, cuadroX + anchoCelda * 5.5, y_actual + altoCelda/2);
  }

  // Botón Volver
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}



void usuarios(){
  
  fill(0);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Administrar Usuarios registrados", width/2, 30);

// Cuadro grande (lista de usuarios)
fill(255);
stroke(0);
rect(100, 100, width - 300, height - 200);

// Líneas de columnas
int xInicio = 100;
int yInicio = 100;
int anchoTotal = width - 300;
int altoTotal = height - 200;

// Líneas verticales (columnas)
int col1 = xInicio + 30;     // N° 
int col2 = xInicio + 300;    // Nombre de usuario
int col3 = xInicio + 700;    // UID

line(col1, yInicio, col1, yInicio + altoTotal);
line(col2, yInicio, col2, yInicio + altoTotal);
line(col3, yInicio, col3, yInicio + altoTotal);

// Líneas horizontales (filas)
int filaAltura = 30;  // altura de cada fila
for (int y = yInicio + 40; y < yInicio + altoTotal; y += filaAltura) {
  line(xInicio, y, xInicio + anchoTotal, y);
}

// Títulos de columnas
fill(0);
textAlign(LEFT, CENTER);
textSize(16);
text("N°", xInicio + 10, yInicio + 20);
text("Nombre de usuario", col1 + 20, yInicio + 20);
text("UID", col2 + 20, yInicio + 20);

  // Botón Añadir
  fill(251, 251, 251);
  stroke(0);
  rect(width - 170, 150, 120, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Añadir", width - 110, 175);

  // Botón Eliminar
  fill(251, 251, 251);
  stroke(0);
  rect(width - 170, 220, 120, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Eliminar", width - 110, 245);
  
  // Mostrar cada usuario con su número
  for (int i = 0; i < nombres.size(); i++) {
    int y = 140 + i * 30;
    textAlign(LEFT, CENTER);
    text(str(i+1), xInicio + 10, y + 20);            // Número de orden
    text(nombres.get(i),col1 + 20, y + 20);       // Nombre
    text(uids.get(i), col2 + 20, y + 20);          // UID
    
  }
  

   //BOTON VOLVER
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}

void añadirusuario(){
  textSize(20);
  text("Ingrese nuevo nombre de usuario", rectX + 100, rectY);
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  fill(0);
  text(nombre, rectX + 80, rectY + 60);
  textSize(16);
  
  if(ingresaruid==1){
  textSize(20);
  text("Ingrese UID en formato hexadecimal", rectX + 500, rectY);
  fill(255);
  rect(rectX + 400, rectY + 40, 300, 40);
  fill(0);
  text(UID, rectX + 520, rectY + 60);
  textSize(16);
  }

//BOTON VOLVER
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}
void eliminarusuario(){
  
    fill(0);
    textAlign(LEFT, TOP);
    textSize(24);
    // Título/Instrucción
    text("Ingrese el N° de usuario a eliminar de la lista:", rectX, rectY);

    // Cuadro de entrada de texto (donde se ve 'indiceEliminar')
    fill(255);
    rect(rectX, rectY + 40, 100, 40);
    fill(0);
    textSize(20);
    textAlign(LEFT, CENTER);
    text(indiceEliminar, rectX + 10, rectY + 60);

    textSize(16);
    textAlign(LEFT, TOP);
    fill(100);
    text("Presione ENTER para confirmar.", rectX, rectY + 100);

  //BOTON VOLVER
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}





// ===============================================
// EVENTO SERIAL (LÓGICA FUSIONADA)
// ===============================================
void serialEvent(Serial p) {
  try {
    String entrada = p.readStringUntil('\n'); 
    
    if (entrada == null) return;
    
    entrada = entrada.trim();

    // 1. Lógica de REGISTRO DE VENTAS (Prioridad: Guardar en archivo y memoria)
    if (entrada.startsWith("Registro:")) {
      String datos = entrada.substring("Registro:".length());
      String[] partes = datos.split(":");
      
      if (partes.length == 2) {
        int idProducto = Integer.parseInt(partes[0].trim());
        int precio = Integer.parseInt(partes[1].trim());
        String nombreProducto = (idProducto >= 0 && idProducto < PRODUCTOS.length) ? PRODUCTOS[idProducto] : "ID Producto " + idProducto;
        
        // Genera la línea de registro completa antes de guardarla/añadirla a memoria
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd,HH:mm:ss");
        String fechaHora = dateFormat.format(new Date());
        String lineaRegistro = fechaHora + "," + nombreProducto + "," + precio;
        
        // 1.1. GUARDA EN EL ARCHIVO
        guardarRegistro(nombreProducto, precio); 
        
        // 1.2. AÑADE AL BUFFER EN MEMORIA (para la tabla VENTAS)
        registrosEnMemoria.add(lineaRegistro);
      }
      return; 
    }
    else if (entrada.startsWith("STOCK_UPDATE:")) {
      // Obtiene los datos (ej: "10:5")
      String datos = entrada.substring("STOCK_UPDATE:".length());
      String[] partes = split(datos, ':');
      
      if (partes.length == 2) {
        stockActual1 = int(partes[0]);
        stockActual2 = int(partes[1]);
        println("Stock actualizado: P1=" + stockActual1 + ", P2=" + stockActual2); // Para depuración
      }
      return; // Termina
    }
    // 2. Lógica de MENSAJES DE CONTROL/DISPLAY
    if (entrada.startsWith("Recibido") || entrada.length() == 0) {
       return; 
    }

    println("Mensaje Control: " + entrada);
    
    // Desplaza todos los mensajes hacia arriba (buffer circular)
    for (int i = 0; i < mensajes.length - 1; i++) {
      mensajes[i] = mensajes[i + 1];
    }

    // Guarda el nuevo mensaje en la última posición
    mensajes[mensajes.length - 1] = entrada;
    
  } catch (Exception e) {
    println("Error en serialEvent: " + e.getMessage());
  }
}
// ===============================================
// FUNCIÓN GUARDAR REGISTRO
// ===============================================

void guardarRegistro(String producto, int precio) {
  SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
  SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");

  Date ahora = new Date();
  String fecha = dateFormat.format(ahora);
  String hora = timeFormat.format(ahora);
  // Crea la línea de registro en formato CSV
  String lineaRegistro = fecha + "," + hora + "," + producto + "," + precio;
  
  // AQUÍ ESTÁ EL BLOQUE 'try' QUE FALTABA
  try {
    FileWriter fw = new FileWriter(dataPath(nombreArchivo), true);
    fw.write(lineaRegistro + "\n");
    fw.close(); 
    println("Registro guardado: " + lineaRegistro);
  }
  catch (IOException e) {
    println("Error al escribir en el archivo: " + e.getMessage());
  }
}

// ===============================================
// FUNCIÓN CARGAR ARCHIVO
// ===============================================

void cargarRegistrosVentas() {
  println("Intentando cargar registros históricos...");
  
  String[] registros = loadStrings(dataPath(nombreArchivo));
  
  // Limpia el registro actual en memoria antes de cargar el historial
  registrosEnMemoria.clear(); 
  
  if (registros == null || registros.length == 0) {
    println("🚫 Archivo de ventas vacío o no encontrado.");
    archivoCargado = true;
    return;
  }
  
  // Agrega cada línea del archivo al ArrayList de la sesión actual
  for (String linea : registros) {
    registrosEnMemoria.add(linea.trim());
  }
  
  println("✅ Registros históricos cargados: " + registrosEnMemoria.size() + " ventas.");
  archivoCargado = true;
}



// ===============================================
// FUNCIÓN CARGAR ARCHIVO
// ===============================================
void pantallaCargarArchivo() {
  fill(0);
  textSize(24);
  textAlign(CENTER, CENTER);
  
  if (!archivoCargado) {
    text("Cargando datos históricos, espere...", width/2, height/2 - 30);
    cargarRegistrosVentas();
    delay(1000); 
  }
  
  if (registrosEnMemoria.size() > 0) {
    text("✅ " + registrosEnMemoria.size() + " registros cargados con éxito.", width/2, height/2);
  } else {
    text("⚠️ Archivo de ventas vacío o no encontrado.", width/2, height/2);
  }
  
  // Vuelve al menú principal automáticamente
  delay(1500); 
  pantalla = 0;
  archivoCargado = false; // Permite recargar el archivo si el usuario vuelve a presionar el botón
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
      if (cantidadIngresada.length() > 0 && usuarioSeleccionadoParaSaldo != -1) {
        
        // Obtenemos la UID del usuario seleccionado
        String uid = uids.get(usuarioSeleccionadoParaSaldo);
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
  
      nombres.add(nombre);
      uids.add(UID);
      
    
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
    
    if (i >= 0 && i < uids.size()) {
      // Obtenemos la UID que vamos a eliminar
      String uidAEliminar = uids.get(i);
      // BORRAR localmente
      uids.remove(i);
      nombres.remove(i);
      
      // Enviar UID al Arduino para que la borre
      uidAEliminar = uidAEliminar.replace(" ", "").toUpperCase(); // limpieza por si acaso
      
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
