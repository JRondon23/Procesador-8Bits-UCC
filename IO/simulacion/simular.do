transcript on
# Desde la raiz del repositorio: do IO/simulacion/simular.do
onerror {quit -code 1 -f}
vlib work
vmap work work
vlog -sv IO/entrada.sv IO/salida.sv IO/bloqueIO.sv IO/placa/placa.sv IO/simulacion/pruebas.sv IO/simulacion/ensayo.sv
vsim -onfinish stop work.pruebas
add wave *
run -all
