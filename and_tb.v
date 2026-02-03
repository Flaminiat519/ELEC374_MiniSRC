`timescale 1ns/10ps
module and_tb;

    // Clock
    reg clock;

    // Register write enables
    reg R2in, R5in, R6in;
    // Register outputs
    reg R2out, R5out, R6out;
    // Special signals
    reg Yin, Zin;
    reg Zout;

    // ALU control
    reg [12:0] ALU_op;

    // Bus
    wire [31:0] Bus;

    // Register values
    wire [31:0] R2, R5, R6;
    wire [63:0] Z; // ALU output

    // Data to load
    reg [31:0] load_val;

    // -----------------------
    // Clock generation
    // -----------------------
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // -----------------------
    // Registers
    // -----------------------
    register R5_reg(.clear(0), .clock(clock), .enable(R5in), .BusMuxIn(load_val), .BusMuxOut(R5));
    register R6_reg(.clear(0), .clock(clock), .enable(R6in), .BusMuxIn(load_val), .BusMuxOut(R6));
    register R2_reg(.clear(0), .clock(clock), .enable(R2in), .BusMuxIn(Bus), .BusMuxOut(R2));

    // -----------------------
    // ALU
    // -----------------------
    ALU alu_inst(
        .RA(R5),
        .RB(R6),
        .ALU_op(ALU_op),
        .RZ(Z)
    );

    // -----------------------
    // Z register (stores ALU result)
    // -----------------------
    register Z_reg(.clear(0), .clock(clock), .enable(Zin), .BusMuxIn(Z[31:0]), .BusMuxOut());

    // -----------------------
    // Simple Bus module
    // -----------------------
    Bus bus_inst(
        .R0(32'b0), .R1(32'b0), .R2(R2), .R3(32'b0), .R4(32'b0), .R5(R5), .R6(R6), .R7(32'b0),
        .R8(32'b0), .R9(32'b0), .R10(32'b0), .R11(32'b0), .R12(32'b0), .R13(32'b0), .R14(32'b0), .R15(32'b0),
        .HI(32'b0), .LO(32'b0), .Z(Z[31:0]), .PC(32'b0), .MAR(32'b0), .MDR(32'b0), .IR(32'b0), .Y(R5),
        .R0out(0), .R1out(0), .R2out(R2out), .R3out(0), .R4out(0), .R5out(R5out), .R6out(R6out), .R7out(0),
        .R8out(0), .R9out(0), .R10out(0), .R11out(0), .R12out(0), .R13out(0), .R14out(0), .R15out(0),
        .HIout(0), .LOout(0), .Zout(Zout), .PCout(0), .MARout(0), .MDRout(0), .IRout(0), .Yout(0),
        .BusMuxOut(Bus)
    );

    // -----------------------
    // Test sequence
    // -----------------------
    initial begin
        // Initialize
        R2in = 0; R5in = 0; R6in = 0;
        R2out = 0; R5out = 0; R6out = 0;
        Yin = 0; Zin = 0; Zout = 0;
        ALU_op = 0;
        load_val = 0;

        // Load R5 with 0xF0F0F0F0
        #20 load_val = 32'hF0F0F0F0; R5in = 1;
        #20 R5in = 0;

        // Load R6 with 0x0FF00FF0
        #20 load_val = 32'h0FF00FF0; R6in = 1;
        #20 R6in = 0;

        // Perform AND: R5 AND R6 -> Z
        #20 ALU_op = 13'b1 << 0; // `AND` operation
        R5out = 1; Yin = 1; // Put R5 on bus to ALU
        R6out = 1; // Put R6 as second ALU input
        Zin = 1;
        #20 R5out = 0; R6out = 0; Yin = 0; Zin = 0;

        // Move Z -> R2
        Zout = 1; R2in = 1;
        #20 Zout = 0; R2in = 0;

        #50 $finish;
    end

endmodule
