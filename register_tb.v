//TUTORIAL CODE GIVEN TB
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


//TB TO CHECK A COUPLE OF REGISTERS AND Bus
/*
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
*/

//TESTBENCH FOR DATAPATH, BUS, MEMORY, EVERYTHING BEFORE ALU
`timescale 1ns / 1ps
module tb_data_path;

//----------------------------
// Signals
//----------------------------
reg clock, clear;

// Control signals
reg R0in, R0out, R1in, R1out, R2in, R2out, R3in, R3out;
reg PCin, PCout;
reg IRin;
reg Yin, Zin;  // placeholders
reg MARin;
reg MDRin, MDRout;

// Data input to MDR
reg [31:0] Mdatain;

// Bus output
wire [31:0] BusMuxOut;

// Outputs of registers (for monitoring)
wire [31:0] BusMuxIn_R0, BusMuxIn_R1, BusMuxIn_R2, BusMuxIn_R3;
wire [31:0] BusMuxIn_PC, BusMuxIn_IR, BusMuxIn_Y, BusMuxIn_Z, BusMuxIn_MAR, BusMuxIn_MDR;

//----------------------------
// Instantiate the datapath
//----------------------------
data_path DP (
    .clock(clock),
    .clear(clear),

    // Control signals
    .R0in(R0in), .R0out(R0out),
    .R1in(R1in), .R1out(R1out),
    .R2in(R2in), .R2out(R2out),
    .R3in(R3in), .R3out(R3out),
    .PCin(PCin), .PCout(PCout),
    .IRin(IRin),
    .Yin(Yin),
    .Zin(Zin),
    .MARin(MARin),
    .MDRin(MDRin), .MDRout(MDRout),

    // Data input
    .Mdatain(Mdatain),

    // Bus output
    .BusMuxOut(BusMuxOut),

    // Register outputs
    .BusMuxIn_R0(BusMuxIn_R0),
    .BusMuxIn_R1(BusMuxIn_R1),
    .BusMuxIn_R2(BusMuxIn_R2),
    .BusMuxIn_R3(BusMuxIn_R3),
    .BusMuxIn_PC(BusMuxIn_PC),
    .BusMuxIn_IR(BusMuxIn_IR),
    .BusMuxIn_Y(BusMuxIn_Y),
    .BusMuxIn_Z(BusMuxIn_Z),
    .BusMuxIn_MAR(BusMuxIn_MAR),
    .BusMuxIn_MDR(BusMuxIn_MDR)
);

//----------------------------
// Clock generation
//----------------------------
initial clock = 0;
always #5 clock = ~clock;  // 10ns period

//----------------------------
// Test sequence
//----------------------------
initial begin
    // Initialize signals
    clear = 1;
    R0in = 0; R0out = 0; R1in = 0; R1out = 0;
    R2in = 0; R2out = 0; R3in = 0; R3out = 0;
    PCin = 0; PCout = 0; IRin = 0; Yin = 0; Zin = 0;
    MARin = 0; MDRin = 0; MDRout = 0;
    Mdatain = 32'h0;

    #10;
    clear = 0; // release reset

    //----------------------
    // Test 1: Write R0 via MDR and read on bus
    //----------------------
    $display("=== Test 1: Write R0 via MDR ===");
    Mdatain = 32'h11111111;
    MDRin = 1; #10; MDRin = 0;        // Load MDR with data
    MDRout = 1; R0in = 1; #10;        // Transfer MDR → R0
    MDRout = 0; R0in = 0;
    R0out = 1; #10;                    // Output R0 to bus
    $display("Bus = %h (expect 11111111)", BusMuxOut);
    R0out = 0;

    //----------------------
    // Test 2: Move R0 → R1
    //----------------------
    $display("=== Test 2: Move R0 → R1 ===");
    R0out = 1; R1in = 1; #10;
    R0out = 0; R1in = 0;
    R1out = 1; #10;
    $display("Bus = %h (expect 11111111)", BusMuxOut);
    R1out = 0;

    //----------------------
    // Test 3: Write R2 via MDR
    //----------------------
    $display("=== Test 3: Write R2 ===");
    Mdatain = 32'h22222222;
    MDRin = 1; #10; MDRin = 0;
    MDRout = 1; R2in = 1; #10; MDRout = 0; R2in = 0;
    R2out = 1; #10;
    $display("Bus = %h (expect 22222222)", BusMuxOut);
    R2out = 0;

    //----------------------
    // Test 4: Load PC
    //----------------------
    $display("=== Test 4: Load PC ===");
    Mdatain = 32'hAAAA5555;
    MDRin = 1; #10; MDRin = 0;
    MDRout = 1; PCin = 1; #10; MDRout = 0; PCin = 0;
    PCout = 1; #10;
    $display("Bus = %h (expect AAAA5555)", BusMuxOut);
    PCout = 0;

    //----------------------
    // Test 5: Load IR
    //----------------------
    $display("=== Test 5: Load IR ===");
    Mdatain = 32'hDEADBEEF;
    MDRin = 1; #10; MDRin = 0;
    MDRout = 1; IRin = 1; #10; MDRout = 0; IRin = 0;
    $display("IR = %h (expect DEADBEEF)", BusMuxIn_IR);

    //----------------------
    // Test 6: MDR readout to bus
    //----------------------
    $display("=== Test 6: MDR readout ===");
    Mdatain = 32'hCAFEBABE;
    MDRin = 1; #10; MDRin = 0;
    MDRout = 1; #10;
    $display("Bus = %h (expect CAFEBABE)", BusMuxOut);
    MDRout = 0;

    $display("=== Phase 1 testing complete ===");
    $finish;
end

endmodule

