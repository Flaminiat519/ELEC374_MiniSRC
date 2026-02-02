module CLA_4(
	input wire [3:0] a, b,
	input wire c_in,
	output wire [3:0] s,
	output wire c_out
);

	wire [3:0] G, P;
	wire [3:0] carry;
	wire [3:0] carry_outs; //left blank

	assign G = a & b;
	assign P = a ^ b;

	assign carry[0] = c_in;
	assign carry[1] = G[0] | (P[0]&carry[0]);
	assign carry[2] = G[1] | (P[1]&G[0]) | (P[1]&P[0]&carry[0]);
	assign carry[3] = G[2] | (P[2]&G[1]) | (P[2]&P[1]&G[0]) | (P[2]&P[1]&P[0]&carry[0]);
	assign c_out = G[3] | (P[3]&G[2]) | (P[3]&P[2]&G[1]) | (P[3]&P[2]&P[1]&G[0]) | (P[3]&P[2]&P[1]&P[0]&carry[0]);

	full_adder fa0 (a[0], b[0], carry[0], s[0], carry_outs[0]);
	full_adder fa1 (a[1], b[1], carry[1], s[1], carry_outs[1]);
	full_adder fa2 (a[2], b[2], carry[2], s[2], carry_outs[2]);
	full_adder fa3 (a[3], b[3], carry[3], s[3], carry_outs[3]);
endmodule
