`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_ld_ldi
//  Follows Phase 1 state machine style.
//
//  Control Sequences (from Phase 2 spec Section 3.1):
//  ld:
//    T0: PCout, MARin, IncPC, Zin
//    T1: Zlowout, PCin, Read, MDRin
//    T2: MDRout, IRin
//    T3: Grb, BAout, Yin
//    T4: Cout, ADD, Zin
//    T5: Zlowout, MARin
//    T6: Read, MDRin
//    T7: MDRout, Gra, Rin
//
//  ldi:
//    T0-T2: same as ld
//    T3: Grb, BAout, Yin
//    T4: Cout, ADD, Zin
//    T5: Zlowout, Gra, Rin
//
//  Test Cases:
//    Case 1: ld  R7, 0x65       mem[0x65]=0x84  -> R7 should = 0x84
//    Case 2: ld  R0, 0x72(R2)   R2=0x57, mem[0xC9]=0x2B -> R0 should = 0x2B
//    Case 3: ldi R7, 0x65       -> R7 should = 0x65
//    Case 4: ldi R0, 0x72(R2)   R2=0x57 -> R0 should = 0x72+0x57 = 0xC9
//
//  IR encoding (Mini SRC):
//    [31:27] = opcode
//    [26:23] = Ra
//    [22:19] = Rb
//    [18:0]  = C (constant, sign extended)
//
//  ld  opcode = 5'b00000  (from CPU spec)
//  ldi opcode = 5'b00001  (from CPU spec) -- adjust if your spec differs
// ================================================================
module ld_tb;

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
    localparam ADD = 13'b0000000010000; // bit 4

    // ── State encoding ───────────────────────────────────────
    parameter
        Default      = 5'd0,
        // Preload R2 with 0x57
        Rload1a      = 5'd1,   // MDRin with 0x57
        Rload1b      = 5'd2,   // MDRout, R2in
        // ld Case 1: ld R7, 0x65
        LD1_T0       = 5'd3,
        LD1_T1       = 5'd4,
        LD1_T2       = 5'd5,
        LD1_T3       = 5'd6,
        LD1_T4       = 5'd7,
        LD1_T5       = 5'd8,
        LD1_T6       = 5'd9,
        LD1_T7       = 5'd10,
        // ld Case 2: ld R0, 0x72(R2)
        LD2_T0       = 5'd11,
        LD2_T1       = 5'd12,
        LD2_T2       = 5'd13,
        LD2_T3       = 5'd14,
        LD2_T4       = 5'd15,
        LD2_T5       = 5'd16,
        LD2_T6       = 5'd17,
        LD2_T7       = 5'd18,
        // ldi Case 3: ldi R7, 0x65
        LDI3_T0      = 5'd19,
        LDI3_T1      = 5'd20,
        LDI3_T2      = 5'd21,
        LDI3_T3      = 5'd22,
        LDI3_T4      = 5'd23,
        LDI3_T5      = 5'd24,
        // ldi Case 4: ldi R0, 0x72(R2)
        LDI4_T0      = 5'd25,
        LDI4_T1      = 5'd26,
        LDI4_T2      = 5'd27,
        LDI4_T3      = 5'd28,
        LDI4_T4      = 5'd29,
        LDI4_T5      = 5'd30,
        Done         = 5'd31;

    reg [4:0] Present_state = Default;

    // ── IR words ─────────────────────────────────────────────
    // IR = {opcode[31:27], Ra[26:23], Rb[22:19], C[18:0]}
    // ld  opcode = 5'b00000
    // ldi opcode = 5'b00001
    // Case 1: ld  R7, 0x65      Ra=R7(0111), Rb=R0(0000), C=0x65
    localparam IR_LD_CASE1  = {5'b00000, 4'd7,  4'd0, 19'h065};
    // Case 2: ld  R0, 0x72(R2)  Ra=R0(0000), Rb=R2(0010), C=0x72
    localparam IR_LD_CASE2  = {5'b00000, 4'd0,  4'd2, 19'h072};
    // Case 3: ldi R7, 0x65      Ra=R7(0111), Rb=R0(0000), C=0x65
    localparam IR_LDI_CASE3 = {5'b00001, 4'd7,  4'd0, 19'h065};
    // Case 4: ldi R0, 0x72(R2)  Ra=R0(0000), Rb=R2(0010), C=0x72
    localparam IR_LDI_CASE4 = {5'b00001, 4'd0,  4'd2, 19'h072};

    // ── State transitions ────────────────────────────────────
    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default  : Present_state <= Rload1a;
            Rload1a  : Present_state <= Rload1b;
            Rload1b  : Present_state <= LD1_T0;
            LD1_T0   : Present_state <= LD1_T1;
            LD1_T1   : Present_state <= LD1_T2;
            LD1_T2   : Present_state <= LD1_T3;
            LD1_T3   : Present_state <= LD1_T4;
            LD1_T4   : Present_state <= LD1_T5;
            LD1_T5   : Present_state <= LD1_T6;
            LD1_T6   : Present_state <= LD1_T7;
            LD1_T7   : Present_state <= LD2_T0;
            LD2_T0   : Present_state <= LD2_T1;
            LD2_T1   : Present_state <= LD2_T2;
            LD2_T2   : Present_state <= LD2_T3;
            LD2_T3   : Present_state <= LD2_T4;
            LD2_T4   : Present_state <= LD2_T5;
            LD2_T5   : Present_state <= LD2_T6;
            LD2_T6   : Present_state <= LD2_T7;
            LD2_T7   : Present_state <= LDI3_T0;
            LDI3_T0  : Present_state <= LDI3_T1;
            LDI3_T1  : Present_state <= LDI3_T2;
            LDI3_T2  : Present_state <= LDI3_T3;
            LDI3_T3  : Present_state <= LDI3_T4;
            LDI3_T4  : Present_state <= LDI3_T5;
            LDI3_T5  : Present_state <= LDI4_T0;
            LDI4_T0  : Present_state <= LDI4_T1;
            LDI4_T1  : Present_state <= LDI4_T2;
            LDI4_T2  : Present_state <= LDI4_T3;
            LDI4_T3  : Present_state <= LDI4_T4;
            LDI4_T4  : Present_state <= LDI4_T5;
            LDI4_T5  : Present_state <= Done;
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

            // ── Preload R2 = 0x57 ────────────────────────────
            // (needed for Cases 2 and 4 which use ld/ldi Rx, 0x72(R2))
            // We use the same Read+MDRin trick from Phase 1
            Default: begin
                MDatain <= 32'h00000000;
            end

            Rload1a: begin
                MDatain <= 32'h57;
                Read <= 1; MDRin <= 1;
            end

            Rload1b: begin
                MDRout <= 1; Rin <= 1; Grb <= 1;
                // Grb selects Rb field of IR, but IR=0 at reset so Rb=0000=R0
                // We need to target R2 directly so force R2in:
                // Since select_and_encode reads IR which is 0, we force R2in
            end

            // NOTE: Rload1b uses Grb with IR=0 which gives R0, not R2.
            // To directly load R2 we force it like Phase 1 did with explicit Rnin signals.
            // Since your new datapath uses Gra/Grb/Grc, we force the IR first.
            // See the $display note below for how to handle this.

            // ─────────────────────────────────────────────────
            // ld CASE 1: ld R7, 0x65  (expect R7 = mem[0x65] = 0x84)
            // ─────────────────────────────────────────────────
            LD1_T0: begin
                // Force IR so select_and_encode sees Ra=R7, Rb=R0, C=0x65
                force DUT.IR_reg.q = IR_LD_CASE1;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end

            LD1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end

            LD1_T2: begin
                MDRout <= 1; IRin <= 1;
                release DUT.IR_reg.q; // let IR latch the value from MDR
                // NOTE: MDR has PC content not our instruction here.
                // Because we are not using real memory for instruction fetch,
                // we keep the force approach and release after T2 latches it.
                force DUT.IR_reg.q = IR_LD_CASE1;
            end

            LD1_T3: begin
                // Grb selects Rb=R0 from IR, BAout gates 0 onto bus -> Y=0
                Grb <= 1; BAout <= 1; Yin <= 1;
            end

            LD1_T4: begin
                // Z = Y + C = 0 + 0x65 = 0x65
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end

            LD1_T5: begin
                // MAR = Z = 0x65
                Zout <= 1; MARin <= 1;
            end

            LD1_T6: begin
                // Read mem[0x65] -> MDR
                Read <= 1; MDRin <= 1;
            end

            LD1_T7: begin
                // R7 = MDR = mem[0x65] = 0x84
                MDRout <= 1; Gra <= 1; Rin <= 1;
                release DUT.IR_reg.q;
            end

            // ─────────────────────────────────────────────────
            // ld CASE 2: ld R0, 0x72(R2)  R2=0x57, mem[0xC9]=0x2B
            //            effective addr = R2 + 0x72 = 0x57+0x72 = 0xC9
            //            expect R0 = 0x2B
            // ─────────────────────────────────────────────────
            LD2_T0: begin
                force DUT.IR_reg.q = IR_LD_CASE2;
                // Also need R2=0x57 loaded - we preload this via force too
                force DUT.R2_reg.q = 32'h57;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end

            LD2_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end

            LD2_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_LD_CASE2;
            end

            LD2_T3: begin
                // Grb selects Rb=R2, BAout=1 -> R2 value (0x57) goes to bus -> Y=0x57
                Grb <= 1; BAout <= 1; Yin <= 1;
            end

            LD2_T4: begin
                // Z = Y + C = 0x57 + 0x72 = 0xC9
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end

            LD2_T5: begin
                Zout <= 1; MARin <= 1;
            end

            LD2_T6: begin
                Read <= 1; MDRin <= 1;
            end

            LD2_T7: begin
                // R0 = MDR = mem[0xC9] = 0x2B
                MDRout <= 1; Gra <= 1; Rin <= 1;
                release DUT.IR_reg.q;
                release DUT.R2_reg.q;
            end

            // ─────────────────────────────────────────────────
            // ldi CASE 3: ldi R7, 0x65  -> R7 = 0x65
            // ─────────────────────────────────────────────────
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

            LDI3_T3: begin
                // Grb selects Rb=R0, BAout=1 -> 0 on bus -> Y=0
                Grb <= 1; BAout <= 1; Yin <= 1;
            end

            LDI3_T4: begin
                // Z = 0 + C = 0x65
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end

            LDI3_T5: begin
                // R7 = Z = 0x65  (no memory access for ldi)
                Zout <= 1; Gra <= 1; Rin <= 1;
                release DUT.IR_reg.q;
            end

            // ─────────────────────────────────────────────────
            // ldi CASE 4: ldi R0, 0x72(R2)  R2=0x57
            //             R0 = R2 + 0x72 = 0x57 + 0x72 = 0xC9
            // ─────────────────────────────────────────────────
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

            LDI4_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end

            LDI4_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end

            LDI4_T5: begin
                // R0 = R2 + C = 0x57 + 0x72 = 0xC9
                Zout <= 1; Gra <= 1; Rin <= 1;
                release DUT.IR_reg.q;
                release DUT.R2_reg.q;
            end

            Done: begin
                deassert_all();
                // Results are checked in the monitor block below
            end

        endcase
    end

    // ── Result monitor ───────────────────────────────────────
    // Check register values one cycle after each instruction completes
    integer pass = 0, fail = 0;

    task check;
        input [31:0] got;
        input [31:0] expected;
        input [63:0] label;
        begin
            if (got === expected) begin
                $display("  PASS test %0d: got 0x%08h", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL test %0d: expected 0x%08h, got 0x%08h",
                         label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    always @(posedge clock) begin
	$display("t=%0t state=%0d Bus=0x%08h MAR=0x%08h MDR=0x%08h R7=0x%08h IR=0x%08h",
             $time, Present_state, DUT.Bus, DUT.MAR_reg.q, DUT.MDR_reg.mdr.q, 
             DUT.R7_reg.q, DUT.IR_reg.q);
        // After LD1_T7 completes, R7 should = 0x84
        if (Present_state == LD1_T7) begin
            #2;
            $display("-- ld Case 1: ld R7, 0x65 --");
            check(DUT.R7_reg.q, 32'h84, 1);
        end

        // After LD2_T7 completes, R0 should = 0x2B
        if (Present_state == LD2_T7) begin
            #2;
            $display("-- ld Case 2: ld R0, 0x72(R2) --");
            check(DUT.R0_reg.q, 32'h2B, 2);
        end

        // After LDI3_T5, R7 should = 0x65
        if (Present_state == LDI3_T5) begin
            #2;
            $display("-- ldi Case 3: ldi R7, 0x65 --");
            check(DUT.R7_reg.q, 32'h65, 3);
        end

        // After LDI4_T5, R0 should = 0xC9
        if (Present_state == LDI4_T5) begin
            #2;
            $display("-- ldi Case 4: ldi R0, 0x72(R2) --");
            check(DUT.R0_reg.q, 32'hC9, 4);
        end

        if (Present_state == Done) begin
            #2;
            $display("===== Results: %0d passed, %0d failed =====", pass, fail);
            $stop;
        end
    end

    // ── Reset ────────────────────────────────────────────────
    initial begin
        $display("===== ld / ldi Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule