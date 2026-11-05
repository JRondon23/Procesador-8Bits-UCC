module sumador_pc (
    input  logic [3:0] pc_actual,
    output logic [3:0] pc_mas_uno
);
    assign pc_mas_uno = pc_actual + 4'd1;
endmodule
