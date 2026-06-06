//16-bit carry-lookahead adder Module, built from four 4-bit CLA stages
module CLA_16(
	//Input operands and carry-in, output sum and carry-out
	input wire [15:0] a, b,
	input wire c_in,
	output wire [15:0] s,
	output wire c_out
);
	//Carry signals chained between each 4-bit stage
	wire c_out1;
	wire c_out2;
	wire c_out3;
	
	//Chain four 4-bit CLA instances to produce the full 16-bit sum
	CLA_4 adderA(a[3:0], b[3:0], c_in, s[3:0], c_out1);
	CLA_4 adderB(a[7:4], b[7:4], c_out1, s[7:4], c_out2);
	CLA_4 adderC(a[11:8], b[11:8], c_out2, s[11:8], c_out3);
	CLA_4 adderD(a[15:12], b[15:12], c_out3, s[15:12], c_out);
endmodule
