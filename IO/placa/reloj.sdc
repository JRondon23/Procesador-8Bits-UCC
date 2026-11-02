create_clock -name reloj_50mhz -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
# Las entradas fisicas son asincronas: solo se excluye el primer FF.
set_false_path -from [get_ports {SW[*]}] -to [get_registers {*recibe*dato_etapa1*}]
set_false_path -from [get_ports {KEY[1]}] -to [get_registers {*recibe*boton_etapa1}]
set_false_path -from [get_ports {KEY[0]}] -to [get_registers {*reset_etapa1}]
# Los LEDs no tienen un receptor sincrono externo.
set_false_path -to [get_ports {LED[*]}]
