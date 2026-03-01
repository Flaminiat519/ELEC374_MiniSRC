`timescale 1ns/10ps
// ================================================================
//  Testbench: tb_brzr
//  brzr R3, 48  — branch if R3 == 0
//
//  Case 1 (TAKEN):     R3=0x00000000 -> CON=1 -> PC jumps to 0x41
//  Case 2 (NOT TAKEN): R3=0x00000005 -> CON=0 -> PC stays at 0x11
//
//  Control Sequence:
//    T0: PCout, MARin, IncPC, Zin
//    T1: Zlowout, PCin, Read, MDRin
//    T2: MDRout, IRin
//    T3: Gra, Rout, CONin
//    T4: PCout, Yin
//    T5: Cout, ADD, Zin
//    T6: Zlowout, CON->PCin
//
//  PC starts at 0x10, incremented to 0x11 in T1
//  Branch offset C=48=0x30
//  Taken target = 0x11 + 0x30 = 0x41
//
//  B-Format: {opcode[31:27], Ra[26:23], C2[22:19], C[18:0]}
//  brzr: opcode=5'b10101, C2=2'b00 -> IR[22:19]=4'b0000
// ================================================================
module tb_brzr;

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
    // brzr R3, 48: opcode=10101, Ra=R3(0011), C2=00(brzr)->IR[22:19]=4'b0000, C=48
    localparam IR_BRZR = {5'b10101, 4'd3, 4'b0000, 19'd48};

    parameter
        Default   = 4'd0,
        // Case 1: TAKEN (R3=0)
        C1_T0     = 4'd1,
        C1_T1     = 4'd2,
        C1_T2     = 4'd3,
        C1_T3     = 4'd4,
        C1_T4     = 4'd5,
        C1_T5     = 4'd6,
        C1_T6     = 4'd7,
        C1_Done   = 4'd8,
        // Case 2: NOT TAKEN (R3=5)
        C2_T0     = 4'd9,
        C2_T1     = 4'd10,
        C2_T2     = 4'd11,
        C2_T3     = 4'd12,
        C2_T4     = 4'd13,
        C2_T5     = 4'd14,
        C2_T6     = 4'd15,
        Done      = 4'd0; // reuse 0 as Done (last state)

    // Need 5 bits since Done wraps — use 5-bit state
    parameter DONE = 5'd16;
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
            // Case 1: TAKEN — R3=0, CON=1
            // PC=0x10 -> after fetch PC=0x11
            // branch target = 0x11 + 48 = 0x41
            // ═══════════════════════════════════
            Default: begin
                force DUT.R3_reg.q    = 32'h00000000;
                force DUT.PC_reg.qTemp = 32'h00000010;
                force DUT.IR_reg.q    = IR_BRZR;
            end
            C1_T0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C1_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C1_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_BRZR;
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
            // Case 2: NOT TAKEN — R3=5, CON=0
            // PC=0x10 -> after fetch PC=0x11
            // branch NOT taken, PC stays at 0x11
            // ═══════════════════════════════════
            C2_T0: begin
                force DUT.R3_reg.q    = 32'h00000005;
                force DUT.PC_reg.qTemp = 32'h00000010;
                force DUT.IR_reg.q    = IR_BRZR;
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            C2_T1: begin
                Zout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            C2_T2: begin
                MDRout <= 1; IRin <= 1;
                force DUT.IR_reg.q = IR_BRZR;
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
                $display("-- brzr Case 1: TAKEN (R3=0) --");
                check(DUT.CON_unit.CON,   1'b1,        "CON FF = 1");
                check(DUT.PC_reg.qTemp,   32'h00000041, "PC = 0x41 (branch taken)");
            end
            DONE: begin
                $display("-- brzr Case 2: NOT TAKEN (R3=5) --");
                check(DUT.CON_unit.CON,   1'b0,        "CON FF = 0");
                check(DUT.PC_reg.qTemp,   32'h00000011, "PC = 0x11 (not taken)");
                $display("===== Results: %0d passed, %0d failed =====", pass, fail);
                $stop;
            end
        endcase
    end

    initial begin
        $display("===== brzr Testbench =====");
        clear = 1;
        #20 clear = 0;
    end

endmodule