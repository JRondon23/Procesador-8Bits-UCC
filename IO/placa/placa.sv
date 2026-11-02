// Prueba independiente: muestra en LEDs el byte ingresado.
// Emula IN y OUT; no reemplaza al Control ni al banco del procesador.
module placa (
    input logic CLOCK_50,
    input logic [1:0] KEY,
    input logic [3:0] SW,
    output logic [7:0] LED
);
    // KEY0: reset. Liberacion sincronizada; mantener pulsado unos instantes.
    logic reset_etapa1 = 1'b1;
    logic rst = 1'b1;
    logic [7:0] dato_entrada, dato_guardado;
    logic dato_listo, mostrar_resultado;
    logic [3:0] opcode;
    logic pe, od;

    always_ff @(posedge CLOCK_50) begin
        reset_etapa1 <= !KEY[0];
        rst <= reset_etapa1;
    end

    assign opcode = mostrar_resultado ? 4'b1001 : 4'b1000;
    assign pe = mostrar_resultado || dato_listo;
    assign od = mostrar_resultado;

    always_ff @(posedge CLOCK_50) begin
        if (rst) begin
            dato_guardado <= 0;
            mostrar_resultado <= 0;
        end else if (mostrar_resultado) begin
            mostrar_resultado <= 0;
        end else if (dato_listo) begin
            dato_guardado <= dato_entrada;
            mostrar_resultado <= 1;
        end
    end

    bloqueIO perifericos (
        .clk(CLOCK_50), .rst(rst), .dato_usuario(SW),
        .boton(KEY[1]), .opcode(opcode), .pe(pe), .od(od),
        .dato_salida(dato_guardado), .dato_entrada(dato_entrada),
        .dato_listo(dato_listo), .leds(LED)
    );
endmodule
