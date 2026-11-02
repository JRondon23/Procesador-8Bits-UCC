`timescale 1ns/1ps
module tb_memoria_programa;
    logic [3:0] direccion;
    logic [7:0] instruccion;

    // NativeLink inicia Questa desde simulation/questa.
    memoria_programa #(.ARCHIVO("../../programa.mem")) dut (
        .direccion(direccion), .instruccion(instruccion)
    );

    initial begin
        direccion = 0; #1;
        if (instruccion !== 8'hC4) $fatal(1, "Fallo lectura 0");
        direccion = 1; #1;
        if (instruccion !== 8'h81) $fatal(1, "Fallo lectura 1");
        direccion = 4; #1;
        if (instruccion !== 8'hB6) $fatal(1, "Fallo lectura 4");
        direccion = 7; #1;
        if (instruccion !== 0) $fatal(1, "Fallo lectura 7");
        direccion = 15; #1;
        if (instruccion !== 8'hA0) $fatal(1, "Fallo lectura 15");
        $display("Memoria: lecturas del archivo correctas");
        $finish;
    end
endmodule
