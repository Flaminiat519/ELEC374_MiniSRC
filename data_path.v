//Main Data path module
`timescale 1ns/10ps
module data_path (
	//clock and clear signal initializations
    input wire clock,
    input wire clear,
    //register write enables
    input wire R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    //register output enables
    input wire R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    //special registers enables
    input wire HIin, HIout,
    input wire LOin, LOout,
    input wire Zin, Zout, ZHIout, ZHIin,
    input wire PCin, PCout,
    input wire MARin, MARout,
    input wire MDRin, MDRout,
    input wire IRin, IRout,
    input wire Yin, Yout,
    //special external control enables
    input wire IncPC,
    input wire Read,
	input wire Write,
    input wire [31:0] MDatain,
    output wire [31:0] BusMuxOut,
	
	//Memory control enables
	//Conditional Logic Control Enables
	input wire CON_In,
	input wire CON_Out
);
    //internal wires for registers
    wire [31:0] R0, RA, RB, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, PC, MAR, MDR, IR, Y, Z, ZHI;
	//internal bus wire
    wire [31:0] Bus;
    //alu initialization
    wire [63:0] ALU_Data;
    wire [12:0] alu_op;
	ALU alu (.RA(Y), .RB(Bus), .ALU_op(alu_op), .RZ(ALU_Data));
	
	//idk
	wire [31:0] memory_out;
	wire Mux_Out;

	//special z registers (HI AND LO)
    register Z_reg (.clear(clear), .clock(clock), .enable(Zin), .BusMuxIn(ALU_Data[31:0]), .BusMuxOut(Z));
	register ZHI_reg (.clear(clear), .clock(clock), .enable(ZHIin), .BusMuxIn(ALU_Data[63:32]), .BusMuxOut(ZHI));
	
    //general purpose registers
    register R0_reg  (.clear(clear), .clock(clock), .enable(R0in),  .BusMuxIn(Bus), .BusMuxOut(R0));
    register RA_reg  (.clear(clear), .clock(clock), .enable(RAin),  .BusMuxIn(Bus), .BusMuxOut(RA));
    register RB_reg  (.clear(clear), .clock(clock), .enable(RBin),  .BusMuxIn(Bus), .BusMuxOut(RB));
    register R1_reg  (.clear(clear), .clock(clock), .enable(R1in),  .BusMuxIn(Bus), .BusMuxOut(R1));
    register R2_reg  (.clear(clear), .clock(clock), .enable(R2in),  .BusMuxIn(Bus), .BusMuxOut(R2));
    register R3_reg  (.clear(clear), .clock(clock), .enable(R3in),  .BusMuxIn(Bus), .BusMuxOut(R3));
    register R4_reg  (.clear(clear), .clock(clock), .enable(R4in),  .BusMuxIn(Bus), .BusMuxOut(R4));
    register R5_reg  (.clear(clear), .clock(clock), .enable(R5in),  .BusMuxIn(Bus), .BusMuxOut(R5));
    register R6_reg  (.clear(clear), .clock(clock), .enable(R6in),  .BusMuxIn(Bus), .BusMuxOut(R6));
    register R7_reg  (.clear(clear), .clock(clock), .enable(R7in),  .BusMuxIn(Bus), .BusMuxOut(R7));
    register R8_reg  (.clear(clear), .clock(clock), .enable(R8in),  .BusMuxIn(Bus), .BusMuxOut(R8));
    register R9_reg  (.clear(clear), .clock(clock), .enable(R9in),  .BusMuxIn(Bus), .BusMuxOut(R9));
    register R10_reg (.clear(clear), .clock(clock), .enable(R10in), .BusMuxIn(Bus), .BusMuxOut(R10));
    register R11_reg (.clear(clear), .clock(clock), .enable(R11in), .BusMuxIn(Bus), .BusMuxOut(R11));
    register R12_reg (.clear(clear), .clock(clock), .enable(R12in), .BusMuxIn(Bus), .BusMuxOut(R12));
    register R13_reg (.clear(clear), .clock(clock), .enable(R13in), .BusMuxIn(Bus), .BusMuxOut(R13));
    register R14_reg (.clear(clear), .clock(clock), .enable(R14in), .BusMuxIn(Bus), .BusMuxOut(R14));
    register R15_reg (.clear(clear), .clock(clock), .enable(R15in), .BusMuxIn(Bus), .BusMuxOut(R15));
    //special general registers HI/LO get ALU_Data directly
    register HI_reg (.clear(clear), .clock(clock), .enable(HIin), .BusMuxIn(Bus), .BusMuxOut(HI));
	register LO_reg (.clear(clear), .clock(clock), .enable(LOin), .BusMuxIn(Bus), .BusMuxOut(LO));
    register Y_reg   (.clear(clear), .clock(clock), .enable(Yin),  .BusMuxIn(Bus), .BusMuxOut(Y));
    register IR_reg  (.clear(clear), .clock(clock), .enable(IRin), .BusMuxIn(Bus), .BusMuxOut(IR));
    register MAR_reg (.clear(clear), .clock(clock), .enable(MARin), .BusMuxIn(Bus), .BusMuxOut(MAR));
	//special register modules
    pc_reg PC_reg (.D(Bus),.clk(clock),.clr(clear),.increment(IncPC),.enable(PCin),.Q(PC));
    //mdr_reg MDR_reg (.BusMuxIn(Bus),.clk(clock),.clr(clear),.Read(Read),.MDRin(MDRin),.MDAtain(MDatain),.Q(MDR));
	mdr_reg MDR_reg (.BusMuxIn(Bus), .clk(clock), .clr(clear), .Read(Read), .MDRin(MDRin), .MDAtain(memory_out), .Q(MDR));
	
	//Memory modules
	memory RAM (.clk(clock), .read(Read), .write(Write), .address(MAR[8:0]),   .data_in(MDR),.data_out(memory_out));
	//conditional logic modules
	//con_ff CON_FF (BusMux_IR[20:19], Mux_Out, CON_In, CON_Out);

    //BusMux initialization
    Bus BUS (
        .R0(R0), .RA(RA), .RB(RB), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .R8(R8), .R9(R9), .R10(R10), .R11(R11), .R12(R12), .R13(R13), .R14(R14), .R15(R15),
        .HI(HI), .LO(LO), .Z(Z), .ZHI(ZHI), .PC(PC), .MAR(MAR), .MDR(MDR), .IR(IR), .Y(Y),
        .R0out(R0out), .RAout(RAout), .RBout(RBout), .R1out(R1out), .R2out(R2out),
        .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), .R12out(R12out),
        .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIout(HIout), .LOout(LOout), .Zout(Zout), .ZHIout(ZHIout), .PCout(PCout), .MARout(MARout),
        .MDRout(MDRout), .IRout(IRout), .Yout(Yout),
        .BusMuxOut(Bus)
    );

	//create bus?
    assign BusMuxOut = Bus;

endmodule
