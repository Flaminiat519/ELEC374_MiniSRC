`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_brnz
//  brnz R3, 48  — branch if R3 != 0
//
//  Case 1 (TAKEN):     R3=0x00000005 -> CON=1 -> PC jumps to 0x41
//  Case 2 (NOT TAKEN): R3=0x00000000 -> CON=0 -> PC stays at 0x11
//
//  brnz: opcode=5'b10101, C2=2'b01 -> IR[22:19]=4'b0001
// ================================================================
module tb_brnz;

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

    localparam ADD = 13'b0000000010000;
    // brnz R3, 48: C2=01 -> IR[22:19]=4'b0001
    localparam IR_BRNZ = {5'b10101, 4'd3, 4'b0001, 19'd48};

    parameter
        Default  = 5'd0,
        C1_T0    = 5'd1,
        C1_T1    = 5'd2,
        C1_T2    = 5'd3,
        C1_T3    = 5'd4,
        C1_T4    = 5'd5,
        C1_T5    = 5'd6,
        C1_T6    = 5'd7,
        C1_Done  = 5'd8,
        C2_T0    = 5'd9,
        C2_T1    = 5'd10,
        C2_T2    = 5'd11,
        C2_T3    = 5'd12,
        C2_T4    = 5'd13,
        C2_T5    = 5'd14,
        C2_T6    = 5'd15,
        DONE     = 5'd16;

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
            C1_T5   : Present_state <= C1_T6;
            C1_T6   : Present_state <= C1_Done;
            C1_Done : Present_state <= C2_T0;
            C2_T0   : Present_state <= C2_T1;
            C2_T1   : Present_state <= C2_T2;
            C2_T2   : Present_state <= C2_T3;
            C2_T3   : Present_state <= C2_T4;
            C2_T4   : Present_state <= C2_T5;
            C2_T5   : Present_state <= C2_T6;
            C2_T6   : Present_state <= DONE;
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
            // Case 1: TAKEN — R3=5 (nonzero)
            // ═══════════════════════════════════
            Default: begin
                force DUT.R3_reg.q     = 32'h00000005;
                force DUT.PC_reg.qTemp = 32'h00000010;
                force DUT.IR_reg.q     = IR_BRNZ;
            end
            C1_T0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_BRNZ;
            end
            C1_T3: begin
                Gra <= 1; Rout <= 1; CON_In <= 1;
            end
            C1_T4: begin
                PCout <= 1; Yin <= 1;
            end
            C1_T5: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            C1_T6: begin
                Zout <= 1; PCin <= 1;
            end
            C1_Done: begin
                release DUT.R3_reg.q;
                release DUT.PC_reg.qTemp;
                release DUT.IR_reg.q;
            end

            // ═══════════════════════════════════
            // Case 2: NOT TAKEN — R3=0 (zero)
            // ═══════════════════════════════════
            C2_T0: begin
                force DUT.R3_reg.q     = 32'h00000000;
                force DUT.PC_reg.qTemp = 32'h00000010;
                force DUT.IR_reg.q     = IR_BRNZ;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C2_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C2_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_BRNZ;
            end
            C2_T3: begin
                Gra <= 1; Rout <= 1; CON_In <= 1;
            end
            C2_T4: begin
                PCout <= 1; Yin <= 1;
            end
            C2_T5: begin
                Cout <= 1; alu_op <= ADD; Zin <= 1;
            end
            C2_T6: begin
                Zout <= 1; PCin <= 1;
            end
            DONE: begin
                release DUT.R3_reg.q;
                release DUT.PC_reg.qTemp;
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
                $display("  PASS %-35s got=0x%08h", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-35s exp=0x%08h got=0x%08h", label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    always @(posedge clock) begin
        #2;
        case (Present_state)
            C1_Done: begin
                $display("-- brnz Case 1: TAKEN (R3=5, nonzero) --");
                check(DUT.CON_unit.CON,  1'b1,        "CON FF = 1");
                check(DUT.PC_reg.qTemp,  32'h00000041, "PC = 0x41 (branch taken)");
            end
            DONE: begin
                $display("-- brnz Case 2: NOT TAKEN (R3=0, zero) --");
                check(DUT.CON_unit.CON,  1'b0,        "CON FF = 0");
                check(DUT.PC_reg.qTemp,  32'h00000011, "PC = 0x11 (not taken)");
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    initial begin
        $display("===== brnz Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule