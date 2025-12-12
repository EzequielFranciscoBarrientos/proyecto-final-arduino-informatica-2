// =================================================================================
// PESTAÑA: STOCK Y PRECIOS
// Funciones para visualizar stock, cambiar precios y guardar configuración
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. VISUALIZACIÓN: TABLA DE STOCK Y PRECIOS (Pantalla 10)
// ---------------------------------------------------------------------------------
void stockcuadro(){
  // --- Título ---
  fill(0);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Stock y Precio Actual", width/2, 30);

  // --- Definiciones de geometría de la tabla ---
  int xInicio = 100;
  int yInicio = 100;
  int anchoTotal = width - 350;
  
  // Columnas (Posición X)
  int col1 = xInicio + 30;
  int col2 = xInicio + 300;
  int col3 = xInicio + 450;
  
  // Filas (Alturas)
  int filaAltura = 30;
  int yCabecera = yInicio + 40;
  int altoTabla = (yCabecera - yInicio) + (2 * filaAltura);

  // --- DIBUJO DEL CUADRO ---
  fill(255);
  stroke(0);
  rect(xInicio, yInicio, anchoTotal, altoTabla); // Borde exterior

  // Líneas verticales (Separadores de columnas)
  line(col1, yInicio, col1, yInicio + altoTabla);
  line(col2, yInicio, col2, yInicio + altoTabla);
  line(col3, yInicio, col3, yInicio + altoTabla);

  // Líneas horizontales (Separadores de filas)
  line(xInicio, yCabecera, xInicio + anchoTotal, yCabecera);
  line(xInicio, yCabecera + filaAltura, xInicio + anchoTotal, yCabecera + filaAltura);

  // --- TEXTO DE CABECERAS ---
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("N°", xInicio + 10, yInicio + 20);
  text("Producto", col1 + 20, yInicio + 20);
  text("Cantidad", col2 + 20, yInicio + 20);
  text("Precio", col3 + 20, yInicio + 20);

  // --- CONTENIDO DE LAS FILAS (DATOS) ---
  
  // Fila 1: Producto 1
  textAlign(CENTER, CENTER);
  text("1", xInicio + (col1 - xInicio) / 2, yCabecera + (filaAltura / 2)); // N°
  textAlign(LEFT, CENTER);
  text("Producto 1", col1 + 20, yCabecera + (filaAltura / 2)); // Nombre
  textAlign(CENTER, CENTER);
  text(stockActual1, col2 + 20, yCabecera + (filaAltura / 2)); // Variable Stock
  text("$" + precioProd1, col3 + 25, yCabecera + (filaAltura / 2)); // Variable Precio

  // Fila 2: Producto 2
  textAlign(CENTER, CENTER);
  text("2", xInicio + (col1 - xInicio) / 2, yCabecera + filaAltura + (filaAltura / 2)); // N°
  textAlign(LEFT, CENTER);
  text("Producto 2", col1 + 20, yCabecera + filaAltura + (filaAltura / 2)); // Nombre
  textAlign(CENTER, CENTER);
  text(stockActual2, col2 + 20, yCabecera + filaAltura + (filaAltura / 2)); // Variable Stock
  text("$" + precioProd2, col3 + 25, yCabecera + filaAltura + (filaAltura / 2)); // Variable Precio
  
  // --- BOTONES DE ACCIÓN ---
  
  // Botón: Añadir Stock
  fill(251, 251, 251);
  stroke(0);
  rect(width - 220, 150, 180, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Añadir stock", width - 130, 175);

  // Botón: Cambiar Precio 
  fill(251, 251, 251); 
  stroke(0);
  rect(width - 220, 220, 180, 50);
  fill(0);
  text("Cambiar Precio", width - 130, 245);
  
  // Botón: Volver
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}

// ---------------------------------------------------------------------------------
// 2. MENÚS DE SELECCIÓN DE PRODUCTO
// ---------------------------------------------------------------------------------

// Pantalla para elegir a qué producto añadir stock (Pantalla 1)
void stock() {
  int i;
  for (i=1; i<=2; i++) {
    fill(251, 251, 251);
    rect(rectX, rectY+(i*100), 130, 40);
  }
  
  // Botón Volver
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  
  // Textos
  fill(0, 0, 0);
  textSize(20);
  text("1° Producto", rectX+60, rectY+(1*100)+25);
  text("2° Producto", rectX+60, rectY+(2*100)+25);
  text("Volver", 555, 325);
}

// Pantalla para elegir qué precio modificar (Pantalla 12)
void seleccionProductoPrecio() {
  fill(0);
  textSize(24);
  textAlign(CENTER, TOP);
  text("¿Qué precio desea modificar?", width/2, 50);

  // Botón Prod 1
  fill(251, 251, 251);
  rect(rectX, rectY + 100, 130, 40);
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Producto 1", rectX + 15, rectY + 120);

  // Botón Prod 2
  fill(251, 251, 251);
  rect(rectX, rectY + 200, 130, 40);
  fill(0);
  text("Producto 2", rectX + 15, rectY + 220);

  // Botón Cancelar
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Cancelar", 565, 325);
}

// ---------------------------------------------------------------------------------
// 3. PANTALLAS DE INGRESO DE DATOS (TECLADO)
// ---------------------------------------------------------------------------------

// Pantalla visual para escribir cantidad de Stock (Pantalla 2)
void pantallaIngresostock() {
  fill(0);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Ingrese cantidad para Producto N° " + productoSeleccionado + ":", rectX+80, rectY);
  
  // Caja de texto
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  
  // Mostrar lo que se escribe
  fill(0);
  textAlign(LEFT, CENTER);
  text(cantidadIngresada, rectX + 10, rectY + 70);
  textSize(16);

  // Botón Volver
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", 555, 325);
}

// Pantalla visual para escribir el nuevo Precio (Pantalla 11)
void pantallaIngresoPrecio() {
  fill(0);
  textSize(24);
  textAlign(LEFT, TOP);
  text("Ingrese NUEVO PRECIO para Producto " + productoSeleccionado + ":", rectX, rectY);
  
  // Caja de texto
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  
  // Mostrar lo que se escribe
  fill(0);
  text(cantidadIngresada, rectX + 10, rectY + 45);
  textSize(16);

  // Botón Cancelar
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Cancelar", 565, 325);
}

// ---------------------------------------------------------------------------------
// 4. PERSISTENCIA: GUARDAR Y CARGAR CONFIGURACIÓN
// ---------------------------------------------------------------------------------

// Guarda Stock y Precios en un archivo de texto (config_vending.txt)
void guardarConfiguracion() {
  // Formato CSV: Stock1,Stock2,Precio1,Precio2
  String linea = stockActual1 + "," + stockActual2 + "," + precioProd1 + "," + precioProd2;
  String[] lista = { linea };
  saveStrings(dataPath(archivoConfig), lista);
}

// Carga la configuración al iniciar y sincroniza con Arduino
void cargarConfiguracion() {
  File f = new File(dataPath(archivoConfig));
  if (!f.exists()) return; // Si no hay archivo, usar valores por defecto
  
  String[] lineas = loadStrings(dataPath(archivoConfig));
  if (lineas != null && lineas.length > 0) {
    String[] partes = split(lineas[0], ',');
    if (partes.length == 4) {
      // Asignar variables locales
      stockActual1 = int(partes[0]);
      stockActual2 = int(partes[1]);
      precioProd1 = int(partes[2]);
      precioProd2 = int(partes[3]);
      
      // SINCRONIZAR CON ARDUINO
      // Es importante enviar estos datos para que el Arduino sepa el estado guardado
      myPort.write("STOCK1:" + stockActual1 + "\n");
      delay(50);
      myPort.write("STOCK2:" + stockActual2 + "\n");
      delay(50);
      myPort.write("CAMBIAR_PRECIO:1:" + precioProd1 + "\n");
      delay(50);
      myPort.write("CAMBIAR_PRECIO:2:" + precioProd2 + "\n");
      
      println("Configuración restaurada.");
    }
  }
}
