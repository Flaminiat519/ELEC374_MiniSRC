module data_path (
    input  wire clock,
    input  wire clear,

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
        .A(RA),
        .B(RB),
        .ALUop(alu_op),
        .Z(ALU_Data)
    );

    //Register modules
    register R0_reg  (BusMuxOut, clock, clear, R0in,  BusMux_R0);
    register RA_reg  (BusMuxOut, clock, clear, RAin,  BusMux_RA);
    register RB_reg  (BusMuxOut, clock, clear, RBin,  BusMux_RB);
    register R1_reg  (BusMuxOut, clock, clear, R1in,  BusMux_R1);
    register R2_reg  (BusMuxOut, clock, clear, R2in,  BusMux_R2);
    register R3_reg  (BusMuxOut, clock, clear, R3in,  BusMux_R3);
    register R4_reg  (BusMuxOut, clock, clear, R4in,  BusMux_R4);
    register R5_reg  (BusMuxOut, clock, clear, R5in,  BusMux_R5);
    register R6_reg  (BusMuxOut, clock, clear, R6in,  BusMux_R6);
    register R7_reg  (BusMuxOut, clock, clear, R7in,  BusMux_R7);
    register R8_reg  (BusMuxOut, clock, clear, R8in,  BusMux_R8);
    register R9_reg  (BusMuxOut, clock, clear, R9in,  BusMux_R9);
    register R10_reg (BusMuxOut, clock, clear, R10in, BusMux_R10);
    register R11_reg (BusMuxOut, clock, clear, R11in, BusMux_R11);
    register R12_reg (BusMuxOut, clock, clear, R12in, BusMux_R12);
    register R13_reg (BusMuxOut, clock, clear, R13in, BusMux_R13);
    register R14_reg (BusMuxOut, clock, clear, R14in, BusMux_R14);
    register R15_reg (BusMuxOut, clock, clear, R15in, BusMux_R15);

    register HI_reg  (BusMuxOut, clock, clear, HIin, BusMux_HI);
    register LO_reg  (BusMuxOut, clock, clear, LOin, BusMux_LO);
    register Y_reg   (BusMuxOut, clock, clear, Yin,  BusMux_Y);
    register IR_reg  (BusMuxOut, clock, clear, IRin,  BusMux_IR);
    register MAR_reg (BusMuxOut, clock, clear, MARin, BusMux_MAR);

    register ZHI_reg (ALU_Data[63:32], clock, clear, Zin, BusMux_ZHI);
    register ZLO_reg (ALU_Data[31:0],  clock, clear, Zin, BusMux_ZLO);

    pc_reg PC_reg (
        BusMuxOut, clock, clear, IncPC, PCin, BusMux_PC
    );

    mdr_reg MDR_reg (
        BusMuxOut, clock, clear, Read, MDRin, MDatain, BusMux_MDR
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
