module memoria_programa #(
    parameter ARCHIVO = "programa.mem"
) (
    input  logic [3:0] direccion,
    output logic [7:0] instruccion
);
    logic [7:0] memoria [0:15];

    initial begin
        for (int i = 0; i < 16; i++) begin
            memoria[i] = 8'b00000000;
        end
        $readmemb(ARCHIVO, memoria);
    end

    assign instruccion = memoria[direccion];
endmodule
