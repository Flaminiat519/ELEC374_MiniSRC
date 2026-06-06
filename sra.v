//32-bit arithmetic shift right — preserves the sign bit
module sra (
	input wire [31:0] a, b,
	output wire [31:0] z
);
	assign z = $signed(a) >>> b;
endmodule
