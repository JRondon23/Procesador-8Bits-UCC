module bloque4 #(
    parameter ARCHIVO = "programa.mem"
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       pe,       // Habilitacion del PC desde Control.
    input  logic       bi,       // Salto incondicional desde Control.
    input  logic       bc,       // Salto condicional desde Control.
    input  logic       Zero,     // Flag guardado por la ALU.
    output logic [7:0] instruccion
);
    logic [3:0] pc_mas_uno;
    logic [3:0] pc_siguiente;
    logic       pc_salto;
	 logic [3:0] pc_actual;

    // BI y BC del Control actual. BC salta cuando Zero = 1.
    assign pc_salto = bi | (bc & Zero);

    sumador_pc suma (
        .pc_actual  (pc_actual),
        .pc_mas_uno (pc_mas_uno)
    );

    mux_pc selector (
        .pc_mas_uno  (pc_mas_uno),
        .dir_salto   (instruccion[3:0]),
        .pc_salto    (pc_salto),
        .pc_siguiente(pc_siguiente)
    );

    PC contador (
        .clk         (clk),
        .rst         (rst),
        .pe          (pe),
        .pc_siguiente(pc_siguiente),
        .pc_actual   (pc_actual)
    );

    memoria_programa #(.ARCHIVO(ARCHIVO)) mem (
        .direccion  (pc_actual),
        .instruccion(instruccion)
    );
endmodule
