module banco_registros (
    input  logic       clk,
    input  logic       rst,         // Reset activo en alto
    input  logic [1:0] sel_a,       // Selector lectura A
    input  logic [1:0] sel_b,       // Selector lectura B
    input  logic [1:0] sel_w,       // Selector escritura
    input  logic [7:0] dato_w,      // Dato a escribir desde ALU o E/S
    input  logic       we,          // Habilitación de escritura
    output logic [7:0] salida_a,    // Operando hacia ALU
    output logic [7:0] salida_b     // Operando hacia ALU
);

// Arreglo de 4 posiciones, cada una de 8 bits
    logic [7:0] registros [0:3];

// Asignación continua combinacional
    assign salida_a = registros[sel_a];
    assign salida_b = registros[sel_b];

always_ff @(posedge clk) begin
        if (rst) begin
            // Reset sincrónico: blanqueo de todos los registros
            registros[0] <= 8'h00;
            registros[1] <= 8'h00;
            registros[2] <= 8'h00;
            registros[3] <= 8'h00;
        end else if (we) begin
            // Escritura sincrónica en el registro seleccionado
            registros[sel_w] <= dato_w;
        end
    end
endmodule