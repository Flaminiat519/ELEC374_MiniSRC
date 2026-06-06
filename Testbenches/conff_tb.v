`timescale 1ns/10ps
// =============================================================
//  Testbench: tb_con_ff
//  Tests all four branch conditions with:
//    - values that SHOULD set CON=1 (branch taken)
//    - values that SHOULD set CON=0 (branch not taken)
//  Also verifies: clear resets CON, CONin=0 holds old value
// =============================================================
module conff_tb;

    // ── DUT signals ──────────────────────────────────────────
    reg         clk;
    reg         clear;
    reg         CONin;
    reg  [1:0]  C2;
    reg  [31:0] Bus_Data;
    wire        CON;

    // ── DUT ──────────────────────────────────────────────────
    con_ff dut (
        .clk      (clk),
        .clear    (clear),
        .CONin    (CONin),
        .C2       (C2),
        .Bus_Data (Bus_Data),
        .CON      (CON)
    );

    // ── Clock ────────────────────────────────────────────────
    initial clk = 0;
    always #10 clk = ~clk;

    // ── Helpers ──────────────────────────────────────────────
    integer pass = 0;
    integer fail = 0;

    // Latch condition on next rising edge, then check
    task apply_and_check;
        input [1:0]  c2_in;
        input [31:0] bus_in;
        input        con_in_en;
        input        expected_CON;
        input [127:0] label;
        begin
            C2       = c2_in;
            Bus_Data = bus_in;
            CONin    = con_in_en;
            @(posedge clk); #1;
            CONin = 0;  // de-assert so next test doesn't re-latch
            if (CON === expected_CON) begin
                $display("  PASS %-40s CON=%b", label, CON);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-40s exp=%b got=%b", label, expected_CON, CON);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        $display("===== CON FF Testbench =====");
        clear = 1; CONin = 0; C2 = 2'b00; Bus_Data = 32'b0;
        @(posedge clk); #1;
        clear = 0;

        // ==================================================
        // C2=00 : brzr – branch if zero
        // ==================================================
        $display("-- brzr (C2=00) --");
        apply_and_check(2'b00, 32'h0000_0000, 1, 1, "brzr: Bus=0 (zero)     -> CON=1");
        apply_and_check(2'b00, 32'h0000_0001, 1, 0, "brzr: Bus=1 (nonzero)  -> CON=0");
        apply_and_check(2'b00, 32'hFFFF_FFFF, 1, 0, "brzr: Bus=-1 (nonzero) -> CON=0");

        // ==================================================
        // C2=01 : brnz – branch if nonzero
        // ==================================================
        $display("-- brnz (C2=01) --");
        apply_and_check(2'b01, 32'h0000_0001, 1, 1, "brnz: Bus=1 (nonzero)  -> CON=1");
        apply_and_check(2'b01, 32'hFFFF_FFFF, 1, 1, "brnz: Bus=-1 (nonzero) -> CON=1");
        apply_and_check(2'b01, 32'h0000_0000, 1, 0, "brnz: Bus=0 (zero)     -> CON=0");

        // ==================================================
        // C2=10 : brpl – branch if positive (>0, not negative)
        // ==================================================
        $display("-- brpl (C2=10) --");
        apply_and_check(2'b10, 32'h0000_0007, 1, 1, "brpl: Bus=7  (pos)     -> CON=1");
        apply_and_check(2'b10, 32'h7FFF_FFFF, 1, 1, "brpl: Bus=MAX_POS      -> CON=1");
        apply_and_check(2'b10, 32'h0000_0000, 1, 0, "brpl: Bus=0  (zero)    -> CON=0");
        apply_and_check(2'b10, 32'hFFFF_FFFF, 1, 0, "brpl: Bus=-1 (neg)     -> CON=0");
        apply_and_check(2'b10, 32'h8000_0000, 1, 0, "brpl: Bus=MIN_NEG      -> CON=0");

        // ==================================================
        // C2=11 : brmi – branch if negative (MSB=1)
        // ==================================================
        $display("-- brmi (C2=11) --");
        apply_and_check(2'b11, 32'hFFFF_FFFF, 1, 1, "brmi: Bus=-1 (neg)     -> CON=1");
        apply_and_check(2'b11, 32'h8000_0000, 1, 1, "brmi: Bus=MIN_NEG      -> CON=1");
        apply_and_check(2'b11, 32'h0000_0000, 1, 0, "brmi: Bus=0  (zero)    -> CON=0");
        apply_and_check(2'b11, 32'h0000_0001, 1, 0, "brmi: Bus=1  (pos)     -> CON=0");

        // ==================================================
        // CONin=0: value should NOT be updated
        // ==================================================
        $display("-- CONin=0 hold test --");
        // First set CON to a known value (CON=1 via brzr with zero)
        apply_and_check(2'b00, 32'h0, 1, 1, "Setup: brzr Bus=0 -> CON=1");
        // Now present a condition that would give CON=0, but CONin=0
        C2 = 2'b00; Bus_Data = 32'h1; CONin = 0;
        @(posedge clk); #1;
        if (CON === 1'b1) begin
            $display("  PASS CONin=0 holds previous CON=1");
            pass = pass + 1;
        end else begin
            $display("  FAIL CONin=0 should hold CON=1, got CON=%b", CON);
            fail = fail + 1;
        end

        // ==================================================
        // Synchronous clear
        // ==================================================
        $display("-- clear test --");
        clear = 1;
        @(posedge clk); #1;
        clear = 0;
        if (CON === 1'b0) begin
            $display("  PASS clear resets CON to 0");
            pass = pass + 1;
        end else begin
            $display("  FAIL clear did not reset CON, got %b", CON);
            fail = fail + 1;
        end

        $display("===== Results: %0d passed, %0d failed =====", pass, fail);
        $finish;
    end

endmodule