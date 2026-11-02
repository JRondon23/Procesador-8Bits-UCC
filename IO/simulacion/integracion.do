transcript on
# Desde la raiz del repositorio: do IO/simulacion/integracion.do
# Usa los modulos originales de los grupos 1 y 3 que estan en DE/
onerror {quit -code 1 -f}
vlib work
vmap work work
vlog -sv IO/entrada.sv IO/salida.sv IO/bloqueIO.sv DE/Unidad_de_Control/unidad_control.sv DE/Banco-Mux/banco_mux.sv DE/Banco-Registros/banco_registros.sv IO/simulacion/integracion.sv
vsim -onfinish stop work.integracion
add wave *
run -all
