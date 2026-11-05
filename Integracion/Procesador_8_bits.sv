// Procesador_8_bits

module Procesador_8_bits(
	input logic 			clk_50,
	input logic				reset, enter,
	input logic [3:0]		Inardo,
	output logic [7:0]	Outardo,
	output logic 			Overflow
);

	logic [1:0] src;
	logic pe, wr, alu, ac, od, bc, bi, dato_listo; // Señales de control
	logic zero; // Flag que sale de la ALU
	logic [7:0] instruction;
	logic [7:0] alu_out; // Dato que le entra al MUX
	logic [7:0] salida_reg_a, salida_reg_b;
	logic [7:0] sign_extend_out;
	logic [7:0] entrada_usuario;

	unidad_control u_control(
		.opcode		(instruction[7:4]),
		.inardo		(enter),
		.pe			(pe),
		.wr			(wr),
		.src			(src),
		.alu			(alu),
		.ac			(ac),
		.bc			(bc),
		.bi			(bi),
		.od			(od)
	);
	
	bloque4 u_IF(
		.clk				(clk_50),
		.rst				(reset),
		.pe				(pe),
		.bi				(bi),
		.bc				(bc),
		.Zero				(zero),
		.instruccion	(instruction)
	);
	
	banco_registros_tl u_DE (
		.clk			(clk_50),
		.rst			(reset),
		.op_code		(instruction),
		.alu_out		(alu_out),
		.dato_in		(entrada_usuario),
		.src_mux		(src),
		.sel_a		(instruction[3:2]),
		.sel_b		(instruction[1:0]),
		.sel_w		(instruction[1:0]),
		.we			(wr),
		.salida_a	(salida_reg_a),
		.salida_b	(salida_reg_b),
		.sign_extend_out (sign_extend_out)
	);
	
	alu_top u_alu (
		.Mux_ctrl	(alu),
		.ALU_pwr		(ac),
		.clk			(clk_50),
		.rst			(reset),
		.In1			(salida_reg_b),
		.InA			(salida_reg_a),
		.InB			(sign_extend_out),
		.ALU_op		(instruction[6:4]),
		.Zero			(zero),
		.Overflow	(Overflow),
		.Output		(alu_out)
	);
	
	bloqueIO u_IO (
		.clk				(clk_50),
		.rst				(reset),
		.dato_usuario	(Inardo),
		.boton			(enter),           
		.opcode			(instruction[7:4]),
		.pe				(pe),
		.od				(od),
		.dato_salida	(salida_reg_a),
		.dato_entrada	(entrada_usuario),
		.dato_listo		(dato_listo),
		.leds				(Outardo)
	);
	
endmodule