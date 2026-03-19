`timescale 1ns/10ps

module cpu_tb;

reg Clock;
reg Reset;
reg Stop;

wire [31:0] BusMuxOut;

CPU dut(
    .Clock(Clock),
    .Reset(Reset),
    .Stop(Stop),
    .BusMuxOut(BusMuxOut)
);

// clock
initial begin
    Clock = 0;
    forever #10 Clock = ~Clock;
end

// test sequence
initial begin
    Stop = 0;
    Reset = 0;

    #50;
    Reset = 1;

    #50;
    Reset = 0;

    #60000;
    $stop;
end

// cycle-by-cycle trace
always @(posedge Clock) begin
    if (!Reset) begin
        $display(
            "Time=%0t | PC=%h | IR=%h | BUS=%h | STATE=%0d",
            $time,
            dut.dp.PC,
            dut.dp.IR,
            BusMuxOut,
            dut.con.present_state
        );
    end
end

// print register dump after each instruction completes
reg seen_non_fetch0;

initial begin
    seen_non_fetch0 = 0;
end

always @(posedge Clock) begin
    if (Reset) begin
        seen_non_fetch0 <= 0;
    end
    else begin
        // once we've left fetch0 at least once, we know an instruction is in flight
        if (dut.con.present_state != 6'd1)
            seen_non_fetch0 <= 1;

        // instruction complete = returned to fetch0
        if ((dut.con.present_state == 6'd1) && seen_non_fetch0) begin
            $display("");
            $display("===== INSTRUCTION COMPLETE @ t=%0t =====", $time);
            $display("PC  = %h | IR  = %h | BUS = %h", dut.dp.PC, dut.dp.IR, BusMuxOut);

            $display("R0  = %h | R1  = %h | R2  = %h | R3  = %h",
                     dut.dp.R0, dut.dp.R1, dut.dp.R2, dut.dp.R3);
            $display("R4  = %h | R5  = %h | R6  = %h | R7  = %h",
                     dut.dp.R4, dut.dp.R5, dut.dp.R6, dut.dp.R7);
            $display("R8  = %h | R9  = %h | R10 = %h | R11 = %h",
                     dut.dp.R8, dut.dp.R9, dut.dp.R10, dut.dp.R11);
            $display("R12 = %h | R13 = %h | R14 = %h | R15 = %h",
                     dut.dp.R12, dut.dp.R13, dut.dp.R14, dut.dp.R15);

            $display("HI  = %h | LO  = %h", dut.dp.HI, dut.dp.LO);
            $display("Y   = %h | Z   = %h | ZHI = %h", dut.dp.Y, dut.dp.Z, dut.dp.ZHI);
            $display("MAR = %h | MDR = %h", dut.dp.MAR, dut.dp.MDR);
            $display("CON = %b", dut.dp.CON);
			
			// After a ST instruction (opcode 10010), print the memory location
            // that was just written so we can verify the store worked correctly.
            // ST opcode = 5'b10010, sits in IR[31:27].
            if (dut.dp.IR[31:27] == 5'b10010) begin
                $display("--- ST completed: M[%h] = %h ---",
                         dut.dp.MAR, dut.dp.RAM.mem[dut.dp.MAR[8:0]]);
            end
			
            $display("========================================");
            $display("");
        end
		
		if (dut.con.present_state == 6'd37) begin
			$display("HALT reached at time %0t", $time);
			$stop;
		end
    end
end

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_tb);
end

endmodule