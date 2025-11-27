
// ===============================================
// CLASE USUARIO (AÑADIDA)
// ===============================================
class Usuario {
  String nombre;
  String uid;

  // Constructor
  Usuario(String nombre, String uid) {
    this.nombre = nombre;
    this.uid = uid;
  }
}

// ===============================================
// PANTALLAS
// ===============================================

//--------------------------------
//FUNCIONES CARGAR SALDO
//------------------------------------

//Selecciona el usuario para agregar saldo
void seleccionarUsuarioSaldo() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Seleccione un usuario para cargar saldo:", 100, 50);

  
  if (usuarios.isEmpty()) { // 🔄 CAMBIO: Uso de usuarios.isEmpty()
    fill(200, 0, 0);
// Texto en rojo
    textAlign(CENTER, CENTER);
    textSize(18);
    text("No hay usuarios registrados.", width/2, 150);
    text("Vaya a la sección 'USUARIOS' para agregar uno.", width/2, 180);
  } else {
    // Dibuja la lista de usuarios
// 🔄 CAMBIO: Uso de usuarios.size()
    for (int i = 0; i < usuarios.size(); i++) {
      fill(251, 251, 251);
      stroke(0);
      int yBoton = 100 + (i * 40);
      rect(100, yBoton, 400, 35);
// Botón más ancho
      
      fill(0);
      textAlign(LEFT, CENTER);
      textSize(16);
// 🔄 CAMBIO: Acceso a las propiedades del objeto Usuario
      text(usuarios.get(i).nombre + " (UID: " + usuarios.get(i).uid + ")", 110, yBoton + 17);
    }
  }

  
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", 565, 325);
}

//Ingresar cantidad de saldo
void pantallaIngresosaldo() {
  fill(0);
  textSize(20);
  textAlign(LEFT, TOP);
// 🔄 CAMBIO: Acceso a la propiedad 'nombre' del objeto Usuario
  if (usuarioSeleccionadoParaSaldo != -1 && usuarioSeleccionadoParaSaldo < usuarios.size()) {
    text("Ingrese saldo a cargar para: " + usuarios.get(usuarioSeleccionadoParaSaldo).nombre, rectX, rectY);
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


//---------------------------------------
//FUNCIONES STOCK
//---------------------------------------

//Administración de stock (lista)
void stockcuadro(){
  fill(0);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Stock Actual", width/2, 30);

  // Definiciones de la tabla
  int xInicio = 100;
  int yInicio = 100;
  int anchoTotal = width - 300;
  // int altoTotal = height - 200;
// ELIMINADO: Ya no usamos la altura total de la pantalla
  
  // Definición de columnas
  int col1 = xInicio + 30;
// N° 
  int col2 = xInicio + 300;    // Producto
  // int col3 = xInicio + 700;


  // Definición de filas
  int filaAltura = 30;
// altura de cada fila
  int yCabecera = yInicio + 40;
// Esto es y = 140 (línea bajo el título)

  // CAMBIO: Calcular la altura EXACTA para Header (40px) + 2 filas (30px c/u)
  int altoTabla = (yCabecera - yInicio) + (2 * filaAltura);
// 40 + (2 * 30) = 100px
  
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
  textAlign(CENTER, CENTER);
// Centrar el N°
  text("1", xInicio + (col1 - xInicio) / 2, yCabecera + (filaAltura / 2));
  textAlign(LEFT, CENTER);
// Alinear Producto a la izquierda
  text("Producto 1", col1 + 20, yCabecera + (filaAltura / 2));
  text(stockActual1, col2 + 20, yCabecera + (filaAltura / 2)); // Muestra el stock
  
  // Fila 2
  textAlign(CENTER, CENTER);
// Centrar el N°
  text("2", xInicio + (col1 - xInicio) / 2, yCabecera + filaAltura + (filaAltura / 2));
  textAlign(LEFT, CENTER); // Alinear Producto a la izquierda
  text("Producto 2", col1 + 20, yCabecera + filaAltura + (filaAltura / 2));
  text(stockActual2, col2 + 20, yCabecera + filaAltura + (filaAltura / 2));
// Muestra el stock
  
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

//Elejir producto a añadir
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
 
  text("1° Producto", rectX+60, rectY+(1*100)+25);
  text("2° Producto", rectX+60, rectY+(2*100)+25);
  text("Volver", 555, 325);
}

//Elejir cantidad de producto a añadir
void pantallaIngresostock() {
  fill(0);
  textSize(20);
  text("Ingrese cantidad para Producto N° " + productoSeleccionado + ":", rectX+80, rectY);
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  fill(0);
  text(cantidadIngresada, rectX + 10, rectY + 70);
  textSize(16);

  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  text("Volver", 555, 325);
}



void archivo() {
  
  // --- CONFIGURACIÓN DE LA TABLA ---
  fill(255);
  int margen = 20;
  int cuadroX = margen;
  int cuadroY = margen;
  int cuadroAncho = width - 2 * margen;
  int cuadroAlto = height - 2 * margen;

  rect(cuadroX, cuadroY, cuadroAncho, cuadroAlto);

  int columnas = 4; 
  float anchoCelda = float(cuadroAncho) / columnas;
  float altoCelda = 30;

  textSize(12);
  fill(0);
  textAlign(CENTER, CENTER);
  
  
  text("Fecha y horario", cuadroX + anchoCelda/2, cuadroY + altoCelda/2);
  text("N°Transaccion", cuadroX + anchoCelda * 1.5, cuadroY + altoCelda/2); // Col 2
  text("Producto", cuadroX + anchoCelda * 2.5, cuadroY + altoCelda/2); // Col 3
  text("Monto de Ventas", cuadroX + anchoCelda * 3.5, cuadroY + altoCelda/2); // Col 4

  line(cuadroX, cuadroY + altoCelda, cuadroX + cuadroAncho, cuadroY + altoCelda);
  for (int i = 1; i < columnas; i++) {
    float x = cuadroX + i * anchoCelda;
    line(x, cuadroY, x, cuadroY + cuadroAlto);
  }

  
      int y_inicio_datos = (int)(cuadroY + altoCelda);

  for (int i = registrosEnMemoria.size() - 1; i >= 0; i--) {
      float y_actual = y_inicio_datos + (registrosEnMemoria.size() - 1 - i) * altoCelda;
      if (y_actual + altoCelda > cuadroY + cuadroAlto) break; // Límite de la tabla

      String linea = registrosEnMemoria.get(i);
      String[] partes = split(linea, ','); 
      String nroTransaccion = String.valueOf(i + 1000); 
      
      String nombreProducto = partes.length >= 3 ?
      partes[2].substring(0, partes[2].indexOf('-')).trim() : "N/D";
      String precioVenta = partes.length >= 4 ? partes[3] : "N/D";

      line(cuadroX, y_actual, cuadroX + cuadroAncho, y_actual);

      if (partes.length >= 2) {
          textAlign(LEFT, CENTER);
          text(partes[0] + " " + partes[1], cuadroX + 5, y_actual + altoCelda/2);
      }
      textAlign(CENTER, CENTER);
      text(nroTransaccion, cuadroX + anchoCelda * 1.5, y_actual + altoCelda/2);
      text(nombreProducto, cuadroX + anchoCelda * 2.5, y_actual + altoCelda/2);
      text(precioVenta, cuadroX + anchoCelda * 3.5, y_actual + altoCelda/2);
    }

  // Botón Volver
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}


//----------------------------------------
//FUNCIONES ARCHIVO
//---------------------------------


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



//Pantalla para cargar archivo
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
  archivoCargado = false;
// Permite recargar el archivo si el usuario vuelve a presionar el botón
}



// EVENTO SERIAL (LÓGICA FUSIONADA)

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
        String nombreProducto = (idProducto >= 0 && idProducto < PRODUCTOS.length) ?
        PRODUCTOS[idProducto] : "ID Producto " + idProducto;
        
        // Genera la línea de registro completa antes de guardarla/añadirla a memoria
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd,HH:mm:ss");
        String fechaHora = dateFormat.format(new Date());
        String lineaRegistro = fechaHora + "," + nombreProducto + "," + precio;
        
        // 1.1.
// GUARDA EN EL ARCHIVO
        guardarRegistro(nombreProducto, precio); 
        
        // 1.2.
// AÑADE AL BUFFER EN MEMORIA (para la tabla VENTAS)
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
        println("Stock actualizado: P1=" + stockActual1 + ", P2=" + stockActual2);
// Para depuración
      }
      return;
// Termina
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





//-------------------------------------------------------
//FUNCIONES USUARIOS
//----------------------------------------------------

//Lista de usuarios
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
int col1 = xInicio + 30;
// N° 
int col2 = xInicio + 300;    // Nombre de usuario
int col3 = xInicio + 700;
// UID

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
//  CAMBIO: Uso de usuarios.size()
  for (int i = 0; i < usuarios.size(); i++) {
    int y = 140 + i * 30;
//  CAMBIO: Acceso a las propiedades del objeto Usuario
    textAlign(LEFT, CENTER);
    text(str(i+1), xInicio + 10, y + 20);            // Número de orden
    text(usuarios.get(i).nombre, col1 + 20, y + 20); // Nombre
    text(usuarios.get(i).uid, col2 + 20, y + 20);    // UID
    
  }
  

   //BOTON VOLVER
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}
//Menu para añadir usuario en el cual se ingresa nombre y UID
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

//Eliminar usuario ingresando posicion que ocupa en la lista
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
