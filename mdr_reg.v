`timescale 1ns/10ps

module mdr_reg (
	input wire [31:0] BusMuxIn,
	input wire clk,
	input wire clr,
	input wire Read,
	input wire MDRin,
	input wire [31:0] MDAtain,
	output wire [31:0] Q
);



	wire [31:0] D;

	// Select between Bus and Memory Data
	mdr_mux muxmdr (
		BusMuxIn,
		Read,
		MDAtain,
		D
	);

	// MDR register
	register mdr (
    .clear(clr),
    .clock(clk),
    .enable(MDRin),
    .BusMuxOut(D),
    .BusMuxIn(Q)
);

endmodule
