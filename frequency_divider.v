//Frequency divider — scales the 50MHz clock down for CPU operation
`timescale 1ns/10ps
module frequency_divider(
	input wire CLOCK_50,
	input wire reset,
	output reg div_clk
);
	reg [31:0] counter;

	//Toggle div_clk every 500 cycles, giving a divided clock period of 1000 cycles
	always @(posedge CLOCK_50 or posedge reset) begin
		if (reset) begin
			counter <= 0;
			div_clk <= 0;
		end else begin
			if (counter == 3'd500) begin
				div_clk <= ~div_clk;
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
	end

endmodule
