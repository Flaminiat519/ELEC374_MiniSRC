/*`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_ld_ldi
//  Cases:
//    Case 1: ld  R7, 0x65        mem[0x65]=0x84  -> R7=0x84
//    Case 2: ld  R0, 0x72(R2)    R2=0x57, mem[0xC9]=0x2B -> R0=0x2B
//    Case 3: ldi R7, 0x65        -> R7=0x65
//    Case 4: ldi R0, 0x72(R2)    R2=0x57 -> R0=0xC9
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

    // ── IR encodings ─────────────────────────────────────────
    // IR = {opcode[31:27], Ra[26:23], Rb[22:19], C[18:0]}
    localparam IR_LD_CASE1  = {5'b00000, 4'd7, 4'd0, 19'h065}; // ld  R7, 0x65
    localparam IR_LD_CASE2  = {5'b00000, 4'd0, 4'd2, 19'h072}; // ld  R0, 0x72(R2)
    localparam IR_LDI_CASE3 = {5'b00001, 4'd7, 4'd0, 19'h065}; // ldi R7, 0x65
    localparam IR_LDI_CASE4 = {5'b00001, 4'd0, 4'd2, 19'h072}; // ldi R0, 0x72(R2)

    // ── State encoding ───────────────────────────────────────
    parameter
        Default    = 6'd0,
        LD1_T0     = 6'd1,
        LD1_T1     = 6'd2,
        LD1_T2     = 6'd3,
        LD1_T3     = 6'd4,
        LD1_T4     = 6'd5,
        LD1_T5     = 6'd6,
        LD1_T6     = 6'd7,   // Assert Read only
        LD1_T6b    = 6'd8,   // Assert MDRin (RAM data stable)
        LD1_T7     = 6'd9,   // MDRout, Gra, Rin -> R7
        LD1_Done   = 6'd10,
        LD2_T0     = 6'd11,
        LD2_T1     = 6'd12,
        LD2_T2     = 6'd13,
        LD2_T3     = 6'd14,
        LD2_T4     = 6'd15,
        LD2_T5     = 6'd16,
        LD2_T6     = 6'd17,
        LD2_T6b    = 6'd18,
        LD2_T7     = 6'd19,
        LD2_Done   = 6'd20,
        LDI3_T0    = 6'd21,
        LDI3_T1    = 6'd22,
        LDI3_T2    = 6'd23,
        LDI3_T3    = 6'd24,
        LDI3_T4    = 6'd25,
        LDI3_T5    = 6'd26,
        LDI3_Done  = 6'd27,
        LDI4_T0    = 6'd28,
        LDI4_T1    = 6'd29,
        LDI4_T2    = 6'd30,
        LDI4_T3    = 6'd31,
        LDI4_T4    = 6'd32,
        LDI4_T5    = 6'd33,
        LDI4_Done  = 6'd34,
        Done       = 6'd35;

    reg [5:0] Present_state = Default;

    // ── State transitions ────────────────────────────────────
    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default   : Present_state <= LD1_T0;
            LD1_T0    : Present_state <= LD1_T1;
            LD1_T1    : Present_state <= LD1_T2;
            LD1_T2    : Present_state <= LD1_T3;
            LD1_T3    : Present_state <= LD1_T4;
            LD1_T4    : Present_state <= LD1_T5;
            LD1_T5    : Present_state <= LD1_T6;
            LD1_T6    : Present_state <= LD1_T6b;
            LD1_T6b   : Present_state <= LD1_T7;
            LD1_T7    : Present_state <= LD1_Done;
            LD1_Done  : Present_state <= LD2_T0;
            LD2_T0    : Present_state <= LD2_T1;
            LD2_T1    : Present_state <= LD2_T2;
            LD2_T2    : Present_state <= LD2_T3;
            LD2_T3    : Present_state <= LD2_T4;
            LD2_T4    : Present_state <= LD2_T5;
            LD2_T5    : Present_state <= LD2_T6;
            LD2_T6    : Present_state <= LD2_T6b;
            LD2_T6b   : Present_state <= LD2_T7;
            LD2_T7    : Present_state <= LD2_Done;
            LD2_Done  : Present_state <= LDI3_T0;
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
                force DUT.R2_reg.q = 32'h57; // preload R2 for Cases 2 & 4
            end

            // ═══════════════════════════════════
            // ld Case 1: ld R7, 0x65
            // ═══════════════════════════════════
            LD1_T0: begin
                force DUT.IR_reg.q = IR_LD_CASE1;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            LD1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            LD1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_LD_CASE1;
            end
            LD1_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LD1_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            LD1_T5: begin
                Zout <= 1; MARin <= 1;
            end
            LD1_T6: begin
                Read <= 1; // RAM output becomes stable after this cycle
            end
            LD1_T6b: begin
                Read <= 1; MDRin <= 1; // latch the stable RAM data into MDR
            end
            LD1_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            LD1_Done: begin
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // ld Case 2: ld R0, 0x72(R2)
            // ═══════════════════════════════════
            LD2_T0: begin
                force DUT.IR_reg.q = IR_LD_CASE2;
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
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LD2_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            LD2_T5: begin
                Zout <= 1; MARin <= 1;
            end
            LD2_T6: begin
                Read <= 1;
            end
            LD2_T6b: begin
                Read <= 1; MDRin <= 1;
            end
            LD2_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            LD2_Done: begin
                release DUT.IR_reg.q;
                release DUT.R2_reg.q;
            end

            // ═══════════════════════════════════
            // ldi Case 3: ldi R7, 0x65
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
            LDI3_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LDI3_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            LDI3_T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1;
            end
            LDI3_Done: begin
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // ldi Case 4: ldi R0, 0x72(R2)
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
            LDI4_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LDI4_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
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

    // Check in Done states — register has fully latched by then
    always @(posedge clock) begin
        #2;
        case (Present_state)
            LD1_Done: begin
                $display("-- ld Case 1: ld R7, 0x65 --");
                check(DUT.R7_reg.q, 32'h00000084, 1);
            end
            LD2_Done: begin
                $display("-- ld Case 2: ld R0, 0x72(R2) --");
                check(DUT.R0_reg.q, 32'h0000002B, 2);
            end
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
        $display("===== ld / ldi Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule*/

`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_ld
//  Cases:
//    Case 1: ld R7, 0x65        mem[0x65]=0x84  -> R7=0x84
//    Case 2: ld R0, 0x72(R2)    R2=0x57, mem[0xC9]=0x2B -> R0=0x2B
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
    localparam ADD = 13'b0000000010000;

    // ── IR encodings ─────────────────────────────────────────
    localparam IR_LD_CASE1 = {5'b00000, 4'd7, 4'd0, 19'h065}; // ld R7, 0x65
    localparam IR_LD_CASE2 = {5'b00000, 4'd0, 4'd2, 19'h072}; // ld R0, 0x72(R2)

    // ── State encoding ───────────────────────────────────────
    parameter
        Default   = 5'd0,
        LD1_T0    = 5'd1,
        LD1_T1    = 5'd2,
        LD1_T2    = 5'd3,
        LD1_T3    = 5'd4,
        LD1_T4    = 5'd5,
        LD1_T5    = 5'd6,
        LD1_T6    = 5'd7,
        LD1_T6b   = 5'd8,
        LD1_T7    = 5'd9,
        LD1_Done  = 5'd10,
        LD2_T0    = 5'd11,
        LD2_T1    = 5'd12,
        LD2_T2    = 5'd13,
        LD2_T3    = 5'd14,
        LD2_T4    = 5'd15,
        LD2_T5    = 5'd16,
        LD2_T6    = 5'd17,
        LD2_T6b   = 5'd18,
        LD2_T7    = 5'd19,
        LD2_Done  = 5'd20,
        Done      = 5'd21;

    reg [4:0] Present_state = Default;

    // ── State transitions ────────────────────────────────────
    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default  : Present_state <= LD1_T0;
            LD1_T0   : Present_state <= LD1_T1;
            LD1_T1   : Present_state <= LD1_T2;
            LD1_T2   : Present_state <= LD1_T3;
            LD1_T3   : Present_state <= LD1_T4;
            LD1_T4   : Present_state <= LD1_T5;
            LD1_T5   : Present_state <= LD1_T6;
            LD1_T6   : Present_state <= LD1_T6b;
            LD1_T6b  : Present_state <= LD1_T7;
            LD1_T7   : Present_state <= LD1_Done;
            LD1_Done : Present_state <= LD2_T0;
            LD2_T0   : Present_state <= LD2_T1;
            LD2_T1   : Present_state <= LD2_T2;
            LD2_T2   : Present_state <= LD2_T3;
            LD2_T3   : Present_state <= LD2_T4;
            LD2_T4   : Present_state <= LD2_T5;
            LD2_T5   : Present_state <= LD2_T6;
            LD2_T6   : Present_state <= LD2_T6b;
            LD2_T6b  : Present_state <= LD2_T7;
            LD2_T7   : Present_state <= LD2_Done;
            LD2_Done : Present_state <= Done;
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
                force DUT.R2_reg.q = 32'h57; // preload R2 for Case 2
            end

            // ═══════════════════════════════════
            // ld Case 1: ld R7, 0x65
            // ═══════════════════════════════════
            LD1_T0: begin
                force DUT.IR_reg.q = IR_LD_CASE1;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            LD1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            LD1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_LD_CASE1;
            end
            LD1_T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LD1_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            LD1_T5: begin
                Zout <= 1; MARin <= 1;
            end
            LD1_T6: begin
                Read <= 1;
            end
            LD1_T6b: begin
                Read <= 1; MDRin <= 1;
            end
            LD1_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            LD1_Done: begin
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // ld Case 2: ld R0, 0x72(R2)
            // ═══════════════════════════════════
            LD2_T0: begin
                force DUT.IR_reg.q = IR_LD_CASE2;
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
                Grb <= 1; BAout <= 1; Yin <= 1;
            end
            LD2_T4: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            LD2_T5: begin
                Zout <= 1; MARin <= 1;
            end
            LD2_T6: begin
                Read <= 1;
            end
            LD2_T6b: begin
                Read <= 1; MDRin <= 1;
            end
            LD2_T7: begin
                MDRout <= 1; Gra <= 1; Rin <= 1;
            end
            LD2_Done: begin
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
            LD1_Done: begin
                $display("-- ld Case 1: ld R7, 0x65 --");
                check(DUT.R7_reg.q, 32'h00000084, 1);
            end
            LD2_Done: begin
                $display("-- ld Case 2: ld R0, 0x72(R2) --");
                check(DUT.R0_reg.q, 32'h0000002B, 2);
            end
            Done: begin
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    // ── Reset ────────────────────────────────────────────────
    initial begin
        $display("===== ld Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule