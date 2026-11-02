`timescale 1ns/1ps
module pruebas;
    logic clk = 0;
    logic rst, boton, pe, od;
    logic [3:0] dato_usuario, opcode;
    logic [7:0] dato_salida, dato_entrada, leds;
    logic dato_listo;
    logic [7:0] capturado_banco;
    integer pulsos = 0;
    // Se usa el filtro real: 10 ms a 50 MHz, sin configuracion externa.
    localparam integer ESPERA = 500016;

    bloqueIO dut (.*);
    always #10 clk = ~clk;

    // Modelo de la captura que debe hacer el banco al aceptar IN.
    always @(posedge clk) begin
        if (rst)
            capturado_banco <= 0;
        else if (opcode == 8 && dato_listo && pe)
            capturado_banco <= dato_entrada;
        if (!rst && dut.recibe.pulso)
            pulsos <= pulsos + 1;
    end

    task automatic esperar(input integer ciclos);
        repeat (ciclos) @(negedge clk);
    endtask

    task automatic elegir_mitad(input logic [3:0] valor);
        @(negedge clk);
        dato_usuario = valor;
        esperar(ESPERA);
    endtask

    task automatic pulsar;
        @(negedge clk); boton = 0;
        esperar(ESPERA);
        boton = 1;
        esperar(ESPERA);
    endtask

    task automatic verificar(input logic condicion, input string caso);
        if (condicion !== 1'b1) $fatal(1, "FALLO: %s", caso);
        $display("OK: %s", caso);
    endtask

    initial begin
        rst = 1; boton = 1;
        pe = 0; od = 0; dato_usuario = 0; opcode = 0; dato_salida = 0;
        esperar(3); rst = 0; esperar(ESPERA);
        verificar(dato_entrada == 0 && !dato_listo && leds == 0, "reset");

        elegir_mitad(9); pulsar();
        verificar(!dato_listo && dato_entrada == 0, "ignorar boton fuera de IN");
        opcode = 8;

        // Rebote corto: no debe completar ni iniciar la carga.
        elegir_mitad(10);
        boton = 0; esperar(1);
        boton = 1; esperar(1);
        boton = 0; esperar(1);
        boton = 1; esperar(ESPERA);
        verificar(!dato_listo && !dut.recibe.mitad_pendiente,
                  "rechazar rebotes del boton");

        // Una pulsacion sostenida solo guarda la mitad superior.
        begin
            integer antes;
            antes = pulsos;
            boton = 0; esperar(2 * ESPERA);
            verificar(pulsos == antes + 1 && !dato_listo,
                      "boton sostenido genera una sola confirmacion");
            boton = 1; esperar(ESPERA);
        end
        elegir_mitad(5); pulsar();
        verificar(dato_listo && dato_entrada == 8'hA5,
                  "primero superiores y despues inferiores: A5");
        esperar(8);
        verificar(dato_listo && dato_entrada == 8'hA5,
                  "dato listo permanece mientras pe=0");
        elegir_mitad(15); pulsar();
        verificar(dato_listo && dato_entrada == 8'hA5,
                  "no sobrescribir un dato pendiente");

        pe = 1; esperar(2);
        verificar(!dato_listo && capturado_banco == 8'hA5 && dato_entrada == 8'hA5,
                  "aceptacion conserva el byte para el banco");
        pe = 0; opcode = 9; dato_salida = 8'h3C; od = 1;
        esperar(2); od = 0; dato_salida = 8'hFF;
        esperar(3);
        verificar(leds == 8'h3C, "salida retenida sin od");

        opcode = 8;
        elegir_mitad(0); pulsar(); pulsar();
        verificar(dato_listo && dato_entrada == 0, "el dato cero tambien es valido");
        pe = 1; esperar(2); pe = 0;

        // Descartar la mitad pendiente si se abandona IN.
        elegir_mitad(12); pulsar();
        opcode = 0; esperar(3); opcode = 8;
        elegir_mitad(3); pulsar(); elegir_mitad(4); pulsar();
        verificar(dato_listo && dato_entrada == 8'h34,
                  "descartar carga incompleta al salir de IN");
        pe = 1; esperar(2); pe = 0;

        // Un pulso con switches inestables se ignora; se debe volver a pulsar.
        boton = 0;
        repeat (24) begin
            dato_usuario = ~dato_usuario;
            esperar(1);
        end
        esperar(ESPERA);
        verificar(!dut.recibe.mitad_pendiente && !dato_listo,
                  "no capturar mientras los switches rebotan");
        boton = 1; esperar(ESPERA);
        elegir_mitad(2); pulsar(); elegir_mitad(7); pulsar();
        verificar(dato_listo && dato_entrada == 8'h27,
                  "nueva pulsacion despues de estabilizar switches");

        rst = 1; esperar(3);
        verificar(dato_entrada == 0 && !dato_listo && leds == 0,
                  "reset limpia captura y salida");
        $display("ENTRADA/SALIDA: todas las pruebas correctas");
        $finish;
    end

    initial begin
        #2000000000;
        $fatal(1, "Tiempo maximo de prueba excedido");
    end
endmodule
