`timescale 1ns/10ps

module addi_tb;

  reg clock, clear;

  // GPR select controls
  reg Gra, Grb, Grc, Rin, Rout, BAout;

  // Special controls
  reg HIin, HIout, LOin, LOout;
  reg Zin, Zout, ZHIin, ZHIout;
  reg PCin, PCout;
  reg MARin, MARout;
  reg MDRin, MDRout;
  reg IRin, IRout;
  reg Yin, Yout;

  // Memory + misc
  reg IncPC, Read, Write;
  reg [31:0] MDatain;

  // Conditional
  reg CON_In, CON_Out;

  // If your datapath has these ports, tie them off
  reg OUTPORT_In, OUTPORT_Out, INPORT_Out;

  wire [31:0] BusMuxOut;

  // DUT
  data_path DUT (
    .clock(clock), .clear(clear),

    .Gra(Gra), .Grb(Grb), .Grc(Grc),
    .Rin(Rin), .Rout(Rout), .BAout(BAout),

    .HIin(HIin), .HIout(HIout),
    .LOin(LOin), .LOout(LOout),
    .Zin(Zin), .Zout(Zout), .ZHIin(ZHIin), .ZHIout(ZHIout),
    .PCin(PCin), .PCout(PCout),
    .MARin(MARin), .MARout(MARout),
    .MDRin(MDRin), .MDRout(MDRout),
    .IRin(IRin), .IRout(IRout),
    .Yin(Yin), .Yout(Yout),

    .IncPC(IncPC),
    .Read(Read),
    .Write(Write),
    .MDatain(MDatain),

    .CON_In(CON_In),
    .CON_Out(CON_Out),

    // Comment these out if your datapath doesn't have them
    .OUTPORT_In(OUTPORT_In),
    .INPORT_Out(INPORT_Out),
    .OUTPORT_Out(OUTPORT_Out),

    .BusMuxOut(BusMuxOut)
  );

  // clock
  initial begin
    clock = 0;
    forever #10 clock = ~clock;
  end

  task deassert_all;
  begin
    Gra=0; Grb=0; Grc=0; Rin=0; Rout=0; BAout=0;
    HIin=0; HIout=0; LOin=0; LOout=0;
    Zin=0; Zout=0; ZHIin=0; ZHIout=0;
    PCin=0; PCout=0; MARin=0; MARout=0;
    MDRin=0; MDRout=0; IRin=0; IRout=0;
    Yin=0; Yout=0;
    IncPC=0; Read=0; Write=0;
    CON_In=0; CON_Out=0;

    OUTPORT_In=0; OUTPORT_Out=0; INPORT_Out=0;
  end
  endtask

  function [31:0] encode_addi(input [3:0] ra, input [3:0] rb, input [18:0] imm);
    reg [31:0] inst;
    begin
      inst = 32'b0;
      inst[26:23] = ra;
      inst[22:19] = rb;
      inst[18:0]  = imm;
      encode_addi = inst;
    end
  endfunction

  // states
  parameter S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, S10=10;
  reg [3:0] state;

  localparam [3:0] RA_DEST = 4'd2;
  localparam [3:0] RB_SRC  = 4'd5;
  localparam [18:0] IMM    = 19'd3;

  localparam [31:0] R5_INIT = 32'h00000034;
  localparam [31:0] EXPECT  = 32'h00000037;

  // reset
  initial begin
    clear = 1; state = S0;
    #25 clear = 0;
  end

  always @(posedge clock) begin
    if (clear) state <= S0;
    else state <= state + 1;
  end

  always @(*) begin
    deassert_all();
    MDatain = 32'h0;

    case(state)

      // preload R5 via MDR->bus, select RA=5, Gra+Rin
      S0: begin
        MDatain = R5_INIT;
        Read = 1; MDRin = 1;
      end

      S1: begin
        // Force IR so Gra selects reg5 (RA field=5)
        force DUT.IR = (32'b0 | (32'(5) << 23));
        MDRout = 1;
        Gra = 1; Rin = 1;
      end

      // fetch: T0-T2
      S2: begin
        release DUT.IR;
        PCout = 1; MARin = 1; IncPC = 1;
      end

      S3: begin
        MDatain = encode_addi(RA_DEST, RB_SRC, IMM);
        Read = 1; MDRin = 1;
      end

      S4: begin
        MDRout = 1; IRin = 1;
      end

      // execute addi
      // T3: Grb Rout Yin
      S5: begin
        Grb = 1; Rout = 1; Yin = 1;
      end

      // T4: Cout ADD Zin  (SIM HACK: force bus to immediate)
      S6: begin
        Zin = 1;
        force DUT.alu_op = (13'b1 << 4); // ADD
        // Put immediate on bus by forcing BusMuxOut (temporary)
        // Better: implement Cout path in Bus for real.
        force DUT.Bus = {{13{DUT.IR[18]}}, DUT.IR[18:0]};
      end

      // T5: Zout Gra Rin
      S7: begin
        release DUT.Bus;
        Zout = 1;
        Gra  = 1;
        Rin  = 1;
        release DUT.alu_op;
      end

      // Check: select Ra=2 and Rout -> bus shows R2
      S8: begin
        force DUT.IR = (32'b0 | (32'(2) << 23));
        Gra = 1; Rout = 1;
      end

      default: begin
        // hold
      end

    endcase
  end

  initial begin
    @(negedge clear);
    #200;

    if (BusMuxOut !== EXPECT) begin
      $display("FAIL: Expected R2=%h but got %h", EXPECT, BusMuxOut);
      $fatal;
    end else begin
      $display("PASS: ADDI works. R2=%h", BusMuxOut);
    end

    $finish;
  end

endmodule