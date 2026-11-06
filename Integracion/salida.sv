module salida (
    input logic clk, rst,
    input logic od,
    input logic [7:0] dato_salida,
    output logic [7:0] leds
);
    always_ff @(posedge clk) begin
        if (rst)
            leds <= 0;
        else if (od)
            leds <= dato_salida;
    end
endmodule
