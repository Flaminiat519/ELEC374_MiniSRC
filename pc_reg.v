`timescale 1ns/10ps

module pc_register #(parameter INIT = 32'h0)(
	input wire [31:0] D,
	input wire clk,
	input	wire clr,
	input wire increment,
	input wire enable,
	output wire [31:0] Q
	);
	
	reg [31:0] qTemp;
	initial qTemp = INIT;
	always @ (posedge clk) 
		begin
			if (clr) begin
				qTemp <= 0;
			end
			else if (enable) begin
				qTemp <= D;
			end
			else if (increment) begin
				qTemp <= Q + 1;
			end
		end
	assign Q = qTemp;
endmodule 