`timescale 1ns/1ps
module tb_contador_programa;
    logic clk = 0;
    logic rst, pe;
    logic [3:0] pc_siguiente, pc_actual;

    PC dut (
        .clk(clk), .rst(rst), .pe(pe),
        .pc_siguiente(pc_siguiente), .pc_actual(pc_actual)
    );
    always #5 clk = ~clk;

    initial begin
        rst = 1; pe = 0; pc_siguiente = 9;
        @(posedge clk); #1;
        if (pc_actual !== 0) $fatal(1, "Fallo del reset");
        @(negedge clk); rst = 0;
        @(posedge clk); #1;
        if (pc_actual !== 0) $fatal(1, "Fallo: pe=0 no conserva el PC");
        @(negedge clk); pe = 1;
        @(posedge clk); #1;
        if (pc_actual !== 9) $fatal(1, "Fallo al capturar pc_siguiente");
        @(negedge clk); rst = 1; pc_siguiente = 15;
        @(posedge clk); #1;
        if (pc_actual !== 0) $fatal(1, "Fallo de prioridad del reset");
        $display("PC: todas las pruebas correctas");
        $finish;
    end
endmodule
