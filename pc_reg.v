/*//Special PC register module
`timescale 1ns/10ps

module pc_reg #(parameter INIT = 32'h0)(
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
endmodule */
//Special PC register module
`timescale 1ns/10ps
module pc_reg #(parameter INIT = 32'h0)(
	input wire [31:0] D,
	input wire clk,
	input	wire clr,
	input wire increment,
	input wire enable,
	output wire [31:0] Q
);
	
reg [31:0] qTemp;
initial qTemp = INIT;

wire [31:0] q_plus_one;
CLA_32 pc_adder (Q, 32'h00000001, 1'b0, q_plus_one, );

	always @ (posedge clk) 
		begin
			if (clr) begin
				qTemp <= 0;
			end
			else if (enable) begin
				qTemp <= D;
			end
			else if (increment) begin
				qTemp <= q_plus_one;
			end
		end
	assign Q = qTemp;
endmodule
