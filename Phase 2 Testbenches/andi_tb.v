`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_andi
//  andi R7, R4, 0x71  — R7 = R4 & 0x71
//
//  Control Sequence (same as addi but AND in T4):
//    T0-T2: instruction fetch
//    T3: Grb, Rout, Yin
//    T4: Cout, AND, Zin
//    T5: Zlowout, Gra, Rin
//
//  I-Format: {opcode[31:27], Ra[26:23], Rb[22:19], C[18:0]}
//  andi opcode = 5'b01010
//
//  Test cases:
//    Case 1: andi R7, R4, 0x71  R4=0xFF -> R7 = 0xFF & 0x71 = 0x71
//    Case 2: andi R7, R4, 0x71  R4=0xAA -> R7 = 0xAA & 0x71 = 0x20
// ================================================================
module andi_tb;

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

    initial clock = 0;
    always #10 clock = ~clock;

    // ALU ops
    localparam AND = 13'b0000000000001; // bit 0
    localparam ADD = 13'b0000000010000; // bit 4 (used for fetch Z path)

    // andi R7, R4, 0x71
    localparam IR_ANDI = {5'b01010, 4'd7, 4'd4, 19'h00071};

    parameter
        Default  = 5'd0,
        C1_T0    = 5'd1,
        C1_T1    = 5'd2,
        C1_T2    = 5'd3,
        C1_T3    = 5'd4,
        C1_T4    = 5'd5,
        C1_T5    = 5'd6,
        C1_Done  = 5'd7,
        C2_T0    = 5'd8,
        C2_T1    = 5'd9,
        C2_T2    = 5'd10,
        C2_T3    = 5'd11,
        C2_T4    = 5'd12,
        C2_T5    = 5'd13,
        DONE     = 5'd14;

    reg [4:0] Present_state = Default;

    always @(posedge clock) begin
        if (clear) Present_state <= Default;
        else case (Present_state)
            Default : Present_state <= C1_T0;
            C1_T0   : Present_state <= C1_T1;
            C1_T1   : Present_state <= C1_T2;
            C1_T2   : Present_state <= C1_T3;
            C1_T3   : Present_state <= C1_T4;
            C1_T4   : Present_state <= C1_T5;
            C1_T5   : Present_state <= C1_Done;
            C1_Done : Present_state <= C2_T0;
            C2_T0   : Present_state <= C2_T1;
            C2_T1   : Present_state <= C2_T2;
            C2_T2   : Present_state <= C2_T3;
            C2_T3   : Present_state <= C2_T4;
            C2_T4   : Present_state <= C2_T5;
            C2_T5   : Present_state <= DONE;
            DONE    : Present_state <= DONE;
        endcase
    end

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

    always @(Present_state) begin
        deassert_all();
        case (Present_state)

            // ═══════════════════════════════════
            // Case 1: andi R7, R4, 0x71
            // R4=0xFF -> R7 = 0xFF & 0x71 = 0x71
            // ═══════════════════════════════════
            Default: begin
                force DUT.R4_reg.q = 32'h000000FF;
                force DUT.IR_reg.q = IR_ANDI;
            end
            C1_T0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_ANDI;
            end
            // T3: Y = R4 = 0xFF
            C1_T3: begin
                Grb <= 1; Rout <= 1; Yin <= 1;
            end
            // T4: Z = Y & C = 0xFF & 0x71 = 0x71
            C1_T4: begin
                Cout <= 1; alu_op <= AND; Zin <= 1;
            end
            // T5: R7 = Z = 0x71
            C1_T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1;
            end
            C1_Done: begin
                release DUT.R4_reg.q;
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // Case 2: andi R7, R4, 0x71
            // R4=0xAA -> R7 = 0xAA & 0x71 = 0x20
            // 0xAA = 1010 1010
            // 0x71 = 0111 0001
            // AND  = 0010 0000 = 0x20
            // ═══════════════════════════════════
            C2_T0: begin
                force DUT.R4_reg.q = 32'h000000AA;
                force DUT.IR_reg.q = IR_ANDI;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C2_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C2_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_ANDI;
            end
            C2_T3: begin
                Grb <= 1; Rout <= 1; Yin <= 1;
            end
            C2_T4: begin
                Cout <= 1; alu_op <= AND; Zin <= 1;
            end
            C2_T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1;
            end
            DONE: begin
                release DUT.R4_reg.q;
                release DUT.IR_reg.q;
            end

        endcase
    end

    integer pass = 0, fail = 0;
    task check;
        input [31:0] got;
        input [31:0] expected;
        input [127:0] label;
        begin
            if (got === expected) begin
                $display("  PASS %-40s got=0x%08h", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-40s exp=0x%08h got=0x%08h", label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    always @(posedge clock) begin
        #2;
        case (Present_state)
            C1_Done: begin
                $display("-- andi Case 1: andi R7, R4, 0x71 (R4=0xFF) --");
                check(DUT.R7_reg.q, 32'h00000071, "R7 = 0xFF & 0x71 = 0x71");
            end
            DONE: begin
                $display("-- andi Case 2: andi R7, R4, 0x71 (R4=0xAA) --");
                check(DUT.R7_reg.q, 32'h00000020, "R7 = 0xAA & 0x71 = 0x20");
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    initial begin
        $display("===== andi Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule