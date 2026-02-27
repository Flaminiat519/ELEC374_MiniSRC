// addi testbench: addi R7, R4, -9   (for synchronous RAM read)
// Expect: if R4 = 100, then R7 = 91
`timescale 1ns/10ps

module addi_tb;

  reg clock, clear;

  // Select/encode controls
  reg Gra, Grb, Grc, Rin, Rout, BAout;

  // Special regs
  reg HIin, HIout, LOin, LOout;
  reg Zin, Zout, ZHIin, ZHIout;
  reg PCin, PCout;
  reg MARin, MARout;
  reg MDRin, MDRout;
  reg IRin, IRout;
  reg Yin, Yout;

  // I/O + constant + mem
  reg OUTPORT_In, INPORT_Out, OUTPORT_Out;
  reg Cout;
  reg IncPC, Read, Write;
  reg [31:0] MDatain;

  // CON FF (unused here)
  reg CON_In, CON_Out;

  wire [31:0] BusMuxOut;

  data_path DUT (
    .clock(clock), .clear(clear),

    .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout),

    .HIin(HIin), .HIout(HIout),
    .LOin(LOin), .LOout(LOout),
    .Zin(Zin), .Zout(Zout), .ZHIout(ZHIout), .ZHIin(ZHIin),

    .PCin(PCin), .PCout(PCout),
    .MARin(MARin), .MARout(MARout),
    .MDRin(MDRin), .MDRout(MDRout),
    .IRin(IRin), .IRout(IRout),
    .Yin(Yin), .Yout(Yout),

    .OUTPORT_In(OUTPORT_In),
    .INPORT_Out(INPORT_Out),
    .OUTPORT_Out(OUTPORT_Out),

    .Cout(Cout),

    .IncPC(IncPC),
    .Read(Read),
    .Write(Write),

    .MDatain(MDatain),
    .BusMuxOut(BusMuxOut),

    .CON_In(CON_In),
    .CON_Out(CON_Out)
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
    PCin=0; PCout=0;
    MARin=0; MARout=0;
    MDRin=0; MDRout=0;
    IRin=0; IRout=0;
    Yin=0; Yout=0;

    OUTPORT_In=0; INPORT_Out=0; OUTPORT_Out=0;
    Cout=0;

    IncPC=0; Read=0; Write=0;

    CON_In=0; CON_Out=0;

    MDatain = 32'h0;
  end
  endtask

  // states
  parameter Default = 4'd0,
            Setup   = 4'd1,
            T0      = 4'd2,
            T1      = 4'd3,
            T2      = 4'd4,
            T3      = 4'd5,
            T4      = 4'd6,
            T5      = 4'd7,
            T6      = 4'd8,
            Done    = 4'd9;

  reg [3:0] Present_state = Default;

  always @(posedge clock) begin
    if (clear) Present_state <= Default;
    else begin
      case (Present_state)
        Default: Present_state <= Setup;
        Setup  : Present_state <= T0;
        T0     : Present_state <= T1;
        T1     : Present_state <= T2;
        T2     : Present_state <= T3;
        T3     : Present_state <= T4;
        T4     : Present_state <= T5;
        T5     : Present_state <= T6;
        T6     : Present_state <= Done;
        Done   : Present_state <= Done;
        default: Present_state <= Default;
      endcase
    end
  end

  // constants
  localparam [31:0] R4_INIT = 32'd100;
  localparam [31:0] EXPECT  = 32'd91;

  // IR format in your select/encode:
  // RA=IR[26:23]=7, RB=IR[22:19]=4, C=IR[18:0]=-9 (19-bit 2's comp = 0x7FFF7)
  localparam [31:0] ADDI_R7_R4_NEG9 = 32'h03A7_FFF7;

  // outputs per state
  always @(*) begin
    deassert_all();

    case (Present_state)

      // ----- Fetch for synchronous RAM -----
      T0: begin
        PCout = 1;
        MARin = 1;
        IncPC = 1;
      end

      // start RAM read (RAM updates data_out on NEXT posedge)
      T1: begin
        Read = 1;
      end

      // latch RAM output into MDR (keep Read=1 so MDR mux selects memory)
      T2: begin
        Read  = 1;
        MDRin = 1;
      end

      // load IR from MDR
      T3: begin
        MDRout = 1;
        IRin   = 1;
      end

      // ----- addi execute (Phase2: T3 Grb Rout Yin) -----
      T4: begin
        Grb  = 1;
        Rout = 1;
        Yin  = 1;
      end

      // Phase2: T4 Cout ADD Zin
      T5: begin
        Cout = 1;
        Zin  = 1;
        force DUT.alu_op = (13'b1 << 4); // ADD is bit 4 in your ALU.v
      end

      // Phase2: T5 Zlowout Gra Rin
      T6: begin
        Zout = 1;
        Gra  = 1;
        Rin  = 1;
        release DUT.alu_op;
      end

      default: begin end
    endcase
  end

  // reset + preload
  integer i;
  initial begin
    clear = 1;
    #25 clear = 0;

    // optional: wipe RAM so the missing ram.hex doesn't matter
    // (and so mem is in a known state)
    for (i = 0; i < 512; i = i + 1)
      DUT.RAM.mem[i] = 32'h0;

    // preload PC, R4, and instruction in memory[0]
    DUT.PC_reg.qTemp = 32'd0;
    DUT.R4_reg.q     = R4_INIT;
    DUT.RAM.mem[0]   = ADDI_R7_R4_NEG9;

    $display("Preload: R4=%0d, RAM[0]=0x%08h", DUT.R4_reg.q, DUT.RAM.mem[0]);
  end

  // check
  initial begin
    wait (Present_state == Done);
    #5;

    $display("Result: R7=%0d (0x%08h), expected=%0d (0x%08h)",
             DUT.R7_reg.q, DUT.R7_reg.q, EXPECT, EXPECT);

    if (DUT.R7_reg.q !== EXPECT)
      $display("FAIL: addi R7,R4,-9 produced wrong result.");
    else
      $display("PASS: addi R7,R4,-9 works.");

    $stop;
  end

endmodule