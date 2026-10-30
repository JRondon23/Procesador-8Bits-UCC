# ARCHIVOS "EX" (EXECUTION)

## EXPLICACIÓN

La carpeta "EX" contiene los archivos relacionados a la ALU.

Los encargados de modificar este archivo son los integrantes del equipo 2.

## Aclaración

Los archivos contenidos en esta carpetas son los modulos y el top level que
integra al resto de modulos. El archivo `ALU.sv` es el top level antes dicho,
que integra `mux_module.sv` y `ALU_module.sv`.

El modulo `mux_module.sv` que es un multiplexor de dos entradas de datos,
un selector y una salida de datos, que elige si la ALU opera con 2 registros o con
un registro y un inmediato.

El modulo `ALU_module.sv` es el encargado de elegir entre
todas las operaciones posibles y luego operar, este cuenta con 2 flags: **ZERO** y
**OVERFLOW**, las cuales se levantan cuando la resta da 0 y cuando el resultado de la
suma o de la resta, excede el máximo número representable por los 8 bits.
