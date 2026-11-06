module banco_mux (
        input  logic [7:0] alu_out,
        input  logic [7:0] sign_extend_out,
        input  logic [7:0] dato_in,      // Nombre corregido
        input  logic [1:0] src_mux,
        output logic [7:0] mux_out       // Coma eliminada
    );

    always_comb begin
        case (src_mux)
            2'b00: mux_out = alu_out;           
            2'b01: mux_out = sign_extend_out;   
            2'b10: mux_out = dato_in;           // Nombre unificado
            default: mux_out = 8'h00;           
        endcase
    end
endmodule