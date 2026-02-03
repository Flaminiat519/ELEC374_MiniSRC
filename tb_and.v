`timescale 1ns/10ps
module and_tb;

    // -----------------------
    // Clock
    // -----------------------
    reg clock;
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // -----------------------
    // Control signals
    // -----------------------
    reg PCout, PCin, IncPC;
    reg MARin, MDRin, IRin;
    reg R2in, R5in, R6in;
    reg R5out, R6out, MDRout, Zout;
    reg Yin, Zin, Read;

    reg [12:0] ALU_op;

    // -----------------------
    // Wires
    // -----------------------
    wire [31:0] Bus;
    wire [31:0] R2, R5, R6;
    wire [31:0] Yreg;
    wire [31:0] Zreg;
    wire [63:0] ALU_Z;

    // -----------------------
    // Registers
    // -----------------------
    register R5_reg (.clear(0), .clock(clock), .enable(R5in), .BusMuxOut(32'hF0F0F0F0), .BusMuxIn(R5));
    register R6_reg (.clear(0), .clock(clock), .enable(R6in), .BusMuxOut(32'h0FF00FF0), .BusMuxIn(R6));
    register R2_reg (.clear(0), .clock(clock), .enable(R2in), .BusMuxOut(Bus), .BusMuxIn(R2));

    register Y_reg  (.clear(0), .clock(clock), .enable(Yin), .BusMuxOut(Bus), .BusMuxIn(Yreg));
    register Z_reg  (.clear(0), .clock(clock), .enable(Zin), .BusMuxOut(ALU_Z[31:0]), .BusMuxIn(Zreg));

    register PC_reg (.clear(0), .clock(clock), .enable(PCin), .BusMuxOut(Bus), .BusMuxIn());
    register MAR_reg(.clear(0), .clock(clock), .enable(MARin), .BusMuxOut(Bus), .BusMuxIn());
    register MDR_reg(.clear(0), .clock(clock), .enable(MDRin), .BusMuxOut(32'h00000000), .BusMuxIn());
    register IR_reg (.clear(0), .clock(clock), .enable(IRin), .BusMuxOut(Bus), .BusMuxIn());

    // -----------------------
    // ALU (Y op Bus)
    // -----------------------
    ALU alu_inst (
        .RA(Yreg),
        .RB(Bus),
        .ALU_op(ALU_op),
        .RZ(ALU_Z)
    );

    // -----------------------
    // Bus
    // -----------------------
    Bus bus_inst (
        .RA(32'b0), .RB(32'b0), .R0(32'b0),
        .R1(32'b0), .R2(R2), .R3(32'b0), .R4(32'b0),
        .R5(R5), .R6(R6), .R7(32'b0),
        .R8(32'b0), .R9(32'b0), .R10(32'b0), .R11(32'b0),
        .R12(32'b0), .R13(32'b0), .R14(32'b0), .R15(32'b0),
        .HI(32'b0), .LO(32'b0), .Z(Zreg),
        .PC(32'b0), .MAR(32'b0), .MDR(32'b0),
        .IR(32'b0), .Y(Yreg),

        .RAout(0), .RBout(0), .R0out(0),
        .R1out(0), .R2out(0), .R3out(0), .R4out(0),
        .R5out(R5out), .R6out(R6out), .R7out(0),
        .R8out(0), .R9out(0), .R10out(0), .R11out(0),
        .R12out(0), .R13out(0), .R14out(0), .R15out(0),
        .HIout(0), .LOout(0), .Zout(Zout),
        .PCout(PCout), .MARout(0), .MDRout(MDRout),
        .IRout(0), .Yout(0),

        .BusMuxOut(Bus)
    );

    // -----------------------
    // Control Sequence T0–T5
    // -----------------------
    initial begin
        // Init
        {PCout, PCin, IncPC, MARin, MDRin, IRin,
         R2in, R5in, R6in, R5out, R6out, MDRout,
         Yin, Zin, Zout, Read} = 0;

        ALU_op = 0;

        // -----------------------
        // T0: PCout, MARin, IncPC, Zin
        // -----------------------
        #20 PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
        #20 PCout = 0; MARin = 0; IncPC = 0; Zin = 0;

        // -----------------------
        // T1: Zlowout, PCin, Read, MDRin
        // -----------------------
        #20 Zout = 1; PCin = 1; Read = 1; MDRin = 1;
        #20 Zout = 0; PCin = 0; Read = 0; MDRin = 0;

        // -----------------------
        // T2: MDRout, IRin
        // -----------------------
        #20 MDRout = 1; IRin = 1;
        #20 MDRout = 0; IRin = 0;

        // -----------------------
        // T3: R5out, Yin
        // -----------------------
        #20 R5out = 1; Yin = 1;
        #20 R5out = 0; Yin = 0;

        // -----------------------
        // T4: R6out, AND, Zin
        // -----------------------
        #20 R6out = 1; ALU_op = 13'b1; Zin = 1;
        #20 R6out = 0; Zin = 0;

        // -----------------------
        // T5: Zlowout, R2in
        // -----------------------
        #20 Zout = 1; R2in = 1;
        #20 Zout = 0; R2in = 0;

        #50 $finish;
    end

endmodule
