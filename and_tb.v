`timescale 1ns/10ps
module and_tb;

<<<<<<< Updated upstream
    reg clock;
=======
    // ---------------- Control signals ----------------
    reg Zlowout, MDRout, R5out, R6out;
    reg Zin, MDRin;
    reg AND;
    reg R2in, R5in, R6in;
    reg Clock;

    reg [31:0] Mdatain;

    // ---------------- FSM states ----------------
    parameter Default     = 4'b0000,
              Reg_load1a  = 4'b0001,
              Reg_load1b  = 4'b0010,
              Reg_load2a  = 4'b0011,
              Reg_load2b  = 4'b0100,
              T0          = 4'b0101,
              T1          = 4'b0110,
              T2          = 4'b0111,
              T3          = 4'b1000,
              T4          = 4'b1001;

    reg [3:0] Present_state = Default;

    // ---------------- DUT ----------------
    Datapath DUT (
        .Zlowout(Zlowout),
        .MDRout(MDRout),
        .R5out(R5out),
        .R6out(R6out),
        .Zin(Zin),
        .MDRin(MDRin),
        .AND(AND),
        .R2in(R2in),
        .R5in(R5in),
        .R6in(R6in),
        .Clock(Clock),
        .Mdatain(Mdatain)
    );

    // ---------------- Clock ----------------
>>>>>>> Stashed changes
    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

<<<<<<< Updated upstream
    reg R2in, R5in, R6in;
    reg R2out, R5out, R6out;
    reg Zin, Zout;

    reg [12:0] ALU_op;
    reg [31:0] load_val;

    wire [31:0] Bus;
    wire [31:0] R2, R5, R6;
    wire [63:0] ALU_Z;
    wire [31:0] Zreg;


    register R5_reg (.clear(0),.clock(clock),.enable(R5in),.BusMuxOut(load_val),.BusMuxIn(R5));

    register R6_reg (.clear(0),.clock(clock),.enable(R6in),.BusMuxOut(load_val),.BusMuxIn(R6));

    register R2_reg (.clear(0),.clock(clock),.enable(R2in),.BusMuxOut(Bus),.BusMuxIn(R2));

    register Z_reg (.clear(0),.clock(clock),.enable(Zin),.BusMuxOut(ALU_Z[31:0]),.BusMuxIn(Zreg));

    ALU alu_inst (.RA(R5),.RB(R6),.ALU_op(ALU_op),.RZ(ALU_Z));

    Bus bus_inst (
        .RA(32'b0), .RB(32'b0), .R0(32'b0),.R1(32'b0), .R2(R2), .R3(32'b0), .R4(32'b0),
        .R5(R5), .R6(R6), .R7(32'b0),
        .R8(32'b0), .R9(32'b0), .R10(32'b0), .R11(32'b0),
        .R12(32'b0), .R13(32'b0), .R14(32'b0), .R15(32'b0),

        .HI(32'b0), .LO(32'b0), .Z(Zreg),
        .PC(32'b0), .MAR(32'b0), .MDR(32'b0),.IR(32'b0), .Y(32'b0),

        .RAout(0), .RBout(0), .R0out(0),.R1out(0), .R2out(R2out), .R3out(0), .R4out(0),
        .R5out(R5out), .R6out(R6out), .R7out(0),
        .R8out(0), .R9out(0), .R10out(0), .R11out(0),.R12out(0), .R13out(0), .R14out(0), .R15out(0),

        .HIout(0), .LOout(0), .Zout(Zout),
        .PCout(0), .MARout(0), .MDRout(0),
        .IRout(0), .Yout(0),

        .BusMuxOut(Bus)
    );

    initial begin
        //Init
=======
    // ---------------- FSM sequencing ----------------
    always @(posedge Clock) begin
        case (Present_state)
            Default    : Present_state <= Reg_load1a;
            Reg_load1a : Present_state <= Reg_load1b;
            Reg_load1b : Present_state <= Reg_load2a;
            Reg_load2a : Present_state <= Reg_load2b;
            Reg_load2b : Present_state <= T0;
            T0         : Present_state <= T1;
            T1         : Present_state <= T2;
            T2         : Present_state <= T3;
            T3         : Present_state <= T4;
        endcase
    end

    // ---------------- Control logic ----------------
    always @(Present_state) begin
        // -------- default deassert --------
        Zlowout = 0; MDRout = 0; R5out = 0; R6out = 0;
        Zin = 0; MDRin = 0;
        AND = 0;
>>>>>>> Stashed changes
        R2in = 0; R5in = 0; R6in = 0;
        Mdatain = 32'h00000000;

<<<<<<< Updated upstream
        //Load R5
        #20 load_val = 32'hF0F0F0F0; R5in = 1;
        #20 R5in = 0;

        //Load R6
        #20 load_val = 32'h0FF00FF0; R6in = 1;
        #20 R6in = 0;

        //AND operation
        #20 ALU_op[0] = 13'b1;//op code equivalent
        Zin = 1;
        #20 Zin = 0;

        //Move Z to r2
        #20 Zout = 1; R2in = 1;
        #20 Zout = 0; R2in = 0;

        #50 $finish;
=======
        case (Present_state)

        // -------- Load R5 = 0x34 --------
        Reg_load1a: begin
            Mdatain = 32'h00000034;
            MDRin   = 1;
        end

        Reg_load1b: begin
            MDRout = 1;
            R5in   = 1;
        end

        // -------- Load R6 = 0x45 --------
        Reg_load2a: begin
            Mdatain = 32'h00000045;
            MDRin   = 1;
        end

        Reg_load2b: begin
            MDRout = 1;
            R6in   = 1;
        end

        // -------- T0–T2: symbolic fetch (no-op) --------
        T0: begin end
        T1: begin end
        T2: begin end

        // -------- T3: AND execute --------
        T3: begin
            AND = 1;
            Zin = 1;
        end

        // -------- T4: writeback --------
        T4: begin
            Zlowout = 1;
            R2in    = 1;
        end

        endcase
>>>>>>> Stashed changes
    end

endmodule
