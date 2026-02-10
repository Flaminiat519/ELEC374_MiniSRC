//Shift left? module
module srl (
	//initialize wires
	input wire [31:0] a, b,
	output wire [31:0] z
);
	//Shift right operation!
	assign z = a >> b;
endmodule
