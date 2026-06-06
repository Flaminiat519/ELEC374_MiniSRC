//MDR multiplexer — selects between memory data and bus data depending on Read
`timescale 1ns/10ps
module mdr_mux (
	input wire [31:0] BusMuxOut,
	input wire Read,
	input wire [31:0] MDatain,
	output reg [31:0] Q
);
	always @(*) begin
		if (Read)
			Q = MDatain; //Load from memory
		else
			Q = BusMuxOut; //Load from bus
	end
endmodule
