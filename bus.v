//Bus module
module Bus (
    //define 32-bit inputs for each relevant component
    //includes registers and control signals
    input [31:0] RA, RB, R0, R1, R2, R3, R4, R5, R6, R7,
    input [31:0] R8, R9, R10, R11, R12, R13, R14, R15,
    input [31:0] HI, LO, Z, ZHI, PC, MAR, MDR, IR, Y,

    //define inputs for the outputs of each register
    input RAout, RBout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input HIout, LOout, Zout, ZHIout, PCout, MARout, MDRout, IRout, Yout,

    //define 32-bit output register for the BusMuxOut
    output reg [31:0] BusMuxOut
);

    //use always loop to create the bus multiplexer
    //to determine which control signal is turned on
    //to determine which register to access
always @(*) begin
    if (R0out) BusMuxOut = R0;
    else if (RAout) BusMuxOut = RA;
    else if (RBout) BusMuxOut = RB;
    else if (R1out) BusMuxOut = R1;
    else if (R2out) BusMuxOut = R2;
    else if (R3out) BusMuxOut = R3;
    else if (R4out) BusMuxOut = R4;
    else if (R5out) BusMuxOut = R5;
    else if (R6out) BusMuxOut = R6;
    else if (R7out) BusMuxOut = R7;
    else if (R8out) BusMuxOut = R8;
    else if (R9out) BusMuxOut = R9;
    else if (R10out) BusMuxOut = R10;
    else if (R11out) BusMuxOut = R11;
    else if (R12out) BusMuxOut = R12;
    else if (R13out) BusMuxOut = R13;
    else if (R14out) BusMuxOut = R14;
    else if (R15out) BusMuxOut = R15;
    else if (HIout) BusMuxOut = HI;
    else if (LOout) BusMuxOut = LO;
    else if (Zout) BusMuxOut = Z;
	else if (ZHIout) BusMuxOut = ZHI;
    else if (PCout) BusMuxOut = PC;
    else if (MARout) BusMuxOut = MAR;
    else if (MDRout) BusMuxOut = MDR;
    else if (IRout) BusMuxOut = IR;
    else if (Yout) BusMuxOut = Y;
    else BusMuxOut = 32'b0;
end

endmodule
