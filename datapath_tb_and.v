`timescale 1ns/10ps

module datapath_tb_and;

  reg clock, clear;

  reg R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
  reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;

  reg R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
  reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;

  reg HIin, HIout, LOin, LOout, Zin, Zout;
  reg PCin, PCout, MARin, MARout, MDRin, MDRout, IRin, IRout, Yin, Yout;

  reg IncPC, Read;
  reg [31:0] MDatain;

  wire [31:0] BusMuxOut;

  data_path DUT (
    .clock(clock), .clear(clear),

    .R0in(R0in), .RAin(RAin), .RBin(RBin), .R1in(R1in), .R2in(R2in), .R3in(R3in), .R4in(R4in), .R5in(R5in),
    .R6in(R6in), .R7in(R7in), .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in), .R12in(R12in),
    .R13in(R13in), .R14in(R14in), .R15in(R15in),

    .R0out(R0out), .RAout(RAout), .RBout(RBout), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out),
    .R5out(R5out), .R6out(R6out), .R7out(R7out), .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
    .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),

    .HIin(HIin), .HIout(HIout),
    .LOin(LOin), .LOout(LOout),
    .Zin(Zin), .Zout(Zout),
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
    R0in=0; RAin=0; RBin=0; R1in=0; R2in=0; R3in=0; R4in=0; R5in=0; R6in=0; R7in=0;
    R8in=0; R9in=0; R10in=0; R11in=0; R12in=0; R13in=0; R14in=0; R15in=0;

    R0out=0; RAout=0; RBout=0; R1out=0; R2out=0; R3out=0; R4out=0; R5out=0; R6out=0; R7out=0;
    R8out=0; R9out=0; R10out=0; R11out=0; R12out=0; R13out=0; R14out=0; R15out=0;

    HIin=0; HIout=0; LOin=0; LOout=0;
    Zin=0; Zout=0;
    PCin=0; PCout=0;
    MARin=0; MARout=0;
    MDRin=0; MDRout=0;
    IRin=0; IRout=0;
    Yin=0; Yout=0;

    IncPC=0; Read=0;
  end
  endtask

  task mem_read_to_mdr(input [31:0] val);
  begin
    @(negedge clock);
    MDatain = val;
    Read    = 1;
    MDRin   = 1;
    @(negedge clock);
    Read  = 0;
    MDRin = 0;
  end
  endtask

  task mdr_to_reg(input integer regnum);
  begin
    @(negedge clock);
    MDRout = 1;
    case (regnum)
      2: R2in = 1;
      5: R5in = 1;
      6: R6in = 1;
    endcase
    @(negedge clock);
    MDRout = 0;
    R2in   = 0;
    R5in   = 0;
    R6in   = 0;
  end
  endtask

  reg [31:0] PC_start, PC_expected;

  // trace
  always @(posedge clock) begin
    $display("t=%0t clear=%b | PCin=%b PCout=%b IncPC=%b | Bus=%h | PC=%h Z=%h R5=%h R6=%h R2=%h",
      $time, clear, PCin, PCout, IncPC, BusMuxOut, DUT.PC, DUT.Z, DUT.R5, DUT.R6, DUT.R2);
  end

  initial begin
    clear = 1;
    MDatain = 32'h0;
    deassert_all();

    repeat(2) @(negedge clock);
    clear = 0;

    // preload PC to 0x10 using MDR->PC (so it's obvious in demo)
    PC_start    = 32'h00000010;
    PC_expected = PC_start + 32'h1;

    mem_read_to_mdr(PC_start);
    @(negedge clock);
    MDRout = 1; PCin = 1;
    @(negedge clock);
    MDRout = 0; PCin = 0;

    // preload registers
    mem_read_to_mdr(32'h00000034); mdr_to_reg(5);
    mem_read_to_mdr(32'h00000045); mdr_to_reg(6);

    // ---------------- FETCH (matching YOUR pc_reg design) ----------------
    // T0: PCout, MARin, IncPC  (PC increments internally on posedge)
    @(negedge clock); deassert_all();
    PCout = 1; MARin = 1; IncPC = 1;
    @(negedge clock); deassert_all();

    // After T0 posedge, PC should already be incremented (0x11)
    #1;
    if (DUT.PC !== PC_expected)
      $display("❌ PC increment failed after T0: PC=%h expected=%h", DUT.PC, PC_expected);
    else
      $display("✅ PC increment OK after T0: PC=%h", DUT.PC);

    // T1: Read, MDRin, MDatain (NO PCin here!)
    @(negedge clock); deassert_all();
    Read = 1; MDRin = 1;
    MDatain = 32'h112B0000;
    @(negedge clock); deassert_all();

    // Ensure PC stayed incremented
    #1;
    if (DUT.PC !== PC_expected)
      $display("❌ PC changed unexpectedly after T1: PC=%h expected=%h", DUT.PC, PC_expected);

    // T2: MDRout, IRin
    @(negedge clock); deassert_all();
    MDRout = 1; IRin = 1;
    @(negedge clock); deassert_all();

    // ---------------- EXECUTE AND ----------------
    // T3: R5out, Yin
    @(negedge clock); deassert_all();
    R5out = 1; Yin = 1;
    @(negedge clock); deassert_all();

    // T4: R6out, AND, Zin  (force alu_op one-hot AND)
    @(negedge clock); deassert_all();
    R6out = 1; Zin = 1;
    force DUT.alu_op = (13'b1 << 0); // AND index 0
    @(negedge clock); deassert_all();
    release DUT.alu_op;

    // T5: Zout, R2in
    @(negedge clock); deassert_all();
    Zout = 1; R2in = 1;
    @(negedge clock); deassert_all();

    #1;
    $display("R5=%h R6=%h R2=%h (expected 00000004)", DUT.R5, DUT.R6, DUT.R2);
    if (DUT.R2 !== 32'h00000004) $display("❌ AND test FAILED");
    else                         $display("✅ AND test PASSED");

    // final PC must still be +1
    if (DUT.PC !== PC_expected)
      $display("❌ Final PC wrong: PC=%h expected=%h", DUT.PC, PC_expected);
    else
      $display("✅ Final PC correct: PC=%h", DUT.PC);

    #50;
    $stop;
  end

endmodule


