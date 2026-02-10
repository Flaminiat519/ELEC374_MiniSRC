//Shift left module
module sll (
	//wire initialization
	input wire [31:0] a, b,
	output wire [31:0] z
);
	//shift left operation
	assign z = a << b;
endmodule
