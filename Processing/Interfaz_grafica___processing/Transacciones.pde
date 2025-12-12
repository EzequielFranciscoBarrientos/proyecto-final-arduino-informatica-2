// =================================================================================
// PESTAÑA: TRANSACCIONES
// Visualización y guardado de historial de ventas
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. DIBUJO DE LA TABLA DE VENTAS (Pantalla 5)
// ---------------------------------------------------------------------------------
void archivo() {
  
  // --- CONFIGURACIÓN DE LA TABLA ---
  fill(255);
  int margen = 20;
  int cuadroX = margen;
  int cuadroY = margen;
  int cuadroAncho = width - 2 * margen;
  int cuadroAlto = height - 2 * margen;

  // Fondo del cuadro
  rect(cuadroX, cuadroY, cuadroAncho, cuadroAlto);

  // Definición de columnas
  int columnas = 4;
  float anchoCelda = float(cuadroAncho) / columnas;
  float altoCelda = 30;

  // --- CABECERAS ---
  textSize(12);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Fecha y horario", cuadroX + anchoCelda/2, cuadroY + altoCelda/2);
  text("N°Transaccion", cuadroX + anchoCelda * 1.5, cuadroY + altoCelda/2);
  text("Producto", cuadroX + anchoCelda * 2.5, cuadroY + altoCelda/2);
  text("Monto de Ventas", cuadroX + anchoCelda * 3.5, cuadroY + altoCelda/2);

  // Línea separadora de cabecera
  line(cuadroX, cuadroY + altoCelda, cuadroX + cuadroAncho, cuadroY + altoCelda);
  
  // Líneas verticales separadoras de columnas
  for (int i = 1; i < columnas; i++) {
    float x = cuadroX + i * anchoCelda;
    line(x, cuadroY, x, cuadroY + cuadroAlto);
  }

  // --- DIBUJADO DE DATOS (Iterando sobre registrosEnMemoria) ---
  int y_inicio_datos = (int)(cuadroY + altoCelda);
  
  // Recorremos la lista de atrás hacia adelante (lo más nuevo arriba)
  for (int i = registrosEnMemoria.size() - 1; i >= 0; i--) {
      float y_actual = y_inicio_datos + (registrosEnMemoria.size() - 1 - i) * altoCelda;
      
      if (y_actual + altoCelda > cuadroY + cuadroAlto) break; // Parar si nos salimos del cuadro

      String linea = registrosEnMemoria.get(i);
      String[] partes = split(linea, ','); 
      
      // Parseo de datos para mostrar
      String nroTransaccion = String.valueOf(i + 1000); // Generación ID ficticio
      String nombreProducto = partes.length >= 3 ? partes[2].substring(0, partes[2].indexOf('-')).trim() : "N/D";
      String precioVenta = partes.length >= 4 ? partes[3] : "N/D";

      // Línea horizontal de fila
      line(cuadroX, y_actual, cuadroX + cuadroAncho, y_actual);
      
      // Mostrar Fecha y Hora (partes 0 y 1)
      if (partes.length >= 2) {
          textAlign(LEFT, CENTER);
          text(partes[0] + " " + partes[1], cuadroX + 5, y_actual + altoCelda/2);
      }
      
      // Mostrar resto de columnas
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


// ---------------------------------------------------------------------------------
// 2. FUNCIÓN DE GUARDADO EN ARCHIVO (CSV)
// ---------------------------------------------------------------------------------

// Agrega una nueva línea al archivo de texto 'registro_ventas.txt'
void guardarRegistro(String producto, int precio) {
  // Formateadores de fecha y hora
  SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
  SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");

  Date ahora = new Date();
  String fecha = dateFormat.format(ahora);
  String hora = timeFormat.format(ahora);
  
  // Crea la línea de registro en formato CSV: FECHA,HORA,PRODUCTO,PRECIO
  String lineaRegistro = fecha + "," + hora + "," + producto + "," + precio;
  
  try {
    // FileWriter con 'true' habilita el modo 'append' (agregar al final sin borrar)
    FileWriter fw = new FileWriter(dataPath(nombreArchivo), true);
    fw.write(lineaRegistro + "\n");
    fw.close(); 
    println("Registro guardado: " + lineaRegistro);
  }
  catch (IOException e) {
    println("Error al escribir en el archivo: " + e.getMessage());
  }
}
