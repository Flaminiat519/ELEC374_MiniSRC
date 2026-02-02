module data_path (
    input wire clock,
    input wire clear,

    //Register write enables
    input wire R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,

    //Register output enables
    input wire R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,

    //Special registers
    input wire HIin, HIout,
    input wire LOin, LOout,
    input wire Zin,  Zout,
    input wire PCin, PCout,
    input wire MARin, MARout,
    input wire MDRin, MDRout,
    input wire IRin, IRout,
    input wire Yin,  Yout,

    //External control
    input wire IncPC,
    input wire Read,
    input wire [31:0] MDatain,

    output wire [31:0] BusMuxOut
);

    //Internal wires (Bus inputs)
    wire [31:0] BusMux_R0,  BusMux_RA,  BusMux_RB,  BusMux_R1;
    wire [31:0] BusMux_R2,  BusMux_R3,  BusMux_R4,  BusMux_R5;
    wire [31:0] BusMux_R6,  BusMux_R7,  BusMux_R8,  BusMux_R9;
    wire [31:0] BusMux_R10, BusMux_R11, BusMux_R12, BusMux_R13;
    wire [31:0] BusMux_R14, BusMux_R15;
    wire [31:0] BusMux_HI, BusMux_LO, BusMux_ZHI, BusMux_ZLO;
    wire [31:0] BusMux_PC, BusMux_MAR, BusMux_MDR, BusMux_IR, BusMux_Y;

    // Registers
    reg [31:0]
        R0, RA, RB, R1, R2, R3, R4, R5, R6, R7,
        R8, R9, R10, R11, R12, R13, R14, R15,
        HI, LO, Z, PC, MAR, MDR, IR, Y;

    // ALU
    wire [63:0] ALU_Data;
    wire [12:0] alu_op;

    ALU alu (
    .RA(RA),
    .RB(RB),
    .ALU_op(alu_op),
    .RZ(ALU_Data)
);

    //Register modules
    // General purpose registers
register R0_reg (
    .clear(clear), .clock(clock), .enable(R0in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R0)
);
register RA_reg (
    .clear(clear), .clock(clock), .enable(RAin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_RA)
);
register RB_reg (
    .clear(clear), .clock(clock), .enable(RBin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_RB)
);
register R1_reg (
    .clear(clear), .clock(clock), .enable(R1in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R1)
);
register R2_reg (
    .clear(clear), .clock(clock), .enable(R2in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R2)
);
register R3_reg (
    .clear(clear), .clock(clock), .enable(R3in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R3)
);
register R4_reg (
    .clear(clear), .clock(clock), .enable(R4in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R4)
);
register R5_reg (
    .clear(clear), .clock(clock), .enable(R5in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R5)
);
register R6_reg (
    .clear(clear), .clock(clock), .enable(R6in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R6)
);
register R7_reg (
    .clear(clear), .clock(clock), .enable(R7in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R7)
);
register R8_reg (
    .clear(clear), .clock(clock), .enable(R8in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R8)
);
register R9_reg (
    .clear(clear), .clock(clock), .enable(R9in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R9)
);
register R10_reg (
    .clear(clear), .clock(clock), .enable(R10in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R10)
);
register R11_reg (
    .clear(clear), .clock(clock), .enable(R11in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R11)
);
register R12_reg (
    .clear(clear), .clock(clock), .enable(R12in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R12)
);
register R13_reg (
    .clear(clear), .clock(clock), .enable(R13in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R13)
);
register R14_reg (
    .clear(clear), .clock(clock), .enable(R14in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R14)
);
register R15_reg (
    .clear(clear), .clock(clock), .enable(R15in),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_R15)
);

// Special registers
register HI_reg (
    .clear(clear), .clock(clock), .enable(HIin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_HI)
);
register LO_reg (
    .clear(clear), .clock(clock), .enable(LOin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_LO)
);
register Y_reg (
    .clear(clear), .clock(clock), .enable(Yin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_Y)
);
register IR_reg (
    .clear(clear), .clock(clock), .enable(IRin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_IR)
);
register MAR_reg (
    .clear(clear), .clock(clock), .enable(MARin),
    .BusMuxOut(BusMuxOut), .BusMuxIn(BusMux_MAR)
);

// Z register split into high and low
register ZHI_reg (
    .clear(clear), .clock(clock), .enable(Zin),
    .BusMuxOut(ALU_Data[63:32]), .BusMuxIn(BusMux_ZHI)
);
register ZLO_reg (
    .clear(clear), .clock(clock), .enable(Zin),
    .BusMuxOut(ALU_Data[31:0]), .BusMuxIn(BusMux_ZLO)
);

// PC register (special module)
pc_reg PC_reg (
    .D(BusMuxOut),        // 32-bit input to PC
    .clk(clock),           // clock
    .clr(clear),           // reset
    .increment(IncPC),     // increment signal
    .enable(PCin),         // write enable
    .Q(BusMux_PC)          // 32-bit PC output
);

// MDR register (special module)
mdr_reg MDR_reg (
    .BusMuxOut(BusMuxOut),
    .clk(clock),
    .clr(clear),
    .Read(Read),
    .MDRin(MDRin),
    .MDAtain(MDatain),
    .Q(BusMux_MDR)
);


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
