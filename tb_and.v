`timescale 1ns/10ps
module tb_and;

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
    reg R2in, R5in, R6in;
    reg R2out, R5out, R6out;
    reg Zin, Zout;

    reg [12:0] ALU_op;
    reg [31:0] load_val;

    // -----------------------
    // Wires
    // -----------------------
    wire [31:0] Bus;
    wire [31:0] R2, R5, R6;
    wire [63:0] ALU_Z;
    wire [31:0] Zreg;

    // -----------------------
    // Registers
    // -----------------------
    register R5_reg (
        .clear(0),
        .clock(clock),
        .enable(R5in),
        .BusMuxOut(load_val),
        .BusMuxIn(R5)
    );

    register R6_reg (
        .clear(0),
        .clock(clock),
        .enable(R6in),
        .BusMuxOut(load_val),
        .BusMuxIn(R6)
    );

    register R2_reg (
        .clear(0),
        .clock(clock),
        .enable(R2in),
        .BusMuxOut(Bus),
        .BusMuxIn(R2)
    );

    register Z_reg (
        .clear(0),
        .clock(clock),
        .enable(Zin),
        .BusMuxOut(ALU_Z[31:0]),
        .BusMuxIn(Zreg)
    );

    // -----------------------
    // ALU
    // -----------------------
    ALU alu_inst (
        .RA(R5),
        .RB(R6),
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
        .IR(32'b0), .Y(32'b0),

        .RAout(0), .RBout(0), .R0out(0),
        .R1out(0), .R2out(R2out), .R3out(0), .R4out(0),
        .R5out(R5out), .R6out(R6out), .R7out(0),
        .R8out(0), .R9out(0), .R10out(0), .R11out(0),
        .R12out(0), .R13out(0), .R14out(0), .R15out(0),

        .HIout(0), .LOout(0), .Zout(Zout),
        .PCout(0), .MARout(0), .MDRout(0),
        .IRout(0), .Yout(0),

        .BusMuxOut(Bus)
    );

    // -----------------------
    // Test sequence
    // -----------------------
    initial begin
        // Init
        R2in = 0; R5in = 0; R6in = 0;
        R2out = 0; R5out = 0; R6out = 0;
        Zin = 0; Zout = 0;
        ALU_op = 0;
        load_val = 0;

        // Load R5 = F0F0F0F0
        #20 load_val = 32'hF0F0F0F0; R5in = 1;
        #20 R5in = 0;

        // Load R6 = 0FF00FF0
        #20 load_val = 32'h0FF00FF0; R6in = 1;
        #20 R6in = 0;

        // AND operation
        #20 ALU_op = 13'b1;   // <-- AND opcode
        Zin = 1;
        #20 Zin = 0;

        // Move Z -> R2
        #20 Zout = 1; R2in = 1;
        #20 Zout = 0; R2in = 0;

        // Done
        #50 $finish;
    end

endmodule
