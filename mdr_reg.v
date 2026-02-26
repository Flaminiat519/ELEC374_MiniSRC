//Special MDR register module
`timescale 1ns/10ps

module mdr_reg (
	input wire [31:0] BusMuxIn,
	input wire clk,
	input wire clr,
	input wire Read,
	input wire MDRin,
	input wire [31:0] MDatain,
	output wire [31:0] Q
);
	wire [31:0] D;
	//choosing bus or memory data
	mdr_mux muxmdr (BusMuxIn, Read, MDatain, D);
	//reg instantiation
	register mdr (.clear(clr), .clock(clk), .enable(MDRin), .BusMuxOut(Q), .BusMuxIn(D)
);

endmodule
