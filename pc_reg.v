//PC register — supports load, increment, and reset; uses a CLA adder for incrementing
`timescale 1ns/10ps
module pc_reg #(parameter INIT = 32'h0)(
	input wire [31:0] D,
	input wire clk,
	input wire clr,
	input wire increment,
	input wire enable,
	output wire [31:0] Q
);
	reg [31:0] qTemp;
	initial qTemp = INIT;

	//Precompute PC+1 using the CLA adder
	wire [31:0] q_plus_one;
	CLA_32 pc_adder (Q, 32'h00000001, 1'b0, q_plus_one, );

	always @(posedge clk) begin
		if (clr)
			qTemp <= 0; //Synchronous reset
		else if (enable)
			qTemp <= D; //Load new value from bus
		else if (increment)
			qTemp <= q_plus_one; //Advance to next instruction
	end

	assign Q = qTemp;
endmodule
