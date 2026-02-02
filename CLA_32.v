module CLA_32(
	input [31:0] a, b,
	input wire c_in,
	input wire [31:0] s,
	output wire c_out
);

	wire c_out_temp;
	
	CLA_16 adder1 (a[15:0], b[15:0], c_in, s[15:0], c_out_temp);
	CLA_16 adder2 (a[31:16], b[31:16], c_out_temp, s[31:16], c_out);
endmodule