`timescale 1ns/1ps
module tb_bloque4;
    logic clk = 0;
    logic rst, pe, bi, bc, Zero;
    logic [7:0] instruccion;
    logic [3:0] pc_actual;

    // Ruta relativa al directorio donde NativeLink inicia Questa.
    bloque4 #(.ARCHIVO("../../programa.mem")) venti (
        .clk(clk), .rst(rst), .pe(pe), .bi(bi), .bc(bc), .Zero(Zero),
        .instruccion(instruccion), .pc_actual(pc_actual)
    );
    always #5 clk = ~clk;

    // Controles en flanco descendente; comprobacion despues del ascendente.
    task automatic paso(
        input logic r, e, i, c, z,
        input logic [3:0] pc_esperado,
        input logic [7:0] instruccion_esperada,
        input string nombre
    );
        @(negedge clk);
        rst = r; pe = e; bi = i; bc = c; Zero = z;
        @(posedge clk); #1;
        if (pc_actual !== pc_esperado || instruccion !== instruccion_esperada)
            $fatal(1, "%s: PC=%d instruccion=%b", nombre, pc_actual, instruccion);
        $display("OK %s: PC=%0d instruccion=%b", nombre, pc_actual, instruccion);
    endtask

    initial begin
        rst = 1; pe = 0; bi = 0; bc = 0; Zero = 0;
        paso(1, 0, 0, 0, 0, 0, 8'hC4, "reset");
        paso(0, 1, 0, 0, 0, 1, 8'h81, "incremento");
        paso(0, 0, 0, 0, 0, 1, 8'h81, "espera de entrada");
        paso(0, 0, 1, 1, 1, 1, 8'h81, "pe bloquea tambien el salto");
        paso(0, 1, 0, 0, 0, 2, 8'h31, "entrada lista: avanzar");
        paso(0, 1, 0, 0, 0, 3, 8'h91, "incremento a OUT");
        paso(0, 1, 0, 0, 0, 4, 8'hB6, "incremento a BC");
        paso(0, 1, 0, 1, 0, 5, 8'hAF, "BC no tomado: Zero=0");
        paso(0, 1, 1, 0, 0, 15, 8'hA0, "BI a 15 por el MUX");
        paso(0, 1, 0, 0, 0, 0, 8'hC4, "incremento de 15 a 0");
        paso(0, 1, 0, 0, 0, 1, 8'h81, "recorrido 1");
        paso(0, 1, 0, 0, 0, 2, 8'h31, "recorrido 2");
        paso(0, 1, 0, 0, 0, 3, 8'h91, "recorrido 3");
        paso(0, 1, 0, 0, 0, 4, 8'hB6, "recorrido 4");
        paso(0, 1, 0, 1, 1, 6, 8'hAF, "BC tomado: Zero=1");
        paso(0, 1, 1, 1, 0, 15, 8'hA0, "BI gana aunque Zero=0");
        paso(1, 1, 1, 1, 1, 0, 8'hC4, "prioridad del reset");
        $display("Bloque 4: todas las pruebas correctas");
        $finish;
    end
endmodule
