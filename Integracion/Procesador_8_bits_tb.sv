`timescale 1ns/1ps

module Procesador_8_bits_tb;
    logic clk_50 = 0;
    logic reset = 1, enter = 1;
    logic [3:0] Inardo = 0;
    wire [7:0] Outardo;
    wire Overflow;

    int pass_count = 0, fail_count = 0, omitidos = 0;
    // Filtro: 500000 ciclos, mas margen para el sincronizador.
    localparam int ESTABILIZACION = 500010;

    Procesador_8_bits dut (
        .clk_50(clk_50), .reset(reset), .enter(enter),
        .Inardo(Inardo), .Outardo(Outardo), .Overflow(Overflow)
    );

    always #10 clk_50 = ~clk_50;

    task automatic comprobar(input string caso, input logic correcto);
        if (correcto === 1'b1) begin
            pass_count++;
            $display("PASS: %s", caso);
        end else begin
            fail_count++;
            $display("FAIL: %s (t=%0t PC=%h instruccion=%h OUT=%h Overflow=%b)",
                     caso, $time, dut.u_IF.pc_actual, dut.instruction,
                     Outardo, Overflow);
        end
    endtask

    // Modelo de programa.mem: MOVI 1, IN, ADD y OUT. La suma
    // conserva los 8 bits bajos y Overflow usa el rango con signo.
    task automatic golden_model(
        input logic [7:0] entrada,
        output logic [7:0] salida,
        output logic overflow
    );
        int signed suma;
        suma = int'($signed(entrada)) + 1;
        salida = suma[7:0];
        overflow = (suma < -128) || (suma > 127);
    endtask

    task automatic ciclo;
        @(posedge clk_50);
        #1;
    endtask

    function automatic bit in_en_espera(input logic [7:0] r1_anterior);
        return (dut.u_IF.pc_actual === 4'd1) &&
               (dut.wr === 1'b0) && (dut.dato_listo === 1'b0) &&
               (dut.salida_reg_b === r1_anterior) && (Outardo === 8'h00);
    endfunction

    task automatic esperar_nibble(input logic [7:0] r1_anterior,
                                   output bit estable);
        estable = 1;
        repeat (ESTABILIZACION) begin
            @(negedge clk_50);
            if (!in_en_espera(r1_anterior)) begin
                estable = 0;
                return;
            end
        end
    endtask

    task automatic probar_programa(input logic [7:0] entrada);
        logic [7:0] salida_esperada;
        logic overflow_esperado;
        logic [7:0] r1_anterior;
        bit espera_correcta, recibido;
        golden_model(entrada, salida_esperada, overflow_esperado);
        $display("--- Entrada esperada: %h ---", entrada);

        @(negedge clk_50);
        reset = 1;
        enter = 1; // Boton activo en bajo en el modulo de entrada.
        Inardo = entrada[7:4];
        repeat (3) ciclo();
        comprobar("Reset: PC y salida en cero",
                  (dut.u_IF.pc_actual === 4'd0) && (Outardo === 8'h00));
        @(negedge clk_50);
        reset = 0;
        ciclo();
        comprobar("MOVI: R0=1 y PC=1",
                  (dut.u_IF.pc_actual === 4'd1) &&
                  (dut.salida_reg_a === 8'h01));

        r1_anterior = 8'h00; // Valor de R1 despues del reset.
        esperar_nibble(r1_anterior, espera_correcta);
        comprobar("IN espera con el boton liberado sin escribir R1", espera_correcta);
        if (!espera_correcta) begin
            omitidos++;
            $display("Escenario incompleto: se omiten los pasos posteriores al fallo de IN");
            return;
        end

        enter = 0;
        esperar_nibble(r1_anterior, espera_correcta);
        comprobar("IN espera tras el primer nibble sin escribir R1", espera_correcta);
        if (!espera_correcta) begin
            omitidos++;
            $display("Escenario incompleto: se omiten los pasos posteriores al fallo de IN");
            return;
        end

        enter = 1;
        Inardo = entrada[3:0];
        esperar_nibble(r1_anterior, espera_correcta);
        comprobar("IN espera durante la liberacion del boton", espera_correcta);
        if (!espera_correcta) begin
            omitidos++;
            $display("Escenario incompleto: se omiten los pasos posteriores al fallo de IN");
            return;
        end
        enter = 0;

        recibido = 0;
        for (int i = 0; i < ESTABILIZACION; i++) begin
            ciclo();
            if (dut.dato_listo === 1'b1) begin
                recibido = (dut.u_IF.pc_actual === 4'd1) &&
                           (dut.entrada_usuario === entrada) &&
                           (dut.salida_reg_b === r1_anterior) &&
                           (dut.wr === 1'b1) && (dut.pe === 1'b1);
                break;
            end
            if (!in_en_espera(r1_anterior)) break;
        end
        comprobar($sformatf("IN: dato_listo con byte %h antes de escribir", entrada), recibido);
        if (recibido) begin
            ciclo();
            recibido = (dut.u_IF.pc_actual === 4'd2) &&
                       (dut.salida_reg_b === entrada) && (dut.dato_listo === 1'b0);
            comprobar("IN escribe R1, avanza el PC y limpia dato_listo", recibido);
        end
        if (!recibido) begin
            omitidos++;
            $display("Escenario incompleto: se omiten los pasos posteriores al fallo de IN");
            return;
        end
        comprobar($sformatf("ADD: resultado=%h Overflow=%b",
                            salida_esperada, overflow_esperado),
                  (dut.u_IF.pc_actual === 4'd2) &&
                  (dut.alu_out === salida_esperada) &&
                  (Overflow === overflow_esperado));

        ciclo();
        comprobar("ADD escribe R1 y avanza a OUT", (dut.u_IF.pc_actual === 4'd3) &&
                  (dut.salida_reg_b === salida_esperada) && (Outardo === 8'h00));
        ciclo();
        comprobar($sformatf("OUT publica %h", salida_esperada),
                  (dut.u_IF.pc_actual === 4'd4) && (Outardo === salida_esperada));
        ciclo();
        comprobar("BC con Zero=0 no salta", (dut.u_IF.pc_actual === 4'd5) && (Outardo === salida_esperada));
        ciclo();
        comprobar("BI salta a 15", (dut.u_IF.pc_actual === 4'd15) && (Outardo === salida_esperada));
        ciclo();
        comprobar("BI vuelve a 0 y OUT conserva su valor",
                  (dut.u_IF.pc_actual === 4'd0) && (Outardo === salida_esperada));
    endtask

    initial begin
        probar_programa(8'h2A);
        probar_programa(8'h7F);
        $display("TOTAL=%0d | PASS=%0d | FAIL=%0d",
                 pass_count + fail_count, pass_count, fail_count);
        $display("ESCENARIOS INCOMPLETOS=%0d", omitidos);
        $display("RESULTADO: %s", fail_count == 0 ? "PASS" : "FAIL");
        $stop;
    end
endmodule
