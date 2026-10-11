# Trabajo Práctico Integrador: Procesador de 8 bits

**Universidad Católica de Córdoba (UCC)**  
**Materia:** Microelectrónica I (Microelectrónica Digital)  
**Año:** 2026  

Este repositorio contiene los archivos de código fuente en **SystemVerilog**, *testbenches* y scripts de simulación para el diseño e implementación de un procesador de 8 bits. Este proyecto es desarrollado de manera colaborativa por todos los grupos del curso, donde cada equipo es responsable del diseño, verificación e implementación en FPGA (DE0-Nano) de un bloque funcional específico.

---

## 📋 Asignación de Grupos y Bloques

El procesador está compuesto por 5 bloques fundamentales. El sistema es indivisible y requiere de la integración exitosa de todos los módulos para su funcionamiento.

| Grupo | Integrantes | Bloque Asignado | Dependencias Principales |
| :---: | :--- | :--- | :--- |
| **1** | Rondon - Garelli | **Unidad de Control** | Opcode, Flags |
| **2** | Maggi - Ludueña | **Unidad Aritmético-Lógica (ALU)** | Operandos, Selector ALU |
| **3** | Lucio - Bergia | **Banco de Registros** | Resultado ALU, Control, Entrada |
| **4** | *(A definir)* | **Memoria y Contador de Programa** | Salto, Flags |
| **5** | *(A definir)* | **Entrada / Salida** | Datos, Señales de Control |

---

## 📁 Estructura del repositorio

El repositorio está dividido en carpetas para simplificar la ubicación del trabajo de cada uno de los grupos. Las carpetas están conforme al nombre de un procesador con pipeline, sin embargo, no tomar como arquitectura del procesador, es simplemente a modo de simplificar identificadores.

-   **Carpeta DE:** Archivos destinados a la etapa "DECODE"
-   **Carpeta EX:** Archivos destinado a la etapa "EXECUTION"
-   **Carpeta IF:** Archivos destinado a la etapa "INSTRUCTION FETCH"
-   **Carpeta IO:** Archivos destinado a la etapa "INPUT/OUTPUT"

---

## ⚙️ Especificaciones Generales del Sistema

Los siguientes parámetros arquitectónicos son comunes a todos los módulos y definen la interfaz global del procesador:

-   **Arquitectura:** Se decidió utilizar una arquitectura **MONOCICLO**.
-   **Ancho de datos:** 8 bits (operandos y resultados).
-   **Ancho de direcciones:** 4 bits (16 posiciones de memoria de programa).
-   **Registros:** 4 registros de propósito general de 8 bits (direccionables con 2 bits).
-   **Reloj del sistema:** Derivado del reloj de 50 MHz de la placa FPGA DE0-Nano.
-   **Selector de la ALU:** 3 bits (permite hasta 8 operaciones distintas).
-   **Reset:** Sincrónico y activo en alto, común a todos los bloques.

---

## 🧩 Descripción de los Bloques (Scope: SystemVerilog)

### 1. Unidad de Control
Máquina de estados finita que dicta el ritmo del procesador (búsqueda, decodificación y ejecución). Emite las señales de control para todos los módulos y gestiona los saltos condicionales basados en los flags de la ALU.

### 2. Unidad Aritmético-Lógica (ALU)
Bloque puramente combinacional. Ejecuta operaciones aritméticas (suma, resta), lógicas y de comparación sobre dos operandos de 8 bits. Genera los flags de estado (`Zero`, `Carry`, `Negativo`) en el mismo ciclo.

### 3. Banco de Registros
Almacena los 4 registros de trabajo. Permite la lectura combinacional simultánea de dos registros y la escritura sincrónica de un tercero durante el mismo ciclo de reloj. 

### 4. Memoria de Programa y Contador (PC)
Memoria ROM (cargada en tiempo de síntesis) que almacena las instrucciones. Incluye el Program Counter (PC) que se incrementa secuencialmente o se carga con una nueva dirección en caso de saltos.

### 5. Entrada / Salida (I/O)
Interfaz con el exterior utilizando los recursos de la FPGA DE0-Nano (switches, botones y LEDs). Incluye sincronizadores anti-rebote para las entradas físicas y registros de mantenimiento para la visualización de datos.

---

## 🛠️ Herramientas y Flujo de Trabajo

-   **Lenguaje de Descripción de Hardware:** SystemVerilog (IEEE 1800)
-   **Simulación y Verificación:** Siemens EDA Questa / ModelSim
-   **Síntesis e Implementación:** Intel Quartus Prime
-   **Hardware de Destino:** Terasic DE0-Nano (Intel Cyclone IV FPGA)

*Nota: Por el momento, el alcance de este repositorio se limita exclusivamente a la etapa de diseño digital (RTL) y verificación funcional. La fase de layout físico no está incluida en esta etapa del proyecto.*