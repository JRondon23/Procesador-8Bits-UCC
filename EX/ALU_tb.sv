`timescale 1ns/1ps

module ALU_tb;
    logic clk = 1'b0;
    logic rst = 1'b0;
    logic Mux_ctrl, ALU_pwr;
    logic [7:0] In1, InA, InB;
    logic [2:0] ALU_op;
    wire Zero, Overflow;
    wire [7:0] Output;

    int checks = 0;
    int pass_count = 0;
    int fail_count = 0;
    bit test_done = 0;
    logic expected_zero = 1'b0;

    ALU dut (
        .Mux_ctrl(Mux_ctrl), .ALU_pwr(ALU_pwr),
        .clk(clk), .rst(rst),
        .In1(In1), .InA(InA), .InB(InB), .ALU_op(ALU_op),
        .Zero(Zero), .Overflow(Overflow), .Output(Output)
    );

    always #5 clk = ~clk; // Periodo: 10 ns.

    // Modelo de referencia: calcula desde las entradas, sin leer la DUT.
    // Compara antes y despues del reloj y cuenta un resultado por caso.
    task automatic golden_model;
        logic [7:0] operand, expected_out;
        logic expected_overflow, next_zero;
        int signed arithmetic_result;
        bit passed;
        begin
            operand = Mux_ctrl ? InB : InA;
            expected_out = 'z;
            expected_overflow = 0;
            next_zero = expected_zero;
            passed = 1;
            if (ALU_pwr) begin
                case (ALU_op)
                    0: expected_out = In1 & operand;
                    1: expected_out = In1 | operand;
                    2: expected_out = In1 ^ operand;
                    3, 4: begin
                        arithmetic_result = int'($signed(In1)) + int'($signed(operand));
                        expected_out = arithmetic_result[7:0];
                        expected_overflow = (arithmetic_result < -128) ||
                                            (arithmetic_result > 127);
                    end
                    5: expected_out = In1 << operand;
                    6: expected_out = In1 >> operand;
                    7: begin
                        arithmetic_result = int'($signed(In1)) - int'($signed(operand));
                        expected_out = arithmetic_result[7:0];
                        expected_overflow = (arithmetic_result < -128) ||
                                            (arithmetic_result > 127);
                    end
                    default: expected_out = 'z;
                endcase
                next_zero = (ALU_op == 7) && (In1 == operand);
            end

            #1;
            if (Output !== expected_out || Overflow !== expected_overflow ||
                Zero !== expected_zero) begin
                passed = 0;
                $display("FAIL antes del reloj t=%0t op=%b Power=%b Mux=%b In1=%h operando=%h Out=%h esperado=%h Overflow=%b esperado=%b Zero=%b esperado=%b",
                         $time, ALU_op, ALU_pwr, Mux_ctrl, In1, operand,
                         Output, expected_out, Overflow, expected_overflow,
                         Zero, expected_zero);
            end

            @(posedge clk);
            #1;
            expected_zero = next_zero;
            if (Output !== expected_out || Overflow !== expected_overflow ||
                Zero !== expected_zero) begin
                passed = 0;
                $display("FAIL despues del reloj t=%0t op=%b Out=%h esperado=%h Overflow=%b esperado=%b Zero=%b esperado=%b",
                         $time, ALU_op, Output, expected_out, Overflow,
                         expected_overflow, Zero, expected_zero);
            end
            record_result(passed, "operacion");
        end
    endtask

    task automatic record_result(input bit passed, input string label_text);
        begin
            checks++;
            if (passed) pass_count++;
            else fail_count++;
            $display("Caso %0d (%s): %s | PASS=%0d FAIL=%0d",
                     checks, label_text, passed ? "PASS" : "FAIL",
                     pass_count, fail_count);
        end
    endtask

    // Estimula en el flanco descendente para evitar carreras con la DUT.
    task automatic check_operation(
        input logic power_on,
        input logic select_b,
        input logic [2:0] operation,
        input logic [7:0] a, b, c
    );
        begin
            @(negedge clk);
            ALU_pwr = power_on;
            Mux_ctrl = select_b;
            ALU_op = operation;
            In1 = a;
            InA = b;
            InB = c;
            golden_model();
        end
    endtask

    task automatic check_reset;
        bit passed;
        begin
            @(negedge clk);
            #1;
            rst = 1;
            expected_zero = 0;
            #1;
            passed = (Zero === 1'b0);
            if (!passed)
                $display("FAIL reset asincrono t=%0t Zero=%b esperado=0", $time, Zero);
            @(posedge clk);
            #1;
            if (Zero !== 1'b0) begin
                passed = 0;
                $display("FAIL reset en reloj t=%0t Zero=%b esperado=0", $time, Zero);
            end
            rst = 0;
            record_result(passed, "reset");
        end
    endtask

    initial begin
        Mux_ctrl = 0;
        ALU_pwr = 0;
        ALU_op = 0;
        In1 = 0;
        InA = 0;
        InB = 0;

        check_reset();

        // Todas las operaciones por las dos entradas del multiplexor.
        for (int op = 0; op < 8; op++) begin
            check_operation(1, 0, op, 8'hA5, 8'h03, 8'h01);
            check_operation(1, 1, op, 8'hA5, 8'h03, 8'h01);
        end

        // Patrones de 8 bits interpretados en complemento a dos.
        check_operation(1, 0, 3'b011, 255, 1, 0);
        check_operation(1, 1, 3'b100, 255, 0, 255);
        check_operation(1, 0, 3'b011, 127, 1, 0);
        check_operation(1, 0, 3'b111, 0, 1, 0);
        check_operation(1, 0, 3'b111, 255, 1, 0);

        // Limites con signo por ambos caminos del MUX y ambos codigos de suma.
        for (int sel = 0; sel < 2; sel++) begin
            for (int add_op = 3; add_op <= 4; add_op++) begin
                check_operation(1, sel, add_op, 8'h7F, 8'h01, 8'h01); // 127+1: overflow
                check_operation(1, sel, add_op, 8'h80, 8'hFF, 8'hFF); // -128-1: overflow
                check_operation(1, sel, add_op, 8'h05, 8'hF6, 8'hF6); // 5+(-10): valido
                check_operation(1, sel, add_op, 8'hFF, 8'h01, 8'h01); // -1+1: valido
                check_operation(1, sel, add_op, 8'h80, 8'h80, 8'h80); // -128+(-128)
                check_operation(1, sel, add_op, 8'h7F, 8'h00, 8'h00); // 127+0: valido
            end
            check_operation(1, sel, 7, 8'h7F, 8'hFF, 8'hFF); // 127-(-1): overflow
            check_operation(1, sel, 7, 8'h80, 8'h01, 8'h01); // -128-1: overflow
            check_operation(1, sel, 7, 8'h05, 8'h0A, 8'h0A); // 5-10: valido
            check_operation(1, sel, 7, 8'hFF, 8'h01, 8'h01); // -1-1: valido
            check_operation(1, sel, 7, 8'h80, 8'h80, 8'h80); // -128-(-128): cero
            check_operation(1, sel, 7, 8'h7F, 8'h80, 8'h80); // 127-(-128): overflow
        end

        // Desplazamientos de 0, 7, 8 y 255 posiciones.
        check_operation(1, 0, 3'b101, 1, 0, 0);
        check_operation(1, 0, 3'b101, 1, 7, 0);
        check_operation(1, 0, 3'b101, 255, 8, 0);
        check_operation(1, 1, 3'b110, 128, 0, 7);
        check_operation(1, 1, 3'b110, 255, 0, 255);

        // Zero=1 se conserva apagada, aunque cambien las entradas.
        check_operation(1, 0, 3'b111, 42, 42, 0);
        check_operation(0, 0, 3'b011, 255, 1, 0);
        check_operation(0, 1, 3'b111, 1, 0, 2);
        check_reset(); // Reset funciona tambien estando apagada.
        check_operation(0, 0, 3'b111, 42, 42, 0);

        // Reactivacion y borrado de Zero por otra operacion.
        check_operation(1, 1, 3'b111, 42, 0, 42);
        check_operation(1, 0, 3'b010, 42, 42, 0);
        check_operation(0, 0, 3'b000, 0, 0, 0);

        // Reset tambien se comprueba con Power=1 y Zero=1.
        check_operation(1, 0, 3'b111, 42, 42, 0);
        check_reset();
        check_operation(1, 0, 3'b001, 0, 0, 0);

        // Casos adicionales con entradas aleatorias.
        repeat (500)
            check_operation($urandom_range(0, 1), $urandom_range(0, 1),
                            $urandom_range(0, 7), $urandom_range(0, 255),
                            $urandom_range(0, 255), $urandom_range(0, 255));

        test_done = 1;
        $display("========================================");
        $display("TOTAL=%0d | PASS=%0d | FAIL=%0d", checks, pass_count, fail_count);
        $display("RESULTADO: %s", fail_count == 0 ? "PASS" : "FAIL");
        $display("========================================");
        $stop;
    end

    initial begin
        #100000;
        if (!test_done) begin
            $display("TIMEOUT: PASS=%0d FAIL=%0d", pass_count, fail_count);
            $fatal(1, "La simulacion no termino");
        end
    end
endmodule
