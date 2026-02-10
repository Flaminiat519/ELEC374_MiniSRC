//16-bit carry-lookahead adder module
module CLA_16(
	//define input and output wires, 16-bits
	input wire [15:0] a, b,
	input wire c_in,
	output wire [15:0] s,
	output wire c_out
);

	//defining intermediate wires
	wire c_out1;
	wire c_out2;
	wire c_out3;
	
	//computing the 16-bit sum using instances of the
	//4-bit CLA, then putting these in the s and c_out
	CLA_4 adderA(a[3:0], b[3:0], c_in, s[3:0], c_out1);
	CLA_4 adderB(a[7:4], b[7:4], c_in, s[7:4], c_out2);
	CLA_4 adderC(a[11:8], b[11:8], c_in, s[11:8], c_out3);
	CLA_4 adderD(a[15:12], b[15:12], c_in, s[15:12], c_out);
endmodule
