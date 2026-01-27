/*
`timescale 1ns/10ps
module tutorial_tb();
reg clock, clear, RZout, RAout, RBout, RAin, RBin, RZin;
reg [7:0] AddImmediate;
reg [7:0] RegisterAImmediate;

reg [3:0] present_state;

DataPath DP(
	clock, clear,
	AddImmediate,
	RegisterAImmediate,
	RZout, RAout, RBout,
	RAin, RBin, RZin
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
			clear <= 1;
			AddImmediate <= 8'h00; RegisterAImmediate <= 8'h00;
			RZout <= 0; RAout <= 0; RBout <= 0; RAin <= 0; RBin <= 0; RZin <= 0;
			#15 clear <= 0;
		end
		// ldi A, 5
		T0: begin
			RegisterAImmediate <= 8'b101; RAin <= 1;
			#15 RegisterAImmediate <= 8'h00; RAin <= 0;
		end
	// addi B, A, 5 - 2 steps
		// add value in register A and immediate 5 and then save in Z
		T1: begin
			RAout <= 1; AddImmediate <= 8'h5; RZin <= 1;
			#15 RAout <= 0; RZin <= 0;
		end
		// mv B, Z - move value in Z to B
		T2: begin
			RZout <= 1; RBin <= 1;
			#15 RZout <= 0; RBin <= 0;
		end
	endcase
end
endmodule
*/

`timescale 1ns/1ps

module bus_register_tb;

reg clock, clear;
reg R0in, R1in;
reg R0out, R1out;

wire [31:0] BusMuxOut;
wire [31:0] R0_data, R1_data;

// Clock
initial clock = 0;
always #10 clock = ~clock;

// Register instances
register R0 (
    .clear(clear),
    .clock(clock),
    .enable(R0in),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R0_data)
);

register R1 (
    .clear(clear),
    .clock(clock),
    .enable(R1in),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R1_data)
);

// Bus instance (unused inputs tied to 0)
Bus bus (
    .BusMuxIn_R0(R0_data),
    .BusMuxIn_R1(R1_data),
    .BusMuxIn_R2(32'b0), .BusMuxIn_R3(32'b0),
    .BusMuxIn_R4(32'b0), .BusMuxIn_R5(32'b0),
    .BusMuxIn_R6(32'b0), .BusMuxIn_R7(32'b0),
    .BusMuxIn_R8(32'b0), .BusMuxIn_R9(32'b0),
    .BusMuxIn_R10(32'b0), .BusMuxIn_R11(32'b0),
    .BusMuxIn_R12(32'b0), .BusMuxIn_R13(32'b0),
    .BusMuxIn_R14(32'b0), .BusMuxIn_R15(32'b0),
    .BusMuxIn_HI(32'b0), .BusMuxIn_LO(32'b0),
    .BusMuxIn_ZHI(32'b0), .BusMuxIn_ZLO(32'b0),
    .BusMuxIn_PC(32'b0), .BusMuxIn_MAR(32'b0),
    .BusMuxIn_Inport(32'b0),
    .C_sign_extended(32'b0),

    .R0out(R0out), .R1out(R1out),
    .R2out(0), .R3out(0), .R4out(0), .R5out(0),
    .R6out(0), .R7out(0), .R8out(0), .R9out(0),
    .R10out(0), .R11out(0), .R12out(0), .R13out(0),
    .R14out(0), .R15out(0),
    .HIout(0), .LOout(0), .ZHIout(0), .ZLOout(0),
    .PCout(0), .MARout(0), .Inportout(0), .Cout(0),

    .BusMuxOut(BusMuxOut)
);

// Test sequence
initial begin
    clear = 1;
    R0in = 0; R1in = 0;
    R0out = 0; R1out = 0;

    #25 clear = 0;

    // Load R0 = 10
    R0out = 0;
    R0in = 1;
    force BusMuxOut = 32'd10;
    #20;
    R0in = 0;
    release BusMuxOut;

    // Load R1 = 25
    R1in = 1;
    force BusMuxOut = 32'd25;
    #20;
    R1in = 0;
    release BusMuxOut;

    // Put R0 on bus
    R0out = 1;
    #20;
    R0out = 0;

    // Put R1 on bus
    R1out = 1;
    #20;
    R1out = 0;

    #50 $stop;
end

endmodule
