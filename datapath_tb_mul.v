`timescale 1ns/10ps
module datapath_tb_mul;
reg clock, clear;
// register write enables
reg R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
// register outputs
reg R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
// special registers
reg HIin, HIout, LOin, LOout;
reg Zin, Zout, ZHIin, ZHIout;  // FIXED: Changed Zlowout->Zout, Zhighout->ZHIout, added ZHIin
reg PCin, PCout, MARin, MARout, MDRin, MDRout, IRin, IRout, Yin, Yout;
reg IncPC, Read;
reg [31:0] MDatain;
wire [31:0] BusMuxOut;

parameter Default = 4'b0000,
          L1a     = 4'b0001,
          L1b     = 4'b0010,
          L2a     = 4'b0011,
          L2b     = 4'b0100,
          T0      = 4'b0101,
          T1      = 4'b0110,
          T2      = 4'b0111,
          T3      = 4'b1000,
          T4      = 4'b1001,
          T5      = 4'b1010,
          T6      = 4'b1011;
reg [3:0] Present_state = Default;

// DUT
data_path DUT(
.clock(clock), .clear(clear),
.R0in(R0in), .RAin(RAin), .RBin(RBin), .R1in(R1in), .R2in(R2in), .R3in(R3in),
.R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in), .R8in(R8in), .R9in(R9in),
.R10in(R10in), .R11in(R11in), .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
.R0out(R0out), .RAout(RAout), .RBout(RBout), .R1out(R1out), .R2out(R2out),
.R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
.R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
.R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
.HIin(HIin), .HIout(HIout),
.LOin(LOin), .LOout(LOout),
.Zin(Zin), .Zout(Zout), .ZHIout(ZHIout), .ZHIin(ZHIin),  // FIXED: Updated port names
.PCin(PCin), .PCout(PCout),
.MARin(MARin), .MARout(MARout),
.MDRin(MDRin), .MDRout(MDRout),
.IRin(IRin), .IRout(IRout),
.Yin(Yin), .Yout(Yout),
.IncPC(IncPC),
.Read(Read),
.MDatain(MDatain),
.BusMuxOut(BusMuxOut)
);

// clock
initial begin
clock = 0;
forever #10 clock = ~clock;
end

task deassert_all;
begin
{R0in,RAin,RBin,R1in,R2in,R3in,R4in,R5in,R6in,R7in,R8in,R9in,R10in,R11in,R12in,R13in,R14in,R15in}=0;
{R0out,RAout,RBout,R1out,R2out,R3out,R4out,R5out,R6out,R7out,R8out,R9out,R10out,R11out,R12out,R13out,R14out,R15out}=0;
{HIin,HIout,LOin,LOout,Zin,Zout,ZHIin,ZHIout,PCin,PCout,MARin,MARout,MDRin,MDRout,IRin,IRout,Yin,Yout,IncPC,Read}=0;  // FIXED: Updated signal names
end
endtask

always @(posedge clock) begin
if(clear) Present_state <= Default;
else case(Present_state)
Default: Present_state <= L1a;
L1a: Present_state <= L1b;
L1b: Present_state <= L2a;
L2a: Present_state <= L2b;
L2b: Present_state <= T0;
T0: Present_state <= T1;
T1: Present_state <= T2;
T2: Present_state <= T3;
T3: Present_state <= T4;
T4: Present_state <= T5;
T5: Present_state <= T6;
endcase
end

always @(Present_state) begin
case(Present_state)
Default: deassert_all();
// R3 = 0x80000000
L1a: begin deassert_all(); MDatain<=32'h80000000; Read<=1; MDRin<=1; end
L1b: begin deassert_all(); MDRout<=1; R3in<=1; end
// R1 = 4
L2a: begin deassert_all(); MDatain<=32'h00000004; Read<=1; MDRin<=1; end
L2b: begin deassert_all(); MDRout<=1; R1in<=1; end
T0: begin deassert_all(); PCout<=1; MARin<=1; IncPC<=1; Zin<=1; end
T1: begin
deassert_all();
Zout<=1;  // FIXED: Changed from Zlowout
PCin<=1;
Read<=1;
MDatain<=32'hDEADBEEF;
MDRin<=1;
end
T2: begin deassert_all(); MDRout<=1; IRin<=1; end
T3: begin deassert_all(); R3out<=1; Yin<=1; end
T4: begin
deassert_all();
R1out<=1;
ZHIin<=1;  // FIXED: Added ZHIin for multiply high result
Zin<=1;
force DUT.alu_op = (13'b1 << 6); // MUL
end
T5: begin
deassert_all();
Zout<=1;  // FIXED: Changed from Zlowout
LOin<=1;
release DUT.alu_op;
end
T6: begin
deassert_all();
ZHIout<=1;  // FIXED: Changed from Zhighout
HIin<=1;
end
endcase
end

always @(posedge clock)
$display("t=%0t state=%b R3=%h R1=%h LO=%h HI=%h",
$time,Present_state,DUT.R3,DUT.R1,DUT.LO,DUT.HI);

initial begin
clear=1;
#20 clear=0;
end
endmodule