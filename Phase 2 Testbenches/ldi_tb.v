`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_ldi
//  Cases:
//    Case 3: ldi R7, 0x65        -> R7=0x65
//    Case 4: ldi R0, 0x72(R2)    R2=0x57 -> R0=0xC9
// ================================================================
module ldi_tb;

    // ── DUT signals ──────────────────────────────────────────
    reg         clock, clear;
    reg         Gra, Grb, Grc, Rin, Rout, BAout;
    reg         HIin, HIout, LOin, LOout;
    reg         Zin, Zout, ZHIout, ZHIin;
    reg         PCin, PCout;
    reg         MARin, MARout;
    reg         MDRin, MDRout;
    reg         IRin, IRout;
    reg         Yin, Yout;
    reg         OUTPORT_In, INPORT_Out, OUTPORT_Out;
    reg         Cout;
    reg         IncPC, Read, Write;
    reg  [31:0] MDatain;
    reg  [12:0] alu_op;
    reg         CON_In, CON_Out;
    wire [31:0] BusMuxOut;

    // ── DUT ──────────────────────────────────────────────────
    data_path DUT (
        .clock(clock), .clear(clear),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .HIin(HIin), .HIout(HIout),
        .LOin(LOin), .LOout(LOout),
        .Zin(Zin), .Zout(Zout), .ZHIout(ZHIout), .ZHIin(ZHIin),
        .PCin(PCin), .PCout(PCout),
        .MARin(MARin), .MARout(MARout),
        .MDRin(MDRin), .MDRout(MDRout),
        .IRin(IRin), .IRout(IRout),
        .Yin(Yin), .Yout(Yout),
        .OUTPORT_In(OUTPORT_In), .INPORT_Out(INPORT_Out), .OUTPORT_Out(OUTPORT_Out),
        .Cout(Cout),
        .IncPC(IncPC), .Read(Read), .Write(Write),
        .MDatain(MDatain),
        .alu_op(alu_op),
        .CON_In(CON_In), .CON_Out(CON_Out),
        .BusMuxOut(BusMuxOut)
    );

    // ── Clock ────────────────────────────────────────────────
    initial clock = 0;
    always #10 clock = ~clock;

    // ── ALU op ───────────────────────────────────────────────
    localparam ADD = 13'b0000000010000;

    // ── IR encodings ─────────────────────────────────────────
    localparam IR_LDI_CASE3 = {5'b00001, 4'd7, 4'd0, 19'h065}; // ldi R7, 0x65
    localparam IR_LDI_CASE4 = {5'b00001, 4'd0, 4'd2, 19'h072}; // ldi R0, 0x72(R2)

    // ── State encoding ───────────────────────────────────────
    parameter
        Default    = 4'd0,
        LDI3_T0    = 4'd1,
        LDI3_T1    = 4'd2,
        LDI3_T2    = 4'd3,
        LDI3_T3    = 4'd4,
        LDI3_T4    = 4'd5,
        LDI3_T5    = 4'd6,
        LDI3_Done  = 4'd7,
        LDI4_T0    = 4'd8,
        LDI4_T1    = 4'd9,
        LDI4_T2    = 4'd10,
        LDI4_T3    = 4'd11,
        LDI4_T4    = 4'd12,
        LDI4_T5    = 4'd13,
        LDI4_Done  = 4'd14,
        Done       = 4'd15;

    reg [3:0] Present_state = Default;

    // ── State transitions ────────────────────────────────────
    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default   : Present_state <= LDI3_T0;
            LDI3_T0   : Present_state <= LDI3_T1;
            LDI3_T1   : Present_state <= LDI3_T2;
            LDI3_T2   : Present_state <= LDI3_T3;
            LDI3_T3   : Present_state <= LDI3_T4;
            LDI3_T4   : Present_state <= LDI3_T5;
            LDI3_T5   : Present_state <= LDI3_Done;
            LDI3_Done : Present_state <= LDI4_T0;
            LDI4_T0   : Present_state <= LDI4_T1;
            LDI4_T1   : Present_state <= LDI4_T2;
            LDI4_T2   : Present_state <= LDI4_T3;
            LDI4_T3   : Present_state <= LDI4_T4;
            LDI4_T4   : Present_state <= LDI4_T5;
            LDI4_T5   : Present_state <= LDI4_Done;
            LDI4_Done : Present_state <= Done;
            Done      : Present_state <= Done;
        endcase
    end

    // ── Deassert all ─────────────────────────────────────────
    task deassert_all;
    begin
        {Gra,Grb,Grc,Rin,Rout,BAout}       = 6'b0;
        {HIin,HIout,LOin,LOout}             = 4'b0;
        {Zin,Zout,ZHIout,ZHIin}            = 4'b0;
        {PCin,PCout,MARin,MARout}           = 4'b0;
        {MDRin,MDRout,IRin,IRout}           = 4'b0;
        {Yin,Yout,Cout}                     = 3'b0;
        {OUTPORT_In,INPORT_Out,OUTPORT_Out} = 3'b0;
        {IncPC,Read,Write,CON_In,CON_Out}   = 5'b0;
        alu_op                              = 13'b0;
        MDatain                             = 32'b0;
    end
    endtask

    // ── State outputs ────────────────────────────────────────
    always @(Present_state) begin
        deassert_all();
        case (Present_state)

            Default: begin
                force DUT.R2_reg.q = 32'h57; // preload R2 for Case 4
            end

            // ═══════════════════════════════════
            // ldi Case 3: ldi R7, 0x65 -> R7=0x65
            // ═══════════════════════════════════
            LDI3_T0: begin
                force DUT.IR_reg.q = IR_LDI_CASE3;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            LDI3_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            LDI3_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_LDI_CASE3;
            end
            // T3: Grb, BAout, Yin -> Y=0 (Rb=R0, BAout zeroes it)
            LDI3_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            // T4: Cout, ADD, Zin -> Z = 0 + 0x65 = 0x65
            LDI3_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            // T5: Zlowout, Gra, Rin -> R7 = 0x65
            LDI3_T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1;
            end
            LDI3_Done: begin
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // ldi Case 4: ldi R0, 0x72(R2) -> R0=0xC9
            // ═══════════════════════════════════
            LDI4_T0: begin
                force DUT.IR_reg.q = IR_LDI_CASE4;
                force DUT.R2_reg.q = 32'h57;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            LDI4_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            LDI4_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_LDI_CASE4;
            end
            // T3: Grb, BAout, Yin -> Y=R2=0x57
            LDI4_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            // T4: Cout, ADD, Zin -> Z = 0x57 + 0x72 = 0xC9
            LDI4_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            // T5: Zlowout, Gra, Rin -> R0 = 0xC9
            LDI4_T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1;
            end
            LDI4_Done: begin
                release DUT.IR_reg.q;
                release DUT.R2_reg.q;
            end

            Done: deassert_all();

        endcase
    end

    // ── Result checking ──────────────────────────────────────
    integer pass = 0, fail = 0;

    task check;
        input [31:0] got;
        input [31:0] expected;
        input [31:0] tnum;
        begin
            if (got === expected) begin
                $display("  PASS test %0d: got 0x%08h", tnum, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL test %0d: expected 0x%08h got 0x%08h",
                         tnum, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    always @(posedge clock) begin
        #2;
        case (Present_state)
            LDI3_Done: begin
                $display("-- ldi Case 3: ldi R7, 0x65 --");
                check(DUT.R7_reg.q, 32'h00000065, 3);
            end
            LDI4_Done: begin
                $display("-- ldi Case 4: ldi R0, 0x72(R2) --");
                check(DUT.R0_reg.q, 32'h000000C9, 4);
            end
            Done: begin
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    // ── Reset ────────────────────────────────────────────────
    initial begin
        $display("===== ldi Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule