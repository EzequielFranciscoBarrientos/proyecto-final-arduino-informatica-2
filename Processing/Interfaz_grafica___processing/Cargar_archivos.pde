// =================================================================================
// PESTAÑA: CARGA DE ARCHIVOS Y COMUNICACIÓN SERIAL
// Manejo de lectura de históricos y recepción de datos desde Arduino
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. CARGA DE REGISTROS HISTÓRICOS (Lectura de archivo)
// ---------------------------------------------------------------------------------

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

// Pantalla de carga (Pantalla 6)
void pantallaCargarArchivo() {
  fill(0);
  textSize(24);
  textAlign(CENTER, CENTER);
  
  // Ejecuta la carga si no se ha hecho
  if (!archivoCargado) {
    text("Cargando datos históricos, espere...", width/2, height/2 - 30);
    cargarRegistrosVentas();
    delay(1000); // Pausa para feedback visual
  }
  
  // Muestra resultado
  if (registrosEnMemoria.size() > 0) {
    text("✅ " + registrosEnMemoria.size() + " registros cargados con éxito.", width/2, height/2);
  } else {
    text("⚠️ Archivo de ventas vacío o no encontrado.", width/2, height/2);
  }
  
  // Vuelve al menú principal automáticamente
  delay(1500); 
  pantalla = 0;
  archivoCargado = false; // Reset para permitir recargar en el futuro
}


// ---------------------------------------------------------------------------------
// 2. EVENTO SERIAL (COMUNICACIÓN CON ARDUINO)
// Esta función se ejecuta automáticamente cuando llega un dato por el puerto Serial
// ---------------------------------------------------------------------------------

void serialEvent(Serial p) {
  try {
    String entrada = p.readStringUntil('\n'); // Leer hasta salto de línea
    if (entrada == null) return;
    
    entrada = entrada.trim(); // Limpiar espacios en blanco

    // CASO A: REGISTRO DE VENTA RECIBIDO
    // Formato esperado: "Registro:ID_PRODUCTO:PRECIO"
    if (entrada.startsWith("Registro:")) {
      String datos = entrada.substring("Registro:".length());
      String[] partes = datos.split(":");
      
      if (partes.length == 2) {
        int idProducto = Integer.parseInt(partes[0].trim());
        int precio = Integer.parseInt(partes[1].trim());
        
        // Buscar nombre legible del producto
        String[] listaActual = obtenerNombresProductos();
        String nombreProducto = (idProducto >= 0 && idProducto < listaActual.length) ?
                                listaActual[idProducto] : "ID Producto " + idProducto;
        
        // Generar Timestamp
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd,HH:mm:ss");
        String fechaHora = dateFormat.format(new Date());
        String lineaRegistro = fechaHora + "," + nombreProducto + "," + precio;
        
        // 1. Guardar en disco duro
        guardarRegistro(nombreProducto, precio);
        
        // 2. Añadir a la memoria RAM (para mostrar en tabla inmediatamente)
        registrosEnMemoria.add(lineaRegistro);
      }
      return; 
    }
    
    // CASO B: ACTUALIZACIÓN DE STOCK DESDE ARDUINO
    // Formato esperado: "STOCK_UPDATE:CANTIDAD1:CANTIDAD2"
    else if (entrada.startsWith("STOCK_UPDATE:")) {
      String datos = entrada.substring("STOCK_UPDATE:".length());
      String[] partes = split(datos, ':');
      
      if (partes.length == 2) {
        stockActual1 = int(partes[0]);
        stockActual2 = int(partes[1]);
        println("Stock actualizado: P1=" + stockActual1 + ", P2=" + stockActual2);
        
        // Guardar configuración nueva para persistencia
        guardarConfiguracion();
      }
      return;
    }
    
    // CASO C: MENSAJES DE CONTROL/DISPLAY (Ignorar ACK o vacíos)
    if (entrada.startsWith("Recibido") || entrada.length() == 0) {
       return;
    }

    // Guardar otros mensajes en buffer de debug
    println("Mensaje Control: " + entrada);
    
    // Desplaza buffer circular de mensajes
    for (int i = 0; i < mensajes.length - 1; i++) {
      mensajes[i] = mensajes[i + 1];
    }
    mensajes[mensajes.length - 1] = entrada;
    
  } catch (Exception e) {
    println("Error en serialEvent: " + e.getMessage());
  }
}
