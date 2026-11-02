// bloque 5 entrada y salida
module bloqueIO (
    input logic clk, rst,
    input logic [3:0] dato_usuario,
    input logic boton,           
    input logic [3:0] opcode,
    input logic pe, od,
    input logic [7:0] dato_salida,
    output logic [7:0] dato_entrada,
    output logic dato_listo,
    output logic [7:0] leds
);
    logic habilitar, aceptar;

    // habilitar: la instruccion actual es IN
    // aceptar: en este flanco el banco guarda el byte y el PC avanza
    assign habilitar = (opcode == 4'b1000);
    assign aceptar = habilitar && dato_listo && pe;

    entrada recibe (
        .clk				(clk), 
		  .rst				(rst), 
		  .dato_usuario	(dato_usuario),
        .boton				(boton), 
		  .habilitar		(habilitar), 
		  .aceptar			(aceptar),
        .dato_entrada	(dato_entrada), 
		  .dato_listo		(dato_listo)
    );

    salida muestra (
        .clk				(clk), 
		  .rst				(rst), 
		  .od					(od),
        .dato_salida		(dato_salida), 
		  .leds				(leds)
    );
endmodule
