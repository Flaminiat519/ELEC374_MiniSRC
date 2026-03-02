`timescale 1ns/10ps
// =============================================================
//  Testbench: tb_select_and_encode
//  Tests:
//    1. Gra/Grb/Grc register field selection -> R_in / R_out
//    2. Sign extension of constant C (IR[18] is the sign bit)
//    3. BAout: R0 decode still raises R_out[0] so the register0
//       module can AND it with ~BAout internally
//    4. Rin=0 / Rout=0 gate the outputs to zero
// =============================================================
module sande_tb;

    // ── DUT signals ──────────────────────────────────────────
    reg  [31:0] IR;
    reg         Gra, Grb, Grc;
    reg         Rin, Rout, BAout;
    wire [31:0] C;
    wire [15:0] R_in, R_out;

    // ── DUT ──────────────────────────────────────────────────
    select_and_encode_logic dut (
        .IR    (IR),
        .Gra   (Gra),  .Grb  (Grb),  .Grc  (Grc),
        .Rin   (Rin),  .Rout (Rout), .BAout(BAout),
        .C     (C),
        .R_in  (R_in), .R_out(R_out)
    );

    // ── Helpers ──────────────────────────────────────────────
    integer pass = 0;
    integer fail = 0;

    task check16;
        input [15:0] got;
        input [15:0] expected;
        input [127:0] label;
        begin
            if (got === expected) begin
                $display("  PASS %-30s got=%016b", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-30s exp=%016b got=%016b",
                         label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    task check32;
        input [31:0] got;
        input [31:0] expected;
        input [127:0] label;
        begin
            if (got === expected) begin
                $display("  PASS %-30s got=0x%08h", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-30s exp=0x%08h got=0x%08h",
                         label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    // ── IR field helpers ─────────────────────────────────────
    // IR[31:27]=opcode  IR[26:23]=Ra  IR[22:19]=Rb  IR[18:15]=Rc  IR[18:0]=C
    function [31:0] make_IR;
        input [4:0]  opcode;
        input [3:0]  Ra, Rb, Rc;
        input [14:0] C_low;   // IR[14:0]
        begin
            make_IR = {opcode, Ra, Rb, Rc, C_low};
        end
    endfunction

    initial begin
        $display("===== Select-and-Encode Testbench =====");
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b0;
        IR = 32'b0;
        #5;

        // ==================================================
        // SECTION A – Register selection with Rin
        // ==================================================
        $display("-- Rin tests --");

        // A1: Gra selects Ra=R7, Rin=1 -> R_in[7] should be 1
        IR = make_IR(5'b0, 4'd7, 4'd0, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b100100;  // Gra=1,Rin=1
        #5;
        check16(R_in,  16'h0080, "Gra=1 Ra=7 Rin=1 -> R_in[7]");
        check16(R_out, 16'h0000, "Gra=1 Ra=7 Rin=1 -> R_out=0");

        // A2: Grb selects Rb=R3, Rin=1 -> R_in[3]
        IR = make_IR(5'b0, 4'd0, 4'd3, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b010100;  // Grb=1,Rin=1
        #5;
        check16(R_in,  16'h0008, "Grb=1 Rb=3 Rin=1 -> R_in[3]");

        // A3: Grc selects Rc=R15, Rin=1 -> R_in[15]
        IR = make_IR(5'b0, 4'd0, 4'd0, 4'd15, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b001100;  // Grc=1,Rin=1
        #5;
        check16(R_in,  16'h8000, "Grc=1 Rc=15 Rin=1 -> R_in[15]");

        // A4: Rin=0 -> R_in must be all zeros even with Gra
        IR = make_IR(5'b0, 4'd5, 4'd0, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b100000;  // Gra=1,Rin=0
        #5;
        check16(R_in,  16'h0000, "Gra=1 Rin=0 -> R_in=0");

        // ==================================================
        // SECTION B – Register selection with Rout
        // ==================================================
        $display("-- Rout tests --");

        // B1: Gra Ra=R2, Rout=1 -> R_out[2]
        IR = make_IR(5'b0, 4'd2, 4'd0, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b100010;  // Gra=1,Rout=1
        #5;
        check16(R_out, 16'h0004, "Gra=1 Ra=2 Rout=1 -> R_out[2]");

        // B2: BAout=1, Grb, Rb=R0 -> R_out[0] is raised (register0 handles zeroing)
        IR = make_IR(5'b0, 4'd0, 4'd0, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b010001;  // Grb=1,BAout=1
        #5;
        check16(R_out, 16'h0001, "Grb=1 Rb=R0 BAout=1 -> R_out[0]=1");

        // B3: BAout=1, Grb, Rb=R5 -> R_out[5]
        IR = make_IR(5'b0, 4'd0, 4'd5, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b010001;  // Grb=1,BAout=1
        #5;
        check16(R_out, 16'h0020, "Grb=1 Rb=R5 BAout=1 -> R_out[5]");

        // ==================================================
        // SECTION C – Sign extension of C
        //   C = IR[18:0],  sign bit = IR[18]
        // ==================================================
        $display("-- Sign-extension tests --");

        // C1: IR[18]=0, positive constant 0x0001F -> expect 0x0000_001F
        IR = 32'b0;
        IR[18:0] = 19'b000_0000_0000_0001_1111;  // 0x0001F, IR[18]=0
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b0;
        #5;
        check32(C, 32'h0000_001F, "C sign-ext positive 0x1F");

        // C2: IR[18]=1, negative -> upper 13 bits should be 1s
        // IR[18:0] = 19'b111_1111_1111_1111_1111 = 0x7FFFF -> C = 0xFFFF_FFFF
        IR = 32'b0;
        IR[18:0] = 19'h7FFFF;
        #5;
        check32(C, 32'hFFFF_FFFF, "C sign-ext all-ones 0x7FFFF");

        // C3: IR[18]=1, partial negative: IR[18:0]=19'b1_0000_0000_0000_0000 = 0x40000
        // Expected C = {13{1}, 19'h40000} = 0xFFFC_0000
        IR = 32'b0;
        IR[18:0] = 19'h40000;
        #5;
        check32(C, 32'hFFFC_0000, "C sign-ext 0x40000 -> 0xFFFC0000");

        // C4: IR[18]=0, zero constant
        IR = 32'b0;
        #5;
        check32(C, 32'h0000_0000, "C sign-ext zero");

        // ==================================================
        // SECTION D – Multiple Gra/Grb/Grc conflicts
        //   Only the OR of the selected fields matters
        // ==================================================
        $display("-- Combined Gra+Grb select --");
        // Ra=4, Rb=4 (same) with Gra=Grb=1, Rin=1 -> R_in[4]
        IR = make_IR(5'b0, 4'd4, 4'd4, 4'd0, 15'b0);
        {Gra,Grb,Grc,Rin,Rout,BAout} = 6'b110100;
        #5;
        check16(R_in, 16'h0010, "Gra=Grb=1 same reg -> R_in[4]");

        // ==================================================
        $display("===== Results: %0d passed, %0d failed =====", pass, fail);
        $finish;
    end

endmodule