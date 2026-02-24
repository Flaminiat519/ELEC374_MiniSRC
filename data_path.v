//Main Data path module
`timescale 1ns/10ps
module data_path (
	//clock and clear signal initializations
    input wire clock,
    input wire clear,
    //register read and write signals
	input wire Gra, Grb, Grc, Rin, Rout, BAout,
    //special registers enables
    input wire HIin, HIout,
    input wire LOin, LOout,
    input wire Zin, Zout, ZHIout, ZHIin,
    input wire PCin, PCout,
    input wire MARin, MARout,
    input wire MDRin, MDRout,
    input wire IRin, IRout,
    input wire Yin, Yout,
	input wire OUTPORT_In, INPORT_Out, OUTPORT_Out,
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
    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, PC, MAR, MDR, IR, Y, Z, ZHI;
	wire [31:0] INPORT, OUTPORT;
	//internal bus wire
    wire [31:0] Bus;
    //alu initialization
    wire [63:0] ALU_Data;
    wire [12:0] alu_op;
	ALU alu (.RA(Y), .RB(Bus), .ALU_op(alu_op), .RZ(ALU_Data));
	//Select and encode logic initialization
	wire [15:0] Rin_signals, Rout_signals;
	wire [31:0] C;
	select_and_encode_logic selectandencode (.IR(IR), .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout), .C(C), .R_in(Rin_signals), .R_out(Rout_signals));
	//wires for the input and output ports
	wire [31:0] INPORT_Data;
	wire [31:0] OUTPORT_Data;

	
	//idk
	
	wire Mux_Out;
	

	wire CON;
	wire [31:0] mem_data_out;
	wire PC_enable;
	assign PC_enable = PCin & CON;   // branch gating

	//special z registers (HI AND LO)
    register Z_reg (.clear(clear), .clock(clock), .enable(Zin), .BusMuxIn(ALU_Data[31:0]), .BusMuxOut(Z));
	register ZHI_reg (.clear(clear), .clock(clock), .enable(ZHIin), .BusMuxIn(ALU_Data[63:32]), .BusMuxOut(ZHI));

	//special register 0
	register0 R0_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[0]), .BAout(BAout), .BusMuxIn(Bus), .BusMuxOut(R0));
    //general purpose registers
    register R1_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[1]),  .BusMuxIn(Bus), .BusMuxOut(R1));
    register R2_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[2]),  .BusMuxIn(Bus), .BusMuxOut(R2));
    register R3_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[3]),  .BusMuxIn(Bus), .BusMuxOut(R3));
    register R4_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[4]),  .BusMuxIn(Bus), .BusMuxOut(R4));
    register R5_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[5]),  .BusMuxIn(Bus), .BusMuxOut(R5));
    register R6_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[6]),  .BusMuxIn(Bus), .BusMuxOut(R6));
    register R7_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[7]),  .BusMuxIn(Bus), .BusMuxOut(R7));
    register R8_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[8]),  .BusMuxIn(Bus), .BusMuxOut(R8));
    register R9_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[9]),  .BusMuxIn(Bus), .BusMuxOut(R9));
    register R10_reg (.clear(clear), .clock(clock), .enable(Rin_signals[10]), .BusMuxIn(Bus), .BusMuxOut(R10));
    register R11_reg (.clear(clear), .clock(clock), .enable(Rin_signals[11]), .BusMuxIn(Bus), .BusMuxOut(R11));
    register R12_reg (.clear(clear), .clock(clock), .enable(Rin_signals[12]), .BusMuxIn(Bus), .BusMuxOut(R12));
    register R13_reg (.clear(clear), .clock(clock), .enable(Rin_signals[13]), .BusMuxIn(Bus), .BusMuxOut(R13));
    register R14_reg (.clear(clear), .clock(clock), .enable(Rin_signals[14]), .BusMuxIn(Bus), .BusMuxOut(R14));
    register R15_reg (.clear(clear), .clock(clock), .enable(Rin_signals[15]), .BusMuxIn(Bus), .BusMuxOut(R15));
	//general purpose registers for Inport and Outport
	register INPORT_reg (.clear(clear), .clock(clock), .enable(INPORT_In), .BusMuxIn(MDatain), .BusMuxOut(INPORT));
	register OUTPORT_reg (.clear(clear), .clock(clock), .enable(OUTPORT_In), .BusMuxIn(Bus), .BusMuxOut(OUTPORT));
    //special general registers HI/LO get ALU_Data directly
    register HI_reg (.clear(clear), .clock(clock), .enable(HIin), .BusMuxIn(Bus), .BusMuxOut(HI));
	register LO_reg (.clear(clear), .clock(clock), .enable(LOin), .BusMuxIn(Bus), .BusMuxOut(LO));
    register Y_reg   (.clear(clear), .clock(clock), .enable(Yin),  .BusMuxIn(Bus), .BusMuxOut(Y));
    register IR_reg  (.clear(clear), .clock(clock), .enable(IRin), .BusMuxIn(Bus), .BusMuxOut(IR));
    register MAR_reg (.clear(clear), .clock(clock), .enable(MARin), .BusMuxIn(Bus), .BusMuxOut(MAR));
	//special register modules
    pc_reg PC_reg (.D(Bus),.clk(clock),.clr(clear),.increment(IncPC),.enable(PCin),.Q(PC));
    //mdr_reg MDR_reg (.BusMuxIn(Bus),.clk(clock),.clr(clear),.Read(Read),.MDRin(MDRin),.MDAtain(MDatain),.Q(MDR));
	mdr_reg MDR_reg (
    .BusMuxIn(Bus),
    .clk(clock),
    .clr(clear),
    .Read(Read),
    .MDRin(MDRin),
    .MDatain(mem_data_out),
    .Q(MDR)
	);
	
	//Memory modules
	ram RAM (.clk(clock),
    .read(Read),
    .write(Write),
    .address(MAR[8:0]),
    .data_in(MDR),
    .data_out(mem_data_out));
	//conditional logic modules
	con_ff CON_unit (
    .clk(clock),
    .clear(clear),
    .CONin(CON_In),
    .C2(IR[20:19]),
    .Bus_Data(Bus),
	.CON(CON)
	);

    //BusMux initialization
    Bus BUS (
        .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .R8(R8), .R9(R9), .R10(R10), .R11(R11), .R12(R12), .R13(R13), .R14(R14), .R15(R15),
        .HI(HI), .LO(LO), .Z(Z), .ZHI(ZHI), .PC(PC), .MAR(MAR), .MDR(MDR), .IR(IR), .Y(Y),
		.INPORT(INPORT),
        .R0out(Rout_signals[0]), .R1out(Rout_signals[1]), .R2out(Rout_signals[2]),
        .R3out(Rout_signals[3]), .R4out(Rout_signals[4]), .R5out(Rout_signals[5]), .R6out(Rout_signals[6]), .R7out(Rout_signals[7]),
        .R8out(Rout_signals[8]), .R9out(Rout_signals[9]), .R10out(Rout_signals[10]), .R11out(Rout_signals[11]), .R12out(Rout_signals[12]),
        .R13out(Rout_signals[13]), .R14out(Rout_signals[14]), .R15out(Rout_signals[15]),
        .HIout(HIout), .LOout(LOout), .Zout(Zout), .ZHIout(ZHIout), .PCout(PCout), .MARout(MARout),
        .MDRout(MDRout), .IRout(IRout), .Yout(Yout),
		.INPORTout(INPORT_Out),
        .BusMuxOut(Bus)
    );

	//create bus?
    assign BusMuxOut = Bus;

endmodule
