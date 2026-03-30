//Frequency Divider
`timescale 1ns/10ps

module frequency_divider(
	input wire CLOCK_50,
	input wire reset,
	output reg div_clk
);

	reg [2:0] counter;
	
	always @(posedge CLOCK_50 or posedge reset) begin
		if(reset) begin
			counter <= 0;
			div_clk <= 0;
		end else begin
			if(counter == 3'd3) begin
				div_clk <= ~div_clk;
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end 
		end
	end
	
endmodule