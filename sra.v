//Shift right arithmetic module
module sra (
	//wire initialize
	input wire [31:0] a, b,
	output wire [31:0] z
);
	//sra operation
	assign z = $signed(a) >>> b;
endmodule
