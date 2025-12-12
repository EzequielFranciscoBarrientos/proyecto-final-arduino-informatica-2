<!--<em>  MÁQUINA EXPENDEDORA </em>!-->
# Máquina Expendedora - Trabajo Final Informática II

## 📋 Descripción
Este proyecto consiste en el desarrollo de un prototipo de máquina expendedora automatizada. El sistema simula un proceso de venta completo utilizando tecnología RFID para la validación de usuarios y una interfaz gráfica en PC para la administración del sistema.

El objetivo principal es integrar hardware y software para lograr un control eficiente de stock, saldo y usuarios en tiempo real.

## 🏫 Institución
**Universidad Tecnológica Nacional - Facultad Regional Mendoza**
* **Cátedra:** Informática II
* **Carrera:** Ingeniería en Electrónica
* **Docentes:** Ing. Marcelo Ledda, Ing. Ana Laura Diedrichs, Ing. Mauricio Ponzo.

### 👥 Autores
* **Barrientos Ezequiel**
* **Bazzali Melania**
* **Ibarra Francisco**

---

## ⚙️ Arquitectura del Sistema
El funcionamiento se distribuye en tres módulos principales:

1.  **Interfaz de Gestión (Processing):** Aplicación de escritorio que permite al administrador dar de alta usuarios, cargar saldo, controlar el stock y visualizar el historial de transacciones.
2.  **Arduino Controlador (Principal):** Gestiona la lógica de negocio, valida las tarjetas RFID, controla los motores de despacho y mantiene la comunicación serial con la PC.
3.  **Arduino de Interfaz (UI):** Controla la interacción directa con el cliente mediante un teclado matricial para la selección de productos y una pantalla LCD para mensajes de estado.

### Diagrama de Conexiones
![Esquemático del Circuito](img/esquematico.png)

---

## 🛠️ Hardware y Materiales
Componentes utilizados para el montaje del prototipo:

* 2 x Placas Arduino Uno
* 1 x Módulo Lector RFID RC522
* 1 x Pantalla LCD 16x2 (con módulo I2C)
* 1 x Teclado Matricial 4x4
* 1 x Driver de Motores (L293D o equivalente)
* 2 x Motores de Corriente Continua
* Fuente de alimentación externa
* Protoboard y cableado

## 💻 Software
El proyecto utiliza Programación Orientada a Objetos (POO) y comunicación serial.

* **Arduino:** Librerías para el manejo de periféricos (`MFRC522`, `LiquidCrystal_I2C`, `Keypad`) y comunicación entre placas (`SoftwareSerial`).
* **Processing:** Librerías de comunicación serial (`processing.serial`) y manejo de archivos para el registro de datos.

---

## 🚀 Puesta en Marcha
1.  **Conexiones:** Realizar el montaje electrónico según el diagrama esquemático adjunto.
2.  **Carga de Firmware:** Subir los códigos correspondientes al Arduino Controlador y al Arduino UI.
3.  **Interfaz PC:** Ejecutar la aplicación en Processing asegurando la conexión al puerto COM correcto.
4.  **Uso:** Utilizar la interfaz para cargar saldo a una tarjeta y probar la compra seleccionando un producto en el teclado físico.
