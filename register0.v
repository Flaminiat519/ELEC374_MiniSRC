//R0 register — identical to a general register but forces output to 0 when BAout is asserted
module register0 #(
	parameter DATA_WIDTH_IN  = 32,
	parameter DATA_WIDTH_OUT = 32,
	parameter INIT           = 32'b0
)(
	input wire clear,
	input wire clock,
	input wire enable,
	input wire BAout,
	input wire  [DATA_WIDTH_IN-1:0]  BusMuxIn,
	output wire [DATA_WIDTH_OUT-1:0] BusMuxOut
);
	reg [DATA_WIDTH_IN-1:0] q;
	initial q = INIT;

	always @(posedge clock) begin
    if (clear) q <= {DATA_WIDTH_IN{1'b0}}; //Synchronous reset
    else if (enable) q <= BusMuxIn; //Latch bus value
	end

	//Mask output to 0 when BAout is asserted (base address uses R0 as 0)
	assign BusMuxOut = q & {DATA_WIDTH_OUT{~BAout}};
endmodule
