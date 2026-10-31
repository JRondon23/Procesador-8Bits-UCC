//unidad de control

module unidad_control(
	input logic [3:0] opcode,
	input logic inardo, // esta es la flag de que esta listo el dato
	output logic pe,
	output logic wr,
	output logic [1:0] src,
	output logic alu,
	output logic ac,
	output logic bc,
	output logic bi,
	output logic od
);

always_comb begin

if(opcode == 0 || opcode == 1 || opcode == 2 || opcode == 3 || opcode == 7) begin
	//AND;,OR,XOR,ADD,SUBS
	pe = 1;
	wr = 1;
	src = 0;
	alu = 0;
	ac = 1;
	bc = 0;
	bi = 0;
	od = 0;
end

else if(opcode == 4 || opcode == 5 || opcode == 6 ) begin
	//ADDI,LSL,LSR
	pe = 1;
	wr = 1;
	src = 0;
	alu = 1;
	ac = 1;
	bc = 0;
	bi = 0;
	od = 0;
end

else if(opcode == 8 && inardo == 0) begin
	//inardo
	pe = 0;
	wr = 1;
	src = 2;
	alu = 0;
	ac = 0;
	bc = 0;
	bi = 0;
	od = 0;
	
end

else if(opcode == 8 && inardo == 1) begin
	//inardo
	pe = 1;
	wr = 1;
	src = 0;
	alu = 0;
	ac = 0;
	bc = 0;
	bi = 0;
	od = 0;
end

else if(opcode == 9) begin
	//outarda
	pe = 1;
	wr = 0;
	src = 0;
	alu = 0;
	ac = 0;
	bc = 0;
	bi = 0;
	od = 1;
end


else if(opcode == 10) begin
	//BI
	pe = 1;
	wr = 0;
	src = 0;
	alu = 0;
	ac = 0;
	bc = 0;
	bi = 1;
	od = 0;
end


else if(opcode == 11) begin
	//BC
	pe = 1;
	wr = 0;
	src = 0;
	alu = 0;
	ac = 0;
	bc = 1;
	bi = 0;
	od = 0;
end

else begin
	//MOVI
	pe = 1;
	wr = 1;
	src = 1;
	alu = 0;
	ac = 0;
	bc = 0;
	bi = 0;
	od = 0;
end


end


endmodule