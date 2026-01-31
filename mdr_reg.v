`timescale 1ns/10ps

module mdr_reg (
	input wire [31:0] BusMuxOut,
	input wire clk,
	input wire clr,
	input wire Read,
	input wire MDRin,
	input wire [31:0] MDAtain,
	output wire [31:0] Q
	);
	
	wire [31:0] D;
	
	mdr_mux muxmdr (BusMuxOut, Read, MDAtain, D);
	register mdr (D, clk, clr, MDRin, Q);
endmodule 