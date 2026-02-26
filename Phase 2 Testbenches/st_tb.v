`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_st
//  Control Sequence (inferred from ld):
//    T0: PCout, MARin, IncPC, Zin
//    T1: Zlowout, PCin, Read, MDRin
//    T2: MDRout, IRin
//    T3: Grb, BAout, Yin          (base register or 0)
//    T4: Cout, ADD, Zin           (compute effective address)
//    T5: Zlowout, MARin           (MAR = effective address)
//    T6: Gra, Rout, MDRin         (MDR = R[Ra] = value to store)
//    T7: Write                    (RAM[MAR] = MDR)
//
//  Cases:
//    Case 1: st 0x1F, R6    R6=0x63, mem[0x1F]=0xD4 -> mem[0x1F] should become 0x63
//    Case 2: st 0x1F(R6), R6  R6=0x63, mem[0x82]=0xA7 -> mem[0x82] should become 0x63
//
//  Verification: after each store, read back the memory location
//  using a mini ld sequence to confirm the value was written.
//
//  Opcodes from CPU spec:
//    st  = 5'b10010
//    ld  = 5'b10000  (used for readback)
// ================================================================
module st_tb;

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
    // st  IR = {5'b10010, Ra, Rb, C}
    //   Ra = register to store, Rb = base register
    // Case 1: st 0x1F, R6   -> Ra=R6, Rb=R0, C=0x1F
    localparam IR_ST_CASE1  = {5'b10010, 4'd6, 4'd0, 19'h01F};
    // Case 2: st 0x1F(R6), R6 -> Ra=R6, Rb=R6, C=0x1F
    localparam IR_ST_CASE2  = {5'b10010, 4'd6, 4'd6, 19'h01F};

    // Readback IR encodings (ld to verify memory contents)
    // Case 1 readback: ld R7, 0x1F  -> Ra=R7, Rb=R0, C=0x1F
    localparam IR_RB_CASE1  = {5'b10000, 4'd7, 4'd0, 19'h01F};
    // Case 2 readback: ld R7, 0x1F(R6) -> Ra=R7, Rb=R6, C=0x1F
    localparam IR_RB_CASE2  = {5'b10000, 4'd7, 4'd6, 19'h01F};

    // ── State encoding ───────────────────────────────────────
    parameter
        Default    = 6'd0,
        // st Case 1: st 0x1F, R6
        ST1_T0     = 6'd1,
        ST1_T1     = 6'd2,
        ST1_T2     = 6'd3,
        ST1_T3     = 6'd4,
        ST1_T4     = 6'd5,
        ST1_T5     = 6'd6,
        ST1_T6     = 6'd7,
        ST1_T7     = 6'd8,
        // Readback Case 1: ld R7, 0x1F
        RB1_T3     = 6'd9,
        RB1_T4     = 6'd10,
        RB1_T5     = 6'd11,
        RB1_T6     = 6'd12,
        RB1_T6b    = 6'd13,
        RB1_T7     = 6'd14,
        RB1_Done   = 6'd15,
        // st Case 2: st 0x1F(R6), R6
        ST2_T0     = 6'd16,
        ST2_T1     = 6'd17,
        ST2_T2     = 6'd18,
        ST2_T3     = 6'd19,
        ST2_T4     = 6'd20,
        ST2_T5     = 6'd21,
        ST2_T6     = 6'd22,
        ST2_T7     = 6'd23,
        // Readback Case 2: ld R7, 0x1F(R6)
        RB2_T3     = 6'd24,
        RB2_T4     = 6'd25,
        RB2_T5     = 6'd26,
        RB2_T6     = 6'd27,
        RB2_T6b    = 6'd28,
        RB2_T7     = 6'd29,
        RB2_Done   = 6'd30,
        Done       = 6'd31;

    reg [5:0] Present_state = Default;

    // ── State transitions ────────────────────────────────────
    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default  : Present_state <= ST1_T0;
            ST1_T0   : Present_state <= ST1_T1;
            ST1_T1   : Present_state <= ST1_T2;
            ST1_T2   : Present_state <= ST1_T3;
            ST1_T3   : Present_state <= ST1_T4;
            ST1_T4   : Present_state <= ST1_T5;
            ST1_T5   : Present_state <= ST1_T6;
            ST1_T6   : Present_state <= ST1_T7;
            ST1_T7   : Present_state <= RB1_T3;
            RB1_T3   : Present_state <= RB1_T4;
            RB1_T4   : Present_state <= RB1_T5;
            RB1_T5   : Present_state <= RB1_T6;
            RB1_T6   : Present_state <= RB1_T6b;
            RB1_T6b  : Present_state <= RB1_T7;
            RB1_T7   : Present_state <= RB1_Done;
            RB1_Done : Present_state <= ST2_T0;
            ST2_T0   : Present_state <= ST2_T1;
            ST2_T1   : Present_state <= ST2_T2;
            ST2_T2   : Present_state <= ST2_T3;
            ST2_T3   : Present_state <= ST2_T4;
            ST2_T4   : Present_state <= ST2_T5;
            ST2_T5   : Present_state <= ST2_T6;
            ST2_T6   : Present_state <= ST2_T7;
            ST2_T7   : Present_state <= RB2_T3;
            RB2_T3   : Present_state <= RB2_T4;
            RB2_T4   : Present_state <= RB2_T5;
            RB2_T5   : Present_state <= RB2_T6;
            RB2_T6   : Present_state <= RB2_T6b;
            RB2_T6b  : Present_state <= RB2_T7;
            RB2_T7   : Present_state <= RB2_Done;
            RB2_Done : Present_state <= Done;
            Done     : Present_state <= Done;
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
                // Preload R6=0x63 for both cases
                force DUT.R6_reg.q = 32'h63;
            end

            // ═══════════════════════════════════════
            // st Case 1: st 0x1F, R6
            // Ra=R6 (value to store), Rb=R0 (base=0)
            // effective addr = 0 + 0x1F = 0x1F
            // mem[0x1F] should become 0x63
            // ═══════════════════════════════════════
            ST1_T0: begin
                force DUT.IR_reg.q = IR_ST_CASE1;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            ST1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            ST1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_ST_CASE1;
            end
            // T3: Grb, BAout, Yin -> Y=0 (Rb=R0, BAout zeroes it)
            ST1_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            // T4: Cout, ADD, Zin -> Z = 0 + 0x1F = 0x1F
            ST1_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            // T5: Zlowout, MARin -> MAR = 0x1F
            ST1_T5: begin
                Zout <= 1; MARin <= 1;
            end
            // T6: Gra, Rout, MDRin -> MDR = R6 = 0x63
            ST1_T6: begin
                Gra <= 1; Rout <= 1; MDRin <= 1;
            end
            // T7: Write -> RAM[0x1F] = MDR = 0x63
            ST1_T7: begin
                Write <= 1;
            end

            // ── Readback Case 1: ld R7, 0x1F ──────
            // Verify mem[0x1F] is now 0x63
            RB1_T3: begin
                force DUT.IR_reg.q = IR_RB_CASE1;
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            RB1_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            RB1_T5: begin
                Zout <= 1; MARin <= 1;
            end
            RB1_T6: begin
                Read <= 1;
            end
            RB1_T6b: begin
                Read <= 1; MDRin <= 1;
            end
            RB1_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            RB1_Done: begin
                release DUT.IR_reg.q;
                release DUT.R6_reg.q;
            end

            // ═══════════════════════════════════════
            // st Case 2: st 0x1F(R6), R6
            // Ra=R6 (value to store), Rb=R6 (base)
            // effective addr = R6 + 0x1F = 0x63 + 0x1F = 0x82
            // mem[0x82] should become 0x63
            // ═══════════════════════════════════════
            ST2_T0: begin
                force DUT.IR_reg.q = IR_ST_CASE2;
                force DUT.R6_reg.q = 32'h63; // re-force R6 for Case 2
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            ST2_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            ST2_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_ST_CASE2;
            end
            // T3: Grb, BAout, Yin -> Y=R6=0x63 (Rb=R6, BAout passes value)
            ST2_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            // T4: Cout, ADD, Zin -> Z = 0x63 + 0x1F = 0x82
            ST2_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            // T5: Zlowout, MARin -> MAR = 0x82
            ST2_T5: begin
                Zout <= 1; MARin <= 1;
            end
            // T6: Gra, Rout, MDRin -> MDR = R6 = 0x63
            ST2_T6: begin
                Gra <= 1; Rout <= 1; MDRin <= 1;
            end
            // T7: Write -> RAM[0x82] = 0x63
            ST2_T7: begin
                Write <= 1;
            end

            // ── Readback Case 2: ld R7, 0x1F(R6) ──
            // Verify mem[0x82] is now 0x63
            RB2_T3: begin
                force DUT.IR_reg.q = IR_RB_CASE2;
                force DUT.R6_reg.q = 32'h63;
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            RB2_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            RB2_T5: begin
                Zout <= 1; MARin <= 1;
            end
            RB2_T6: begin
                Read <= 1;
            end
            RB2_T6b: begin
                Read <= 1; MDRin <= 1;
            end
            RB2_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            RB2_Done: begin
                release DUT.IR_reg.q;
                release DUT.R6_reg.q;
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
            RB1_Done: begin
                $display("-- st Case 1: st 0x1F, R6 (readback via ld R7, 0x1F) --");
                check(DUT.R7_reg.q, 32'h00000063, 1);
            end
            RB2_Done: begin
                $display("-- st Case 2: st 0x1F(R6), R6 (readback via ld R7, 0x1F(R6)) --");
                check(DUT.R7_reg.q, 32'h00000063, 2);
            end
            Done: begin
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    // ── Reset ────────────────────────────────────────────────
    initial begin
        $display("===== st Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule