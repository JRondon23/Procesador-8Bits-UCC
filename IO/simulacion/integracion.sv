`timescale 1ns/1ps

// Usa los tres modulos originales de los companeros, sin modificarlos.
// wr y src van directo de la unidad de control al banco y al selector.
module integracion;
    logic clk = 0;
    logic rst = 1;
    logic boton = 1;
    logic [3:0] dato_usuario = 0;
    logic [3:0] opcode = 0;
    wire pe, od, wr, dato_listo;
    wire alu, ac, bc, bi;
    wire [1:0] src;
    wire [7:0] dato_entrada, dato_escritura, registro, otro_registro, leds;
    integer recibidos = 0;
    localparam integer ESPERA = 500016;

    always #10 clk = ~clk;

    unidad_control control (
        .opcode(opcode), .inardo(dato_listo), .pe(pe),
        .wr(wr), .src(src), .alu(alu),
        .ac(ac), .bc(bc), .bi(bi), .od(od)
    );

    bloqueIO perifericos (
        .clk(clk), .rst(rst), .dato_usuario(dato_usuario), .boton(boton),
        .opcode(opcode), .pe(pe), .od(od),
        .dato_salida(registro), .dato_entrada(dato_entrada),
        .dato_listo(dato_listo), .leds(leds)
    );

    // Valores distintos para detectar si accidentalmente se elige la ALU.
    banco_mux selector (
        .alu_out(8'hE7), .sign_extend_out(8'h2C),
        .dato_in(dato_entrada), .src_mux(src), .mux_out(dato_escritura)
    );

    banco_registros banco (
        .clk(clk), .rst(rst), .sel_a(2'd1), .sel_b(2'd0),
        .sel_w(2'd1), .dato_w(dato_escritura), .we(wr),
        .salida_a(registro), .salida_b(otro_registro)
    );

    // En el ciclo en que el IN avanza (pe = 1) el banco debe escribir dato_entrada.
    always @(posedge clk) begin
        if (!rst && opcode == 8 && pe) begin
            if (!dato_listo)
                $fatal(1, "IN avanzo sin dato listo");
            if (!wr || src !== 2'd2)
                $fatal(1, "IN listo: el control no escribe dato_in (wr=%b src=%0d, esperado wr=1 src=2)",
                       wr, src);
            recibidos <= recibidos + 1;
            $display("OK: el banco recibe dato %h al terminar el IN", dato_entrada);
        end
    end

    task automatic esperar(input integer ciclos);
        repeat (ciclos) @(negedge clk);
    endtask

    task automatic confirmar(input logic [3:0] mitad);
        dato_usuario = mitad;
        esperar(ESPERA);
        boton = 0;
        esperar(ESPERA);
        boton = 1;
        esperar(ESPERA);
    endtask

    initial begin
        esperar(3); rst = 0;
        opcode = 12; esperar(2);
        if (registro !== 8'h2C) $fatal(1, "Fallo escritura normal antes de IN");
        opcode = 8;
        confirmar(10);
        if (pe !== 0 || recibidos != 0)
            $fatal(1, "IN no espera con solo una mitad");
        confirmar(5);
        if (registro !== 8'hA5 || recibidos != 1 || dato_listo !== 0)
            $fatal(1, "El banco real no capturo A5 exactamente una vez");

        opcode = 9; esperar(2);
        if (leds !== 8'hA5) $fatal(1, "OUT no muestra el registro real");
        $display("OK: IN A5 -> banco R1 -> OUT A5 con modulos originales");

        opcode = 8;
        confirmar(0); confirmar(7);
        if (registro !== 8'h07 || recibidos != 2)
            $fatal(1, "Fallo de la segunda entrada");
        opcode = 9; esperar(2);
        if (leds !== 8'h07) $fatal(1, "Fallo segunda salida");
        $display("INTEGRACION: entrada, Control, selector, banco y salida correctos");
        $finish;
    end

    initial begin
        #2000000000;
        $fatal(1, "Tiempo maximo de integracion excedido");
    end
endmodule
