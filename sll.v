//32-bit logical shift left
module sll (
	input wire [31:0] a, b,
	output wire [31:0] z
);
	assign z = a << b;
endmodule
