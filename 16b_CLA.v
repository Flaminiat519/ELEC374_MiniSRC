module 16b_CLA (
	input wire [15:0] a, b,
	input wire c_in;
	output wire [15:0] s,
	output wire c_out
);

	wire c_out1;
	wire c_out2;
	wire c_out3;
	
	4b_CLA adderA(a[3:0], b[3:0], c_in, s[3:0], c_out1);
	4b_CLA adderB(a[7:4], b[7:4], c_in, s[7:4], c_out2);
	4b_CLA adderC(a[11:8], b[11:8], c_in, s[11:8], c_out3);
	4b_CLA adderD(a[15:12], b[15:12], c_in, s[15:12], c_out);
endmodule