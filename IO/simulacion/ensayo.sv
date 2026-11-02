`timescale 1ns/1ps
module ensayo;
    logic CLOCK_50 = 0;
    logic [1:0] KEY = 2'b10;
    logic [3:0] SW = 0;
    wire [7:0] LED;
    localparam integer ESPERA = 500016;
    placa dut (.*);
    always #10 CLOCK_50 = ~CLOCK_50;

    task automatic esperar(input integer ciclos);
        repeat (ciclos) @(negedge CLOCK_50);
    endtask
    task automatic confirmar(input logic [3:0] valor);
        SW = valor; esperar(ESPERA);
        KEY[1] = 0; esperar(ESPERA);
        KEY[1] = 1; esperar(ESPERA);
    endtask

    initial begin
        esperar(5); KEY[0] = 1; esperar(ESPERA);
        if (LED !== 0) $fatal(1, "Reset de placa");
        confirmar(10);
        if (LED !== 0) $fatal(1, "No mostrar una mitad incompleta");
        confirmar(5);
        if (LED !== 8'hA5) $fatal(1, "Placa: se esperaba A5");
        $display("OK placa: A5 despues de dos confirmaciones");
        confirmar(3); confirmar(12);
        if (LED !== 8'h3C) $fatal(1, "Placa: se esperaba 3C");
        $display("OK placa: segundo byte 3C");
        KEY[0] = 0; esperar(6);
        if (LED !== 0) $fatal(1, "Placa: reset final");
        $display("PRUEBA DE PLACA: correcta en simulacion");
        $finish;
    end
endmodule
