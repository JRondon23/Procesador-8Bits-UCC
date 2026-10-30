// MUX

module mux_module (
	input logic [7:0] 	A, B,
	input logic				Control,
	output logic [7:0]	Out
);

	always_comb
		case (Control)
			0: Out = A;
			1: Out = B;
			default: Out = 8'b0000_0000;
		endcase

endmodule