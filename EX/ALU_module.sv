// ALU_module

module ALU_module (
    input  logic       clk, rst,
    input  logic [2:0] ALU_op,
    input  logic [7:0] In_1, In_2,
    input  logic       Power,

    output logic       Zero, Overflow,
    output logic [7:0] Out
);

    logic zero;

    // Registro de Zero con reset activo en alto.
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            Zero <= 1'b0;
        else if (Power)
            Zero <= zero;
    end

    // Lógica combinacional de la ALU.
    always_comb begin
        Out      = 'z;
        Overflow = 1'b0;
        zero     = 1'b0;

        if (Power) begin
            case (ALU_op)
                3'b000: Out = In_1 & In_2;
                3'b001: Out = In_1 | In_2;
                3'b010: Out = In_1 ^ In_2;
                3'b011: Out = In_1 + In_2;
                3'b100: Out = In_1 + In_2;
                3'b101: Out = In_1 << In_2;
                3'b110: Out = In_1 >> In_2;
                3'b111: Out = In_1 - In_2;
                default: Out = 'z;
            endcase

            // Solo indica cero para la operación de resta.
            zero = (ALU_op == 3'b111) && (Out == 8'b0000_0000);

            // Acarreo en suma y préstamo en resta sin signo.
            case (ALU_op)
                3'b011, 3'b100:
                    Overflow = (In_1[7] == In_2[7]) && (Out[7] != In_1[7]);

                3'b111:
                    Overflow = (In_1[7] != In_2[7]) && (Out[7] != In_1[7]);

                default:
                    Overflow = 1'b0;
            endcase
        end
    end

endmodule