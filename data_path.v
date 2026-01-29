module data_path(

	//Control Signals 
	input wire clock, clear,
	
	input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, 
	R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, ZHIout, ZLOout, MDRout, MARout, Inportout, Cout, Outportout, PCout, IRout, Yout,
	
	input wire R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, 
	R10in, R11in, R12in, R13in, R14in, R15in, HIin, LOin, ZHIin, ZLOin, MDRin, Inportin, Outportin, Cin, PCin, IRin, Yin
	);

wire [31:0] BusMuxOut, BusMuxInRZ,
           BusMuxIn_R0, BusMuxIn_R1, BusMuxIn_R2, BusMuxIn_R3, BusMuxIn_R4,
           BusMuxIn_R5, BusMuxIn_R6, BusMuxIn_R7, BusMuxIn_R8, BusMuxIn_R9,
           BusMuxIn_R10, BusMuxIn_R11, BusMuxIn_R12, BusMuxIn_R13, BusMuxIn_R14,
           BusMuxIn_R15, BusMuxIn_HI, BusMuxIn_LO, BusMuxIn_ZHI, BusMuxIn_ZLO,
           BusMuxIn_PC, BusMuxIn_IR, BusMuxIn_MAR, BusMuxIn_MDR, BusMuxIn_Inport, C_sign_extended, BusMuxIn_Y;

wire [7:0] Zregin;

//Device Declarations
//Specific Purpose Registers
register HI(clear, clock, HIin, BusMuxOut, BusMuxIn_HI);
register LO(clear, clock, LOin, BusMuxOut, BusMuxIn_LO);
register RZ(clear, clock, RZin, Zregin, BusMuxInRZ);

pc_reg PC(clear, clock, PCin, BusMuxOut, BusMuxIn_PC);

register IR(clear, clock, IRin, BusMuxOut, BusMuxIn_IR); 
register Y(clear, clock, Yin, BusMuxOut, BusMuxIn_Y); 


//R0..R15 Registers
register R0(clear, clock, R0in, BusMuxOut, BusMuxIn_R0); //Temporary, will have to change architecture later
register R1(clear, clock, R1in, BusMuxOut, BusMuxIn_R1);
register R2(clear, clock, R2in, BusMuxOut, BusMuxIn_R2);
register R3(clear, clock, R3in, BusMuxOut, BusMuxIn_R3);
register R4(clear, clock, R4in, BusMuxOut, BusMuxIn_R4);
register R5(clear, clock, R5in, BusMuxOut, BusMuxIn_R5);
register R6(clear, clock, R6in, BusMuxOut, BusMuxIn_R6);
register R7(clear, clock, R7in, BusMuxOut, BusMuxIn_R7);
register R8(clear, clock, R8in, BusMuxOut, BusMuxIn_R8);
register R9(clear, clock, R9in, BusMuxOut, BusMuxIn_R9);
register R10(clear, clock, R10in, BusMuxOut, BusMuxIn_R10);
register R11(clear, clock, R11in, BusMuxOut, BusMuxIn_R11);
register R12(clear, clock, R12in, BusMuxOut, BusMuxIn_R12);
register R13(clear, clock, R13in, BusMuxOut, BusMuxIn_R13);
register R14(clear, clock, R14in, BusMuxOut, BusMuxIn_R14);
register R15(clear, clock, R15in, BusMuxOut, BusMuxIn_R15);

//Memory Registers
register MAR(clear, clock, MARin, BusMuxOut, BusMuxIn_MAR);
mdr_reg MDR (BusMuxOut, Clock, Clear, Read, MDRin, MDatain, BusMuxIn_MDR);	

//IO Registers
register INPORT(clear, clock, Inportin, BusMuxOut, BusMuxIn_Inport);
register OUTPORT(clear, clock, Outportin, BusMuxOut, BusMuxIn_Outport); //dont have this

//Bus
Bus data_path_bus(
	.BusMuxIn_R0(BusMuxIn_R0),
    .BusMuxIn_R1(BusMuxIn_R1),
    .BusMuxIn_R2(BusMuxIn_R2),
    .BusMuxIn_R3(BusMuxIn_R3),
    .BusMuxIn_R4(BusMuxIn_R4),
    .BusMuxIn_R5(BusMuxIn_R5),
    .BusMuxIn_R6(BusMuxIn_R6),
    .BusMuxIn_R7(BusMuxIn_R7),
    .BusMuxIn_R8(BusMuxIn_R8),
    .BusMuxIn_R9(BusMuxIn_R9),
    .BusMuxIn_R10(BusMuxIn_R10),
    .BusMuxIn_R11(BusMuxIn_R11),
    .BusMuxIn_R12(BusMuxIn_R12),
    .BusMuxIn_R13(BusMuxIn_R13),
    .BusMuxIn_R14(BusMuxIn_R14),
    .BusMuxIn_R15(BusMuxIn_R15),
    .BusMuxIn_HI(BusMuxIn_HI),
    .BusMuxIn_LO(BusMuxIn_LO),
    .BusMuxIn_ZHI(BusMuxIn_ZHI),
    .BusMuxIn_ZLO(BusMuxIn_ZLO),
    .BusMuxIn_PC(BusMuxIn_PC),
    .BusMuxIn_MAR(BusMuxIn_MAR),
    .BusMuxIn_MDR(BusMuxIn_MDR),
    .BusMuxIn_Inport(BusMuxIn_Inport),
    .C_sign_extended(C_sign_extended),
    
    .R0out(R0out),
    .R1out(R1out),
    .R2out(R2out),
    .R3out(R3out),
    .R4out(R4out),
    .R5out(R5out),
    .R6out(R6out),
    .R7out(R7out),
    .R8out(R8out),
    .R9out(R9out),
    .R10out(R10out),
    .R11out(R11out),
    .R12out(R12out),
    .R13out(R13out),
    .R14out(R14out),
    .R15out(R15out),
    .HIout(HIout),
    .LOout(LOout),
    .ZHIout(ZHIout),
    .ZLOout(ZLOout),
    .PCout(PCout),
    .MARout(MARout),
    .MDRout(MDRout),
    .Inportout(Inportout),
    .Cout(Cout),
    
    .BusMuxOut(BusMuxOut));

//ALU
//connect alu here when complete

endmodule