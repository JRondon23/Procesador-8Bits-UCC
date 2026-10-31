`timescale 1ns/1ps

module unidad_control_tb;

    logic [3:0] opcode;
    logic inardo;

    logic pe;
    logic wr;
    logic [1:0] src;
    logic alu;
    logic ac;
    logic bc;
    logic bi;
    logic od;

    // Instancia del DUT
    unidad_control dut (
        .opcode(opcode),
        .inardo(inardo),
        .pe(pe),
        .wr(wr),
        .src(src),
        .alu(alu),
        .ac(ac),
        .bc(bc),
        .bi(bi),
        .od(od)
    );

    integer i;

  initial begin

    for (int j = 0; j < 2; j++) begin

        inardo = j;

        for (int i = 0; i < 16; i++) begin

            opcode = i[3:0];

            #10;

            $display(
                "INARDO=%b OPCODE=%0d (%04b) PE=%b WR=%b SRC=%b ALU=%b AC=%b BC=%b BI=%b OD=%b",
                inardo, opcode, opcode,
                pe, wr, src, alu, ac, bc, bi, od
            );

        end
    end

    $finish;

end


endmodule