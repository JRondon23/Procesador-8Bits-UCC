module banco_registros_tl (
    input  logic       clk,
    input  logic       rst,
    // Entradas para el sign_extend
    input  logic [7:0] op_code,
    
    // Entradas directas para el multiplexor (banco_mux)
    input  logic [7:0] alu_out,
    input  logic [7:0] dato_in,
    input  logic [1:0] src_mux,
    
    // Entradas de control y selección para el banco de registros
    input  logic [1:0] sel_a,
    input  logic [1:0] sel_b,
    input  logic [1:0] sel_w,
    input  logic       we,
    
    // Salidas del banco de registros
    output logic [7:0] salida_a,
    output logic [7:0] salida_b,
	 
	 output logic [7:0] sign_extend_out
);

    // Senales internas de interconexion
    logic [7:0] mux_to_reg_w;

    // 1. Instancia del módulo Sign Extend
    sign_extend u_sign_extend (
        .op_code  (op_code),
        .dato_out (sign_extend_out)
    );

    // 2. Instancia del Banco de Multiplexores
    banco_mux u_banco_mux (
        .alu_out         (alu_out),
        .sign_extend_out (sign_extend_out),
        .dato_in         (dato_in),
        .src_mux         (src_mux),
        .mux_out         (mux_to_reg_w)
    );

    // 3. Instancia del Banco de Registros
    banco_registros u_banco_registros (
        .clk      (clk),
        .rst      (rst),
        .sel_a    (sel_a),
        .sel_b    (sel_b),
        .sel_w    (sel_w),
        .dato_w   (mux_to_reg_w), // Recibe el dato seleccionado por el MUX
        .we       (we),
        .salida_a (salida_a),
        .salida_b (salida_b)
    );

endmodule