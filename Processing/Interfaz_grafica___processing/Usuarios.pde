// =================================================================================
// PESTAÑA: GESTIÓN DE USUARIOS
// Clase Usuario, interfaz de administración (CRUD) y persistencia
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. CLASE USUARIO (Estructura de Datos)
// ---------------------------------------------------------------------------------
class Usuario {
  String nombre;
  String uid;
  
  // Constructor
  Usuario(String nombre, String uid) {
    this.nombre = nombre;
    this.uid = uid;
  }
}

// ---------------------------------------------------------------------------------
// 2. INTERFAZ: LISTA DE USUARIOS (Pantalla 7)
// ---------------------------------------------------------------------------------
void usuarios(){
  
  fill(0);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Administrar Usuarios registrados", width/2, 30);
  
  // --- CONFIGURACIÓN DE TABLA ---
  fill(255);
  stroke(0);
  rect(100, 100, width - 300, height - 200); // Cuadro principal
  
  int xInicio = 100;
  int yInicio = 100;
  int anchoTotal = width - 300;
  int altoTotal = height - 200;

  // Definición de columnas X
  int col1 = xInicio + 30;    // Columna N°
  int col2 = xInicio + 300;   // Columna Nombre
  int col3 = xInicio + 700;   // Columna UID (fin)

  // Dibujo de líneas verticales
  line(col1, yInicio, col1, yInicio + altoTotal);
  line(col2, yInicio, col2, yInicio + altoTotal);
  line(col3, yInicio, col3, yInicio + altoTotal);
  
  // Dibujo de líneas horizontales (Grilla)
  int filaAltura = 30;
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
  
  // --- BOTONES LATERALES ---
  
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
  
  // --- MOSTRAR DATOS DE LA LISTA ---
  for (int i = 0; i < usuarios.size(); i++) {
    int y = 140 + i * 30;
    textAlign(LEFT, CENTER);
    text(str(i+1), xInicio + 10, y + 20);      // Número de orden
    text(usuarios.get(i).nombre, col1 + 20, y + 20); // Nombre
    text(usuarios.get(i).uid, col2 + 20, y + 20);    // UID
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
// 3. FORMULARIOS DE AÑADIR/ELIMINAR
// ---------------------------------------------------------------------------------

// Pantalla para añadir usuario (Nombre y luego UID)
void añadirusuario(){
  textSize(20);
  text("Ingrese nuevo nombre de usuario", rectX + 100, rectY);
  
  // Campo Nombre
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  fill(0);
  text(nombre, rectX + 80, rectY + 60);
  textSize(16);
  
  // Campo UID (Solo aparece si ya se dio Enter en nombre)
  if(ingresaruid == 1){
    textSize(20);
    text("Ingrese UID en formato hexadecimal", rectX + 500, rectY);
    fill(255);
    rect(rectX + 400, rectY + 40, 300, 40);
    fill(0);
    text(UID, rectX + 520, rectY + 60);
    textSize(16);
  }

  // Botón Volver
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}

// Pantalla para eliminar usuario por número de lista
void eliminarusuario(){
  fill(0);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Ingrese el N° de usuario a eliminar de la lista:", rectX, rectY);
  
  // Cuadro de entrada de texto
  fill(255);
  rect(rectX, rectY + 40, 100, 40);
  fill(0);
  textSize(20);
  textAlign(LEFT, CENTER);
  text(indiceEliminar, rectX + 10, rectY + 60);

  // Instrucciones
  textSize(16);
  textAlign(LEFT, TOP);
  fill(100);
  text("Presione ENTER para confirmar.", rectX, rectY + 100);

  // Botón Volver
  fill(251, 251, 251);
  rect(width - 150, height - 50, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", width - 85, height - 30);
}


// ---------------------------------------------------------------------------------
// 4. PERSISTENCIA DE USUARIOS (ARCHIVOS)
// ---------------------------------------------------------------------------------

// Guarda la lista de objetos Usuario en el archivo 'usuarios_db.txt'
void guardarUsuariosEnArchivo() {
  String[] lineas = new String[usuarios.size()];
  for (int i = 0; i < usuarios.size(); i++) {
    // Formato: Nombre,UID
    lineas[i] = usuarios.get(i).nombre + "," + usuarios.get(i).uid;
  }
  saveStrings(dataPath(archivoUsuarios), lineas);
}

// Carga usuarios desde el archivo y sincroniza las UIDs con Arduino
void cargarUsuariosDesdeArchivo() {
  File f = new File(dataPath(archivoUsuarios));
  if (!f.exists()) return; // Si no existe, no hace nada

  String[] lineas = loadStrings(dataPath(archivoUsuarios));
  usuarios.clear(); // Limpiamos la lista en memoria para evitar duplicados
  
  if (lineas != null) {
    for (String linea : lineas) {
      String[] partes = split(linea, ',');
      if (partes.length == 2) {
        String nombreCargado = partes[0];
        String uidCargado = partes[1];
        
        // 1. Añadir a la lista local de Processing
        usuarios.add(new Usuario(nombreCargado, uidCargado));
        
        // 2. SINCRONIZAR CON ARDUINO
        // Enviamos la UID al Arduino para que sepa que es válida
        myPort.write("UID:" + uidCargado + "\n");
        delay(100); // Pequeña pausa para no saturar el buffer serial del Arduino
      }
    }
    println("Usuarios cargados y sincronizados: " + usuarios.size());
  }
}
