`timescale 1ns/10ps
// =============================================================
//  Testbench: tb_ram
//  Tests the synchronous 512x32 RAM (read, write, no-op)
// =============================================================
module ram_tb;

    // ── DUT signals ──────────────────────────────────────────
    reg         clk;
    reg         read;
    reg         write;
    reg  [8:0]  address;
    reg  [31:0] data_in;
    wire [31:0] data_out;

    // ── DUT instantiation ────────────────────────────────────
    ram dut (
        .clk      (clk),
        .read     (read),
        .write    (write),
        .address  (address),
        .data_in  (data_in),
        .data_out (data_out)
    );

    // ── Clock: 20 ns period ──────────────────────────────────
    initial clk = 0;
    always #10 clk = ~clk;

    // ── Helper task: apply one clock cycle ──────────────────
    task tick;
        input [8:0]  addr;
        input [31:0] din;
        input        wr;
        input        rd;
        begin
            address  = addr;
            data_in  = din;
            write    = wr;
            read     = rd;
            @(posedge clk); #1; // sample just after rising edge
        end
    endtask

    // ── Test stimulus ────────────────────────────────────────
    integer pass = 0;
    integer fail = 0;

    task check;
        input [31:0] got;
        input [31:0] expected;
        input [63:0] test_num;
        begin
            if (got === expected) begin
                $display("  PASS test %0d: got 0x%08h", test_num, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL test %0d: expected 0x%08h, got 0x%08h",
                         test_num, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        $display("===== RAM Testbench =====");
        read = 0; write = 0; address = 0; data_in = 0;

        // ── Test 1: Write to address 0x010, read it back ─────
        $display("-- Test 1: write 0xDEADBEEF to addr 0x010 --");
        tick(9'h010, 32'hDEAD_BEEF, 1, 0);   // write cycle
        tick(9'h010, 32'h0,         0, 1);   // read  cycle
        @(posedge clk); #1;
        check(data_out, 32'hDEAD_BEEF, 1);

        // ── Test 2: Write to address 0x1FF (last), read back ─
        $display("-- Test 2: write 0xCAFEBABE to addr 0x1FF (boundary) --");
        tick(9'h1FF, 32'hCAFE_BABE, 1, 0);
        tick(9'h1FF, 32'h0,         0, 1);
        @(posedge clk); #1;
        check(data_out, 32'hCAFE_BABE, 2);

        // ── Test 3: Write to two different addresses, confirm
        //           they do not alias ─────────────────────────
        $display("-- Test 3: no address aliasing (addr 0x001 vs 0x002) --");
        tick(9'h001, 32'hAAAA_AAAA, 1, 0);
        tick(9'h002, 32'h5555_5555, 1, 0);
        tick(9'h001, 32'h0,         0, 1);
        @(posedge clk); #1;
        check(data_out, 32'hAAAA_AAAA, 3);
        tick(9'h002, 32'h0,         0, 1);
        @(posedge clk); #1;
        check(data_out, 32'h5555_5555, 4);

        // ── Test 4: Overwrite a location ─────────────────────
        $display("-- Test 4: overwrite addr 0x010 --");
        tick(9'h010, 32'h1234_5678, 1, 0);
        tick(9'h010, 32'h0,         0, 1);
        @(posedge clk); #1;
        check(data_out, 32'h1234_5678, 5);

        // ── Test 5: No read/write – data_out should hold last value
        $display("-- Test 5: idle cycle (no read/write), output holds --");
        tick(9'h010, 32'h0, 0, 0);
        @(posedge clk); #1;
        check(data_out, 32'h1234_5678, 6);   // registered output holds

        // ── Summary ──────────────────────────────────────────
        $display("===== Results: %0d passed, %0d failed =====", pass, fail);
        $finish;
    end

endmodule