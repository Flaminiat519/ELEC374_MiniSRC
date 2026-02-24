//Arithmetic shift test bench
`timescale 1ns/10ps

module datapath_tb_sra;

  //Signal declarations
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

  //State machine parameters
  parameter Default      = 4'b0000,
            Reg_load1a   = 4'b0001,
            Reg_load1b   = 4'b0010,
            Reg_load2a   = 4'b0011,
            Reg_load2b   = 4'b0100,
			Reg_load3a   = 4'b0101,
            Reg_load3b   = 4'b0110,
            T0           = 4'b0111,
            T1           = 4'b1000,
            T2           = 4'b1001,
            T3           = 4'b1010,
            T4           = 4'b1011,
            T5           = 4'b1100;

  reg [3:0] Present_state = Default;

  //DUT instantiation
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

  //clock generation
  initial begin
    clock = 0;
    forever #10 clock = ~clock;
  end

  //deassert all control signals
  task deassert_all;
  begin
    R0in = 0; RAin = 0; RBin = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; 
    R6in = 0; R7in = 0; R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; 
    R14in = 0; R15in = 0;
    R0out = 0; RAout = 0; RBout = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; 
    R6out = 0; R7out = 0; R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; 
    R14out = 0; R15out = 0;
    HIin = 0; HIout = 0; LOin = 0; LOout = 0;
    Zin = 0; Zout = 0; PCin = 0; PCout = 0;
    MARin = 0; MARout = 0; MDRin = 0; MDRout = 0;
    IRin = 0; IRout = 0; Yin = 0; Yout = 0;
    IncPC = 0; Read = 0;
  end
  endtask

  //State machine transitions
  always @(posedge clock) begin
    if (clear) begin
      Present_state <= Default;
    end else begin
      case (Present_state)
        Default      : Present_state <= Reg_load1a;
        Reg_load1a   : Present_state <= Reg_load1b;
        Reg_load1b   : Present_state <= Reg_load2a;
        Reg_load2a   : Present_state <= Reg_load2b;
		Reg_load2b : Present_state <= Reg_load3a;
		Reg_load3a : Present_state <= Reg_load3b;
		Reg_load3b : Present_state <= T0;
        T0           : Present_state <= T1;
        T1           : Present_state <= T2;
        T2           : Present_state <= T3;
        T3           : Present_state <= T4;
        T4           : Present_state <= T5;
      endcase
    end
  end

  //State outputs
  always @(Present_state) begin
    case (Present_state)
      Default: begin
        deassert_all();
        MDatain <= 32'h00803807;
      end

      Reg_load1a: begin
        deassert_all();
        MDatain <= 32'hffff0001;
        Read <= 1; MDRin <= 1;
      end

      Reg_load1b: begin
        deassert_all();
        MDRout <= 1; R0in <= 1;  //Initialize R0 with 0x00
      end

      Reg_load2a: begin
        deassert_all();
        MDatain <= 32'h00000000;
        Read <= 1; MDRin <= 1;
      end

      Reg_load2b: begin
        deassert_all();
        MDRout <= 1; R4in <= 1;  //Initialize R4 with 0x401
      end
	  
	  Reg_load3a: begin
        deassert_all();
        MDatain <= 32'h67; //put in testing number
		Read <= 1; MDRin <= 1;
      end

      Reg_load3b: begin
        deassert_all();
        MDRout <= 1; R7in <= 1;  
	  end

      T0: begin
        deassert_all();
        //FETCh instruction
        PCout <= 1; MARin <= 1; IncPC <= 1;
      end

      T1: begin
        deassert_all();
        //Read instruction
        Read <= 1; MDRin <= 1;
        MDatain <= 32'b00101000000000000000000000000000;  //opcode 
      end

      T2: begin
        deassert_all();
        MDRout <= 1; IRin <= 1;
      end

      T3: begin
        deassert_all();
        R0out <= 1; Yin <= 1;
      end

      T4: begin
        deassert_all();
        //perform operation
        R4out <= 1; Zin <= 1;
        force DUT.alu_op = (13'b1 << 10);  //SRA index 10
      end

      T5: begin
        deassert_all();
        Zout <= 1; R7in <= 1;
        release DUT.alu_op;
      end
    endcase
  end

  //Initialize clear signal
  initial begin
    clear = 1;
    #20 clear = 0;
  end

endmodule
