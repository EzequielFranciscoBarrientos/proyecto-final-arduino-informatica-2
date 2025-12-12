// =================================================================================
// PESTAÑA: CARGAR SALDO
// Selección de usuario y envío de créditos al sistema
// =================================================================================

// ---------------------------------------------------------------------------------
// 1. SELECCIÓN DE USUARIO (Pantalla 3)
// ---------------------------------------------------------------------------------
void seleccionarUsuarioSaldo() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Seleccione un usuario para cargar saldo:", 100, 50);

  // Verificación de lista vacía
  if (usuarios.isEmpty()) { 
    fill(200, 0, 0); // Texto rojo de error
    textAlign(CENTER, CENTER);
    textSize(18);
    text("No hay usuarios registrados.", width/2, 150);
    text("Vaya a la sección 'USUARIOS' para agregar uno.", width/2, 180);
  } else {
    // Dibujar lista dinámica de botones
    for (int i = 0; i < usuarios.size(); i++) {
      fill(251, 251, 251);
      stroke(0);
      int yBoton = 100 + (i * 40);
      rect(100, yBoton, 400, 35); // Rectángulo del botón
      
      fill(0);
      textAlign(LEFT, CENTER);
      textSize(16);
      // Muestra Nombre y UID
      text(usuarios.get(i).nombre + " (UID: " + usuarios.get(i).uid + ")", 110, yBoton + 17);
    }
  }
  
  // Botón Volver
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Volver", 565, 325);
}

// ---------------------------------------------------------------------------------
// 2. INGRESO DE MONTO (Pantalla 4)
// ---------------------------------------------------------------------------------
void pantallaIngresosaldo() {
  fill(0);
  textSize(20);
  textAlign(LEFT, TOP);
  
  // Validación de seguridad: asegurarse que hay usuario seleccionado
  if (usuarioSeleccionadoParaSaldo != -1 && usuarioSeleccionadoParaSaldo < usuarios.size()) {
    text("Ingrese saldo a cargar para: " + usuarios.get(usuarioSeleccionadoParaSaldo).nombre, rectX, rectY);
  } else {
    text("Error: Usuario no seleccionado", rectX, rectY);
  }
  
  // Caja de texto
  fill(255);
  rect(rectX, rectY + 40, 200, 40);
  
  // Texto ingresado (cantidad)
  fill(0);
  textAlign(LEFT, CENTER);
  text(cantidadIngresada, rectX + 10, rectY + 60);
  textSize(16);

  // Botón Volver
  fill(251, 251, 251);
  rect(500, 300, 130, 40);
  fill(0, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("volver", 565, 325);
}
