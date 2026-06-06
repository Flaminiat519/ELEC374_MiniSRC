//32-bit carry-lookahead adder, built from two 16-bit CLA stages
module CLA_32(
	//Input operands and carry-in, output sum and carry-out
	input [31:0] a, b,
	input wire c_in,
	input wire [31:0] s,
	output wire c_out
);
	//Carry signal chained between the two 16-bit stages
	wire c_out_temp;

	//Chain two 16-bit CLAs to produce the full 32-bit sum
	CLA_16 adder1 (a[15:0], b[15:0], c_in, s[15:0], c_out_temp);
	CLA_16 adder2 (a[31:16], b[31:16], c_out_temp, s[31:16], c_out);
endmodule
