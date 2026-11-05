module sign_extend (
    input logic [7:0] op_code, 
    output  logic [7:0] dato_out     // Dato de entrada de 8 bits
    
);
    // Extensión de signo: si el bit más significativo es 1, se extiende con 1s, de lo contrario se extiende con 0s
    always_comb begin
        if (op_code[7] == 1'b1 && op_code[6] == 1'b1) begin
            dato_out = {4'b0000, op_code[5:2]}; // Extensión de signo con 0s
        end 
        else begin
            dato_out = {6'b0000, op_code[3:2]}; // Extensión de signo con 0s
        end
    end
endmodule