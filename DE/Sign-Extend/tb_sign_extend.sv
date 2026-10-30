`timescale 1ns / 1ps

module tb_sign_extend;

    // 1. Declaración de señales de prueba
    logic [7:0] op_code;
    logic [7:0] dato_out;

    // 2. Instancia del módulo a probar (DUT)
    sign_extend dut (
        .op_code(op_code),
        .dato_out(dato_out)
    );

    // 3. Bloque de estímulos
    initial begin
        // Archivos para visualización en GTKWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sign_extend);

        // Monitoreo en consola para ver los resultados sin necesidad de formas de onda
        $monitor("Tiempo=%0t | op_code=%b | dato_out=%b (Hex: %h)", $time, op_code, dato_out, dato_out);

        // --- CASO 1: Instrucción MOVI (Inicia con 11) ---
        // op_code[7:6] = 11, debería extraer op_code[5:2].
        // Ejemplo: 11_1010_00 -> Extrae '1010' y rellena con ceros. Resultado esperado: 00001010 (0x0A)
        op_code = 8'b11101000;
        #10;

        // --- CASO 2: Instrucción ALU (Inicia con 00) ---
        // op_code[7:6] = 00, debería extraer op_code[3:2].
        // Ejemplo: 00_1111_00 -> Extrae '11' y rellena con ceros. Resultado esperado: 00000011 (0x03)
        op_code = 8'b00111100;
        #10;

        // --- CASO 3: Instrucción de Salto (Inicia con 10) ---
        // op_code[7:6] = 10, debería extraer op_code[3:2].
        // Ejemplo: 10_0010_11 -> Extrae '10' y rellena con ceros. Resultado esperado: 00000010 (0x02)
        op_code = 8'b10001011;
        #10;

        // --- CASO 4: Instrucción MOVI con el valor máximo posible ---
        // Ejemplo: 11_1111_11 -> Extrae '1111'. Resultado esperado: 00001111 (0x0F)
        op_code = 8'b11111111;
        #10;

        // Fin de la simulación
        $finish;
    end

endmodule