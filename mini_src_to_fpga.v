`timescale 1ns/10ps

module mini_src_to_fpga{
	input clk,
	input [1:0] KEY,
	input [7:0] SWITCHES,
	output LED5,
	output [6:0] HEX0, HEX1
};

	wire [31:0] INPORT_reg = {24'b0, SWITCHES};
	wire [31:0] OUTPORT_reg;
	wire [31:27] IR_op;
	
	