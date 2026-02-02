module data_path (
    input wire clock,
    input wire clear,

    // Register write enables
    input wire R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,

    // Register output enables
    input wire R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,

    // Special registers
    input wire HIin, HIout,
    input wire LOin, LOout,
    input wire Zin, Zout,
    input wire PCin, PCout,
    input wire MARin, MARout,
    input wire MDRin, MDRout,
    input wire IRin, IRout,
    input wire Yin, Yout,

    // External control
    input wire IncPC,
    input wire Read,
    input wire [31:0] MDatain,

    output wire [31:0] BusMuxOut
);

    // Registers
    reg [31:0] R0, RA, RB, R1, R2, R3, R4, R5, R6, R7,
               R8, R9, R10, R11, R12, R13, R14, R15,
               HI, LO, Z, PC, MAR, MDR, IR, Y;

    // ALU
    wire [63:0] ALU_Data;
    wire [12:0] alu_op;
    ALU alu (.RA(RA), .RB(RB), .ALU_op(alu_op), .RZ(ALU_Data));

    // Connect Z register to ALU lower 32 bits (can adjust if needed)
    always @(posedge clock or posedge clear) begin
        if (clear)
            Z <= 32'b0;
        else if (Zin)
            Z <= ALU_Data[31:0];
    end

    // General purpose and special registers
    register R0_reg (.clear(clear), .clock(clock), .enable(R0in), .BusMuxOut(BusMuxOut), .BusMuxIn(R0));
    register RA_reg (.clear(clear), .clock(clock), .enable(RAin), .BusMuxOut(BusMuxOut), .BusMuxIn(RA));
    register RB_reg (.clear(clear), .clock(clock), .enable(RBin), .BusMuxOut(BusMuxOut), .BusMuxIn(RB));
    register R1_reg (.clear(clear), .clock(clock), .enable(R1in), .BusMuxOut(BusMuxOut), .BusMuxIn(R1));
    register R2_reg (.clear(clear), .clock(clock), .enable(R2in), .BusMuxOut(BusMuxOut), .BusMuxIn(R2));
    register R3_reg (.clear(clear), .clock(clock), .enable(R3in), .BusMuxOut(BusMuxOut), .BusMuxIn(R3));
    register R4_reg (.clear(clear), .clock(clock), .enable(R4in), .BusMuxOut(BusMuxOut), .BusMuxIn(R4));
    register R5_reg (.clear(clear), .clock(clock), .enable(R5in), .BusMuxOut(BusMuxOut), .BusMuxIn(R5));
    register R6_reg (.clear(clear), .clock(clock), .enable(R6in), .BusMuxOut(BusMuxOut), .BusMuxIn(R6));
    register R7_reg (.clear(clear), .clock(clock), .enable(R7in), .BusMuxOut(BusMuxOut), .BusMuxIn(R7));
    register R8_reg (.clear(clear), .clock(clock), .enable(R8in), .BusMuxOut(BusMuxOut), .BusMuxIn(R8));
    register R9_reg (.clear(clear), .clock(clock), .enable(R9in), .BusMuxOut(BusMuxOut), .BusMuxIn(R9));
    register R10_reg (.clear(clear), .clock(clock), .enable(R10in), .BusMuxOut(BusMuxOut), .BusMuxIn(R10));
    register R11_reg (.clear(clear), .clock(clock), .enable(R11in), .BusMuxOut(BusMuxOut), .BusMuxIn(R11));
    register R12_reg (.clear(clear), .clock(clock), .enable(R12in), .BusMuxOut(BusMuxOut), .BusMuxIn(R12));
    register R13_reg (.clear(clear), .clock(clock), .enable(R13in), .BusMuxOut(BusMuxOut), .BusMuxIn(R13));
    register R14_reg (.clear(clear), .clock(clock), .enable(R14in), .BusMuxOut(BusMuxOut), .BusMuxIn(R14));
    register R15_reg (.clear(clear), .clock(clock), .enable(R15in), .BusMuxOut(BusMuxOut), .BusMuxIn(R15));

    register HI_reg (.clear(clear), .clock(clock), .enable(HIin), .BusMuxOut(BusMuxOut), .BusMuxIn(HI));
    register LO_reg (.clear(clear), .clock(clock), .enable(LOin), .BusMuxOut(BusMuxOut), .BusMuxIn(LO));
    register Y_reg (.clear(clear), .clock(clock), .enable(Yin), .BusMuxOut(BusMuxOut), .BusMuxIn(Y));
    register IR_reg (.clear(clear), .clock(clock), .enable(IRin), .BusMuxOut(BusMuxOut), .BusMuxIn(IR));
    register MAR_reg (.clear(clear), .clock(clock), .enable(MARin), .BusMuxOut(BusMuxOut), .BusMuxIn(MAR));

    pc_reg PC_reg (.D(BusMuxOut), .clk(clock), .clr(clear), .increment(IncPC), .enable(PCin), .Q(PC));
    mdr_reg MDR_reg (.BusMuxOut(BusMuxOut), .clk(clock), .clr(clear), .Read(Read), .MDRin(MDRin), .MDAtain(MDatain), .Q(MDR));

    // Bus
    Bus BUS (
        R0, RA, RB, R1, R2, R3, R4, R5, R6, R7,
        R8, R9, R10, R11, R12, R13, R14, R15,
        HI, LO, Z, PC, MAR, MDR, IR, Y,

        R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
        R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
        HIout, LOout, Zout, PCout, MARout, MDRout, IRout, Yout,

        BusMuxOut
    );

endmodule
