module mux_pc (
    input  logic [3:0] pc_mas_uno,
    input  logic [3:0] dir_salto,
    input  logic       pc_salto,
    output logic [3:0] pc_siguiente
);
    always_comb begin
        case (pc_salto)
            1'b0: pc_siguiente = pc_mas_uno;
            1'b1: pc_siguiente = dir_salto;
            default: pc_siguiente = 4'b0000;
        endcase
    end
endmodule
