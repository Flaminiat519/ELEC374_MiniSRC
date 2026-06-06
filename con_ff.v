//Conditional flip-flop — evaluates a branch condition and latches the result
`timescale 1ns/10ps
module con_ff (
	input wire clk,
	input wire clear,
	input wire CONin,
    input wire [1:0] C2, //Branch condition select from IR[20:19]
	input wire [31:0] Bus_Data,
	output reg CON
);
	//Condition flag shortcuts based on the bus data
	wire zero = (Bus_Data == 32'b0);
	wire negative = Bus_Data[31];
	wire positive = (~Bus_Data[31]) & (Bus_Data != 32'b0);
	reg condition;

	//Select the condition to evaluate based on the branch type
	always @(*) begin
		case (C2)
			2'b00: condition = zero; //brzr — branch if zero
			2'b01: condition = ~zero; //brnz — branch if not zero
			2'b10: condition = positive; //brpl — branch if positive
			2'b11: condition = negative; //brmi — branch if negative
		endcase
	end

	//Latch the evaluated condition on the rising clock edge
	always @(posedge clk or posedge clear) begin
		if (clear)
			CON <= 1'b0;
		else if (CONin)
			CON <= condition;
	end
endmodule
