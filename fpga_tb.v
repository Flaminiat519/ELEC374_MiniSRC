`timescale 1ns/10ps
module fpga_tb;

// --- Board-level signals ---
reg        clk_50;       // 50 MHz oscillator
reg        key0;         // Reset (active-low)
reg        key1;         // Stop  (active-low)
reg  [7:0] sw;           // Slide switches SW[7:0]

wire       ledr5;        // Run/Halt LED
wire [7:0] hex0;         // 7-seg digit 0 (lower nibble of out_port)
wire [7:0] hex1;         // 7-seg digit 1 (upper nibble of out_port)

// --- Instantiate FPGA top-level ---
fpga_top dut (
    .clk_50  (clk_50),
    .key0    (key0),
    .key1    (key1),
    .sw      (sw),
    .ledr5   (ledr5),
    .hex0    (hex0),
    .hex1    (hex1)
);

// --- 50 MHz clock (period = 20ns) ---
initial begin
    clk_50 = 0;
    forever #10 clk_50 = ~clk_50;
end

// --- Board reset + switch init ---
initial begin
    key0 = 1;   // buttons released (active-low, so 1 = not pressed)
    key1 = 1;
    sw   = 8'hE0; // spec says initialize switches to 0xE0

    // pulse reset: press KEY0 (drive low), hold, release
    #50;
    key0 = 0;   // assert reset
    #100;
    key0 = 1;   // deassert reset – CPU begins executing

    // run long enough for the full test program
    // the loop runs 5 * 8 iterations with 0xFFFF delay cycles each
    // at 50 MHz sim this is large – adjust #delay as needed
    #20000000;

    $display("Sim done at t=%0t", $time);
    $stop;
end

// --- Monitor board outputs after each CPU instruction ---
reg seen_non_fetch0;
initial seen_non_fetch0 = 0;

always @(posedge clk_50) begin
    if (~key0) begin  // reset active
        seen_non_fetch0 <= 0;
    end else begin
        // track when we've left fetch state at least once
        if (dut.cpu.con.present_state != 6'd1)
            seen_non_fetch0 <= 1;

        // print on return to fetch (instruction complete)
        if ((dut.cpu.con.present_state == 6'd1) && seen_non_fetch0) begin
            $display("");
            $display("Time: t=%0t", $time);
            $display("PC=%h  IR=%h", dut.cpu.dp.PC, dut.cpu.dp.IR);
            $display("MAR=%h  MDR=%h", dut.cpu.dp.MAR, dut.cpu.dp.MDR);
            $display("R0=%h  R1=%h  R2=%h  R3=%h",
                      dut.cpu.dp.R0,  dut.cpu.dp.R1,
                      dut.cpu.dp.R2,  dut.cpu.dp.R3);
            $display("R4=%h  R5=%h  R6=%h  R7=%h",
                      dut.cpu.dp.R4,  dut.cpu.dp.R5,
                      dut.cpu.dp.R6,  dut.cpu.dp.R7);
            $display("R8=%h  R9=%h  R10=%h  R11=%h",
                      dut.cpu.dp.R8,  dut.cpu.dp.R9,
                      dut.cpu.dp.R10, dut.cpu.dp.R11);
            $display("R12=%h  R13=%h  R14=%h  R15=%h",
                      dut.cpu.dp.R12, dut.cpu.dp.R13,
                      dut.cpu.dp.R14, dut.cpu.dp.R15);
            $display("HI=%h  LO=%h", dut.cpu.dp.HI, dut.cpu.dp.LO);
            $display("SW=%h  | LEDR5=%b | HEX1=%b HEX0=%b",
                      sw, ledr5, hex1, hex0);

            // print out_port on OUT instruction
            if (dut.cpu.dp.IR[31:27] == 5'b11000) begin  // adjust opcode to match yours
                $display("OUT: out_port = %h  -> HEX1=%b HEX0=%b",
                          dut.cpu.dp.out_port, hex1, hex0);
            end

            // print in_port on IN instruction
            if (dut.cpu.dp.IR[31:27] == 5'b10111) begin  // adjust opcode to match yours
                $display("IN:  sw=%h -> in_port=%h", sw, dut.in_port);
            end

            // halt state
            if (dut.cpu.con.present_state == 6'd37) begin
                $display("HALT at t=%0t", $time);
                $display("Final: HEX1=%b HEX0=%b (expect 0x63)", hex1, hex0);
                $stop;
            end
        end
    end
end

// --- Optional: change switches mid-run to test IN robustness ---
// initial begin
//     #15000000;
//     sw = 8'h70;  // simulate user flipping switches
// end

initial begin
    $dumpfile("fpga_top.vcd");
    $dumpvars(0, fpga_top_tb);
end

endmodule