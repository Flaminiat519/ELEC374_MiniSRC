//Datapath — contains all registers, ALU, bus, and memory; controlled by the control unit
`timescale 1ns/10ps
module data_path (
	//Clock and reset
	input wire clock,
	input wire clear,
	//General-purpose register read/write select signals
	input wire Gra, Grb, Grc, Rin, Rout, BAout,
	//Special register enable signals
	input wire HIin, HIout,
	input wire LOin, LOout,
	input wire Zin, Zout, ZHIout, ZHIin,
	input wire PCin, PCout,
	input wire MARin, MARout,
	input wire MDRin, MDRout,
	input wire IRin, IRout,
	input wire Yin, Yout,
	input wire OUTPORT_In, INPORT_Out, OUTPORT_Out,
	input wire Cout,
	//External control signals
	input wire IncPC,
	input wire Read,
	input wire Write,
	input wire [31:0] MDatain,
	//External I/O ports
	input wire [31:0] Inport, //Connected to input switches
	output wire [31:0] Outport, //Connected to seven-segment display
	//Bus and IR outputs for the control unit
	output wire [31:0] BusMuxOut,
	output wire [31:0] IR_out,
	//Conditional branch control
	input wire CON_In,
	input wire CON_Out,
	//ALU operation select
	input wire [12:0] alu_op
);
	//General-purpose register outputs
	wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
	wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
	//Special register outputs
	wire [31:0] HI, LO, PC, MAR, MDR, IR, Y, Z, ZHI;
	wire [31:0] INPORT, OUTPORT;
	//Shared internal bus
	wire [31:0] Bus;
	//ALU 64-bit result (upper half used for MUL/DIV)
	wire [63:0] ALU_Data;
	//Register file select/encode outputs
	wire [15:0] Rin_signals, Rout_signals;
	//Sign-extended constant from IR
	wire [31:0] C;

	//ALU — takes Y and Bus as operands, produces a 64-bit result
	ALU alu (.RA(Y), .RB(Bus), .ALU_op(alu_op), .RZ(ALU_Data));

	//Select and encode logic — decodes IR fields into register enable signals
	select_and_encode_logic selectandencode (.IR(IR), .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout), .C(C), .R_in(Rin_signals), .R_out(Rout_signals));

	//CON flip-flop output and gated PC enable for conditional branching
	wire CON;
	wire [31:0] mem_data_out;
	wire PC_enable;
	assign PC_enable = PCin & (~CON_Out | CON); // Only update PC if branch condition is met

	//Z registers — latch the low and high words of the ALU result
	register Z_reg   (.clear(clear), .clock(clock), .enable(Zin),   .BusMuxIn(ALU_Data[31:0]),  .BusMuxOut(Z));
	register ZHI_reg (.clear(clear), .clock(clock), .enable(ZHIin), .BusMuxIn(ALU_Data[63:32]), .BusMuxOut(ZHI));

	//R0 uses a special register that forces 0 when BAout is asserted
	register0 R0_reg  (.clear(clear), .clock(clock), .enable(Rin_signals[0]), .BAout(BAout), .BusMuxIn(Bus), .BusMuxOut(R0));
	//General-purpose registers R1–R15
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

	//INPORT is always latching; OUTPORT latches from bus when OUTPORT_In is asserted
	register INPORT_reg  (.clear(clear), .clock(clock), .enable(1'b1),       .BusMuxIn(Inport), .BusMuxOut(INPORT));
	register OUTPORT_reg (.clear(clear), .clock(clock), .enable(OUTPORT_In), .BusMuxIn(Bus),    .BusMuxOut(OUTPORT));
	assign Outport = OUTPORT;

	//HI/LO latch from the bus (written explicitly by MFHI/MFLO or MUL/DIV sequences)
	register HI_reg (.clear(clear), .clock(clock), .enable(HIin), .BusMuxIn(Bus), .BusMuxOut(HI));
	register LO_reg (.clear(clear), .clock(clock), .enable(LOin), .BusMuxIn(Bus), .BusMuxOut(LO));
	//Remaining special registers
	register Y_reg   (.clear(clear), .clock(clock), .enable(Yin),   .BusMuxIn(Bus), .BusMuxOut(Y));
	register IR_reg  (.clear(clear), .clock(clock), .enable(IRin),  .BusMuxIn(Bus), .BusMuxOut(IR));
	register MAR_reg (.clear(clear), .clock(clock), .enable(MARin), .BusMuxIn(Bus), .BusMuxOut(MAR));

	//PC — supports increment and conditional enable for branching
	pc_reg PC_reg (.D(Bus), .clk(clock), .clr(clear), .increment(IncPC), .enable(PC_enable), .Q(PC));

	//MDR — can load from bus or directly from memory depending on Read
	mdr_reg MDR_reg (
		.BusMuxIn(Bus),
		.clk(clock),
		.clr(clear),
		.Read(Read),
		.MDRin(MDRin),
		.MDatain(mem_data_out),
		.Q(MDR)
	);

	//RAM — addressed by MAR, reads/writes MDR
	ram RAM (
		.clk(clock),
		.read(Read),
		.write(Write),
		.address(MAR[8:0]),
		.data_in(MDR),
		.data_out(mem_data_out)
	);

	//Conditional flip-flop — evaluates branch condition from IR and bus data
	con_ff CON_unit (
		.clk(clock),
		.clear(clear),
		.CONin(CON_In),
		.C2(IR[20:19]),
		.Bus_Data(Bus),
		.CON(CON)
	);

	//Bus multiplexer — selects which register drives the shared bus
	Bus BUS (
		.R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
		.R8(R8), .R9(R9), .R10(R10), .R11(R11), .R12(R12), .R13(R13), .R14(R14), .R15(R15),
		.HI(HI), .LO(LO), .Z(Z), .ZHI(ZHI), .PC(PC), .MAR(MAR), .MDR(MDR), .IR(IR), .Y(Y), .C_sign_extended(C),
		.INPORT(INPORT),
		.R0out(Rout_signals[0]),   .R1out(Rout_signals[1]),   .R2out(Rout_signals[2]),
		.R3out(Rout_signals[3]),   .R4out(Rout_signals[4]),   .R5out(Rout_signals[5]),
		.R6out(Rout_signals[6]),   .R7out(Rout_signals[7]),   .R8out(Rout_signals[8]),
		.R9out(Rout_signals[9]),   .R10out(Rout_signals[10]), .R11out(Rout_signals[11]),
		.R12out(Rout_signals[12]), .R13out(Rout_signals[13]), .R14out(Rout_signals[14]),
		.R15out(Rout_signals[15]),
		.HIout(HIout), .LOout(LOout), .Zout(Zout), .ZHIout(ZHIout), .PCout(PCout), .MARout(MARout),
		.MDRout(MDRout), .IRout(IRout), .Yout(Yout),
		.INPORTout(INPORT_Out), .Cout(Cout),
		.BusMuxOut(Bus)
	);

	//Expose bus and IR to the control unit
	assign BusMuxOut = Bus;
	assign IR_out = IR;

endmodule
