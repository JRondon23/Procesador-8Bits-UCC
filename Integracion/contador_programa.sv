// Registro del PC: el sumador y el MUX estan en bloque4.
module PC (
    input  logic       clk,
    input  logic       rst,
    input  logic       pe,
    input  logic [3:0] pc_siguiente,
    output logic [3:0] pc_actual
);
    always_ff @(posedge clk) begin
        if (rst)
            pc_actual <= 4'd0;
        else if (pe)
            pc_actual <= pc_siguiente;
    end
endmodule
