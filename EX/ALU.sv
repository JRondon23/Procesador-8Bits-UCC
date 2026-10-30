// ALU

module ALU (
	input logic				Mux_ctrl, ALU_pwr, clk, rst,

	input logic [7:0] 	In1, InA, InB,
	input logic [2:0]		ALU_op,
	
	output logic			Zero, Overflow,
	output logic [7:0] 	Output
);

	wire [7:0] mux_a_alu;

	mux_module u_mux(
		.A				(InA),
		.B				(InB),
		.Control		(Mux_ctrl),
		.Out			(mux_a_alu)
	);
	
	ALU_module u_alu(
		.clk			(clk),
		.rst			(rst),
		.ALU_op		(ALU_op),
		.In_1			(In1),
		.In_2			(mux_a_alu),
		.Power		(ALU_pwr),
		.Zero			(Zero),
		.Overflow	(Overflow),
		.Out			(Output)
	);

endmodule