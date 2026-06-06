`timescale 1ns/10ps
// =============================================================
//  Testbench: tb_io_ports
//
//  Tests the Input Port and Output Port register behaviour
//  as they are wired inside data_path:
//
//    INPORT  register (.enable(INPORT_In),  .BusMuxIn(MDatain))
//    OUTPORT register (.enable(OUTPORT_In), .BusMuxIn(Bus))
//
//  Also tests register0 BAout masking since it is the R0
//  revision required by Phase 2.
//
//  We instantiate the individual register / register0 modules
//  directly – no need to bring up the whole datapath.
// =============================================================

// ── Minimal register definition (mirrors your actual module) ─
// If your register.v file is already compiled, remove this block.
module register #(
    parameter DATA_WIDTH_IN  = 32,
    parameter DATA_WIDTH_OUT = 32,
    parameter INIT           = 32'b0
)(
    input  wire                       clear,
    input  wire                       clock,
    input  wire                       enable,
    input  wire [DATA_WIDTH_IN-1:0]   BusMuxIn,
    output wire [DATA_WIDTH_OUT-1:0]  BusMuxOut
);
    reg [DATA_WIDTH_IN-1:0] q;
    initial q = INIT;
    always @(posedge clock) begin
        if (clear)       q <= {DATA_WIDTH_IN{1'b0}};
        else if (enable) q <= BusMuxIn;
    end
    assign BusMuxOut = q;
endmodule

// =============================================================
module io_tb;

    // ── Clock ────────────────────────────────────────────────
    reg clk;
    initial clk = 0;
    always #10 clk = ~clk;

    // ── Common control ───────────────────────────────────────
    reg clear;

    // ── INPORT signals ───────────────────────────────────────
    reg         INPORT_In;         // enable (strobe from input unit)
    reg  [31:0] MDatain;           // data from input unit
    wire [31:0] INPORT;            // registered output -> Bus

    // ── OUTPORT signals ──────────────────────────────────────
    reg         OUTPORT_In;        // enable
    reg  [31:0] Bus_data;          // from bus (simulates BusMuxOut)
    wire [31:0] OUTPORT;           // output to external device

    // ── register0 (R0) signals ───────────────────────────────
    reg         R0_enable;
    reg         BAout;
    reg  [31:0] R0_in;
    wire [31:0] R0_out;

    // ── DUT instantiations ───────────────────────────────────
    register INPORT_reg (
        .clear     (clear),
        .clock     (clk),
        .enable    (INPORT_In),
        .BusMuxIn  (MDatain),
        .BusMuxOut (INPORT)
    );

    register OUTPORT_reg (
        .clear     (clear),
        .clock     (clk),
        .enable    (OUTPORT_In),
        .BusMuxIn  (Bus_data),
        .BusMuxOut (OUTPORT)
    );

    register0 R0_reg (
        .clear     (clear),
        .clock     (clk),
        .enable    (R0_enable),
        .BAout     (BAout),
        .BusMuxIn  (R0_in),
        .BusMuxOut (R0_out)
    );

    // ── Helpers ──────────────────────────────────────────────
    integer pass = 0;
    integer fail = 0;

    task check32;
        input [31:0]  got;
        input [31:0]  expected;
        input [127:0] label;
        begin
            if (got === expected) begin
                $display("  PASS %-45s got=0x%08h", label, got);
                pass = pass + 1;
            end else begin
                $display("  FAIL %-45s exp=0x%08h got=0x%08h",
                         label, expected, got);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        $display("===== I/O Ports & Register0 Testbench =====");
        clear = 1; INPORT_In = 0; OUTPORT_In = 0;
        MDatain = 0; Bus_data = 0;
        R0_enable = 0; BAout = 0; R0_in = 0;
        @(posedge clk); #1;
        clear = 0;

        // ==================================================
        // SECTION A – INPORT
        // ==================================================
        $display("-- INPORT tests --");

        // A1: Load value 0xABCD_1234 into INPORT
        MDatain   = 32'hABCD_1234;
        INPORT_In = 1;
        @(posedge clk); #1;
        INPORT_In = 0;
        check32(INPORT, 32'hABCD_1234, "INPORT: load 0xABCD1234");

        // A2: INPORT_In=0 – register should hold its value
        MDatain = 32'hDEAD_BEEF;  // new data on line but enable low
        @(posedge clk); #1;
        check32(INPORT, 32'hABCD_1234, "INPORT: hold when enable=0");

        // A3: Overwrite with new value
        MDatain   = 32'h0000_00FF;
        INPORT_In = 1;
        @(posedge clk); #1;
        INPORT_In = 0;
        check32(INPORT, 32'h0000_00FF, "INPORT: overwrite 0x000000FF");

        // A4: Clear resets to 0
        clear = 1;
        @(posedge clk); #1;
        clear = 0;
        check32(INPORT, 32'h0000_0000, "INPORT: clear resets to 0");

        // ==================================================
        // SECTION B – OUTPORT
        // ==================================================
        $display("-- OUTPORT tests --");

        // B1: Load from Bus
        Bus_data   = 32'h1234_5678;
        OUTPORT_In = 1;
        @(posedge clk); #1;
        OUTPORT_In = 0;
        check32(OUTPORT, 32'h1234_5678, "OUTPORT: load 0x12345678 from Bus");

        // B2: Hold when enable=0
        Bus_data = 32'hFFFF_FFFF;
        @(posedge clk); #1;
        check32(OUTPORT, 32'h1234_5678, "OUTPORT: hold when enable=0");

        // B3: Typical ALU result written to output port (out R7)
        Bus_data   = 32'h0000_0042;
        OUTPORT_In = 1;
        @(posedge clk); #1;
        OUTPORT_In = 0;
        check32(OUTPORT, 32'h0000_0042, "OUTPORT: out R7 result = 0x42");

        // B4: Clear
        clear = 1;
        @(posedge clk); #1;
        clear = 0;
        check32(OUTPORT, 32'h0000_0000, "OUTPORT: clear resets to 0");

        // ==================================================
        // SECTION C – register0 / BAout masking
        //   When BAout=1, R0 output should be all-zeros
        //   When BAout=0, R0 output = stored value
        // ==================================================
        $display("-- register0 / BAout tests --");

        // C1: Store value, BAout=0 -> output the value
        R0_in    = 32'hDEAD_BEEF;
        R0_enable = 1;
        BAout    = 0;
        @(posedge clk); #1;
        R0_enable = 0;
        check32(R0_out, 32'hDEAD_BEEF, "R0: BAout=0 -> output stored value");

        // C2: BAout=1 -> output should be 0 (R0 acts as base=0 for ld/st)
        BAout = 1;
        #1;  // combinational – no clock edge needed
        check32(R0_out, 32'h0000_0000, "R0: BAout=1 -> output forced to 0");

        // C3: BAout back to 0 -> value returns
        BAout = 0;
        #1;
        check32(R0_out, 32'hDEAD_BEEF, "R0: BAout=0 restored -> value back");

        // C4: BAout=1 with zero stored (edge case)
        clear = 1;
        @(posedge clk); #1;
        clear = 0;
        BAout = 1;
        #1;
        check32(R0_out, 32'h0000_0000, "R0: BAout=1 with stored=0 -> 0");

        // ==================================================
        $display("===== Results: %0d passed, %0d failed =====", pass, fail);
        $finish;
    end

endmodule