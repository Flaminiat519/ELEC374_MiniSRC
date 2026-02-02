module data_path(
    input wire clock, clear,

);

    //control signals
    input wire R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,

    input wire R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,

    input wire HIin, HIout, LOin, LOout,
    input wire Zin, Zout,
    input wire PCin, PCout,
    input wire MARin, MARout,
    input wire MDRin, MDRout,
    input wire IRin, IRout,
    input wire Yin, Yout,

	wire [31:0] BusMux_R0;
	wire [31:0] BusMux_R1;
	wire [31:0] BusMux_R2;
	wire [31:0] BusMux_R3;
	wire [31:0] BusMux_R4;
	wire [31:0] BusMux_R5;
	wire [31:0] BusMux_R6;
	wire [31:0] BusMux_R7;
	wire [31:0] BusMux_R8;
	wire [31:0] BusMux_R9;
	wire [31:0] BusMux_R10;
	wire [31:0] BusMux_R11;
	wire [31:0] BusMux_R12;
	wire [31:0] BusMux_R13;
	wire [31:0] BusMux_R14;
	wire [31:0] BusMux_R15;
	wire [31:0] BusMux_HI;
	wire [31:0] BusMux_LO;
	wire [31:0] BusMux_ZHI;
	wire [31:0] BusMux_ZLO;
	wire [31:0] BusMux_PC;
	wire [31:0] BusMux_MDR;
	wire [31:0] BusMux_MAR;
	wire [31:0] BusMux_InPort;
	wire [31:0] BusMux_C;
	wire [31:0] BusMux_Y;
	wire [31:0] BusMux_IR;
	wire [4:0] Mux_Select;
	wire [31:0] Mux_Out;

    output wire [31:0] BusMuxOut

    //Registers
    reg [31:0]
        R0, RA, RB, R1, R2, R3, R4, R5, R6, R7,
        R8, R9, R10, R11, R12, R13, R14, R15,
        HI, LO, Z, PC, MAR, MDR, IR, Y;
    
    wire [63:0] ALU_Data;

	register RA (BusMuxOut, Clock, Clear, R2in, BusMux_RA);
	register RB (BusMuxOut, Clock, Clear, R2in, BusMux_RB);
	register R2 (BusMuxOut, Clock, Clear, R2in, BusMux_R2);
	register R4 (BusMuxOut, Clock, Clear, R4in, BusMux_R4);
	register R5 (BusMuxOut, Clock, Clear, R5in, BusMux_R5);
	register R6 (BusMuxOut, Clock, Clear, R6in, BusMux_R6);
	register R7 (BusMuxOut, Clock, Clear, R7in, BusMux_R7);

	register Y (BusMuxOut, Clock, Clear, Yin, BusMux_Y);
    register HI (BusMuxOut, Clock, Clear, HIin, BusMux_HI);
	register LO (BusMuxOut, Clock, Clear, LOin, BusMux_LO);
	register ZHI (ALU_Data[63:32], Clock, Clear, ZHIin, BusMux_ZHI);
	register ZLO (ALU_Data[31:0], Clock, Clear, ZLOin, BusMux_ZLO);
	register MAR (BusMuxOut, Clock, Clear, MARin, BusMux_MAR);
	pc_reg PC (BusMuxOut, Clock, Clear, IncPC, PCin, BusMux_PC);
	register IR (BusMuxOut, Clock, Clear, IRin, BusMux_IR);
	mdr_reg MDR (BusMuxOut, Clock, Clear, Read, MDRin, MDatain, BusMux_MDR);	
   
    always @(posedge clock or posedge clear) begin
        if (clear) begin
            R0<=0; R1<=0; R2<=0; R3<=0; R4<=0; R5<=0; R6<=0; R7<=0;
            R8<=0; R9<=0; R10<=0; R11<=0; R12<=0; R13<=0; R14<=0; R15<=0;
            HI<=0; LO<=0; Z<=0; PC<=0; MAR<=0; MDR<=0; IR<=0; Y<=0;
        end else begin
            if (R0in) R0 <= BusMuxOut;
            if (RAin) RA <= BusMuxOut;
            if (RBin) RB <= BusMuxOut;
            if (R1in) R1 <= BusMuxOut;
            if (R2in) R2 <= BusMuxOut;
            if (R3in) R3 <= BusMuxOut;
            if (R4in) R4 <= BusMuxOut;
            if (R5in) R5 <= BusMuxOut;
            if (R6in) R6 <= BusMuxOut;
            if (R7in) R7 <= BusMuxOut;
            if (R8in) R8 <= BusMuxOut;
            if (R9in) R9 <= BusMuxOut;
            if (R10in) R10 <= BusMuxOut;
            if (R11in) R11 <= BusMuxOut;
            if (R12in) R12 <= BusMuxOut;
            if (R13in) R13 <= BusMuxOut;
            if (R14in) R14 <= BusMuxOut;
            if (R15in) R15 <= BusMuxOut;
            if (HIin) HI <= BusMuxOut;
            if (LOin) LO <= BusMuxOut;
            if (Zin)  Z  <= BusMuxOut;
            if (PCin) PC <= BusMuxOut;
            if (MARin) MAR <= BusMuxOut;
            if (MDRin) MDR <= BusMuxOut;
            if (IRin) IR <= BusMuxOut;
            if (Yin)  Y  <= BusMuxOut;
        end
    end

    //ALU
    //ALU operations
    wire alu_op [12:0];
    ALU alu (RA, RB, alu_op, Z);

    
    //Bus
    Bus BUS(
        R0,R1,R2,R3,R4,R5,R6,R7,
        R8,R9,R10,R11,R12,R13,R14,R15,
        HI,LO,Z,PC,MAR,MDR,IR,Y,
        R0out,R1out,R2out,R3out,R4out,R5out,R6out,R7out,
        R8out,R9out,R10out,R11out,R12out,R13out,R14out,R15out,
        HIout,LOout,Zout,PCout,MARout,MDRout,IRout,Yout,
        BusMuxOut
    );

endmodule
