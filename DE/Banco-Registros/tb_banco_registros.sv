`timescale 1ns / 1ps

module tb_banco_registros;

    // 1. Declaración de señales locales (conectadas al módulo)
    logic       clk;
    logic       rst;
    logic [1:0] sel_a;
    logic [1:0] sel_b;
    logic [1:0] sel_w;
    logic [7:0] dato_w;
    logic       we;
    logic [7:0] salida_a;
    logic [7:0] salida_b;

    // 2. Instanciación del módulo a probar (Device Under Test - DUT)
    banco_registros dut (
        .clk(clk),
        .rst(rst),
        .sel_a(sel_a),
        .sel_b(sel_b),
        .sel_w(sel_w),
        .dato_w(dato_w),
        .we(we),
        .salida_a(salida_a),
        .salida_b(salida_b)
    );

    // 3. Generación del reloj (ejemplo: período de 20ns -> 50MHz de la DE0-Nano)
    always #10 clk = ~clk;

    // 4. Bloque principal de estímulos
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_banco_registros);

        // Forzar el volcado de cada registro interno para GTKWave
        for (integer i = 0; i < 4; i = i + 1) begin
            $dumpvars(0, dut.registros[i]);
        end
        // Inicialización de señales
        clk = 0;
        rst = 1; // Activo el reset
        sel_a = 2'b00;
        sel_b = 2'b00;
        sel_w = 2'b00;
        dato_w = 8'h00;
        we = 0;

        // Esperar unos ciclos y quitar el reset
        #30 rst = 0;

        // --- PRUEBA 1: Escritura en registros ---
        @(negedge clk);
        we = 1; sel_w = 2'b00; dato_w = 8'hAA; // Escribo AA en R0
        
        @(negedge clk);
        we = 1; sel_w = 2'b01; dato_w = 8'hBB; // Escribo BB en R1
        
        @(negedge clk);
        we = 1; sel_w = 2'b10; dato_w = 8'hCC; // Escribo CC en R2
        
        @(negedge clk);
        we = 0; // Apago escritura


        // --- PRUEBA 2: Lectura simultánea (Combinacional) ---
        // Verificamos que se pueden leer dos registros a la vez
        #10;
        sel_a = 2'b00; // Leo R0 en el puerto A (debería salir AA)
        sel_b = 2'b01; // Leo R1 en el puerto B (debería salir BB)
        #20;

        // --- PRUEBA 3: Colisión de Lectura y Escritura ---
        // Exigencia del informe: documentar qué pasa si leo y escribo el mismo registro en el mismo ciclo
        @(negedge clk);
        we = 1; 
        sel_w = 2'b10; dato_w = 8'hFF; // Escribo FF en R2
        sel_a = 2'b10;                 // Al mismo tiempo, intento leer R2
        
        // Aquí en la forma de onda deberías observar que salida_a muestra el valor viejo (CC) 
        // durante este ciclo, y recién cambia a FF después del próximo flanco de reloj.
        
        @(negedge clk);
        we = 0;

        // Fin de simulación
        #50 $finish;
    end

endmodule