# ARCHIVOS "ARQ" (ARQUITECTURA)

## EXPLICACIÓN

La carpeta "ARQ" contiene los archivos relacionados a las decisiones tomadas de la arquitectura, como lo puede ser el opcode, datapath, etc.

Los encargados de modificar estos archivos son todos los integrantes del repositorio.# Especificaciones y Condiciones del Datapath — Procesador de 8 Bits

## 1. Regla Principal de Registros

* **Restricción:** El registro de destino ($RD$) es siempre equivalente al registro de fuente $RM$ ($RD = RM$).
* **Justificación:** Es una condición necesaria de diseño para **ahorrar bits en la instrucción**. Al asumir que $RD$ y $RM$ comparten la misma dirección de registro, no se requieren campos de bits adicionales dedicados exclusivamente a $RD$, optimizando el espacio dentro de los 8 bits disponibles por instrucción.

---

## 2. Formatos de Instrucciones (8 bits)

Existen **5 formatos de instrucciones** estructurados de la siguiente manera:

| Tipo | Opcode | Campos / Distribución de Bits | Descripción / Registro |
| :--- | :--- | :--- | :--- |
| **1. Tipo R** | 4 bits (MSB) | 2 bits $RN$ \| 2 bits $RM$ (LSB) | Operaciones Aritmético-Lógicas entre registros. |
| **2. Tipo I** | 4 bits | 2 bits Inmediato \| 2 bits $RM$ | Operaciones con valor Inmediato corto. |
| **3. Tipo B** | 4 bits | 4 bits Address | Instrucciones de Salto / Branching. |
| **4. Tipo Movi**| 2 bits | 4 bits Inmediato \| 2 bits $RM$ ($RD$) | Carga de datos inmediatos más largos. |
| **5. Tipo I/O** | 4 bits | 2 bits Sin uso \| 2 bits $RD$ ($RM$) | Entrada / Salida de datos. |

---

## 3. Recursos del Hardware

* **Program Counter (PC):** Registro encargado de mantener la dirección de la instrucción actual.
* **Memoria de Instrucciones (Imem):** Almacena el código de ejecutable/instrucciones.
* **Banco de Registros:** Contiene los registros generales procesables.
* **ALU & ALU-OP:** Unidad Aritmético Lógica y su lógica de decodificación de operación.
* **Unidad de Control:** Genera las señales de control para la sincronización y ruta de datos.
* **Sign-Extend:** Módulo de extensión de signo para operaciones que utilizan inmediatos.

---

## 4. Interconexiones y Lógica de Control

### Multiplexores (3 en total):
1. **MUX de Escritura en Registro (Banco MUX):** Selecciona el origen del dato a escribir en $RD$ (entre `Input`, `Resultado ALU` o `Movi`).
2. **MUX del PC:** Selecciona la siguiente dirección del PC (entre `PC + 1` o `Address de Salto / Branch`).
3. **MUX de Entrada a la ALU:** Selecciona la segunda entrada para la ALU (entre el registro $RN$ o un valor enviado desde el `Sign-Extend`).

### Conexiones Especiales y Banderas:
* **Transmission Gate / Switch:** Componente dedicado para el control del `Output`.
* **Banderas de Control:** Todos los módulos que requieran señales/banderas de control deben instanciar directamente a la **Unidad de Control**.

---

## 5. Distribución de Trabajo por Equipos

| Equipo / Integrantes | Módulos y Responsabilidades Asignadas |
| :--- | :--- |
| **Bautista, Sánchez, Tavia** | PC, Memoria de Instrucciones (Imem), Transmission Gate, Asignación de Pines, Sumador $PC + 1$, MUX del PC. |
| **Lucio, Bergia** | Banco de Registros, Módulo Sign-Extend, MUX de Escritura en Banco de Registros. |
| **Maggi, Ludueña** | ALU, ALU-OP, MUX de entrada a la ALU. |
| **Garelli, Rondón** | Unidad de Control *(Representado en color azul en el esquema del datapath)*. |