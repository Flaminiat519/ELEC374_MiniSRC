`timescale 1ns/1ps
module register_tb;

    reg clock, clear;
    reg R0in, R0out, R1in, R1out;
    reg PCin, PCout;
    reg IRin, IRout;
    reg Yin, Yout;

    wire [31:0] BusMuxOut;

    data_path DP(
        .clock(clock), .clear(clear),
        .R0in(R0in), .R1in(R1in),
        .R0out(R0out), .R1out(R1out),
        .PCin(PCin), .PCout(PCout),
        .IRin(IRin), .IRout(IRout),
        .Yin(Yin), .Yout(Yout),
        .BusMuxOut(BusMuxOut),

        // Tie unused signals low
        .R2in(0),.R3in(0),.R4in(0),.R5in(0),.R6in(0),.R7in(0),
        .R8in(0),.R9in(0),.R10in(0),.R11in(0),.R12in(0),.R13in(0),.R14in(0),.R15in(0),
        .R2out(0),.R3out(0),.R4out(0),.R5out(0),.R6out(0),.R7out(0),
        .R8out(0),.R9out(0),.R10out(0),.R11out(0),.R12out(0),.R13out(0),.R14out(0),.R15out(0),
        .HIin(0),.HIout(0),.LOin(0),.LOout(0),
        .Zin(0),.Zout(0),
        .MARin(0),.MARout(0),
        .MDRin(0),.MDRout(0)
    );

    always #5 clock = ~clock;

    initial begin
        clock = 0;
        clear = 1;
        R0in=0; R0out=0; R1in=0; R1out=0;
        PCin=0; PCout=0; IRin=0; IRout=0; Yin=0; Yout=0;

        #10 clear = 0;

        // Write value to R0
        R0in = 1; #10 R0in = 0;
        R0out = 1; #10 R0out = 0;

        // Move R0 → R1
        R0out = 1; R1in = 1; #10;
        R0out = 0; R1in = 0;

        #20 $stop;
    end

endmodule
