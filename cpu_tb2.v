//CPU TESTBENCH
`timescale 1ns/10ps

module cpu_tb2;

reg Clock;
reg Reset;
reg Stop;

wire [31:0] BusMuxOut;

//initiate datapath
CPU dut(
    .Clock(Clock),
    .Reset(Reset),
    .Stop(Stop),
    .BusMuxOut(BusMuxOut)
);

//clock
initial begin
    Clock = 0;
    forever #10 Clock = ~Clock;
end

//begin sequence
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


//print after each instruction completes
reg seen_non_fetch0;

initial begin
    seen_non_fetch0 = 0;
end

always @(posedge Clock) begin
    if (Reset) begin
        seen_non_fetch0 <= 0;
    end
    else begin
        //once we've left fetch0 at least once, we know an instruction has begun running
        if (dut.con.present_state != 6'd1)
            seen_non_fetch0 <= 1;

        //instruction complete = returned to fetch0
        if ((dut.con.present_state == 6'd1) && seen_non_fetch0) begin
            $display("");
            $display("Time: t=%0t", $time);
            $display("PC = %h, IR = %h, BUS = %h", dut.dp.PC, dut.dp.IR, BusMuxOut);
			$display("MAR = %h , MDR = %h", dut.dp.MAR, dut.dp.MDR);

            $display("R0 = %h , R1 = %h , R2 = %h , R3 = %h",
                     dut.dp.R0, dut.dp.R1, dut.dp.R2, dut.dp.R3);
            $display("R4 = %h , R5 = %h , R6 = %h , R7 = %h",
                     dut.dp.R4, dut.dp.R5, dut.dp.R6, dut.dp.R7);
            $display("R8 = %h , R9  = %h , R10 = %h , R11 = %h",
                     dut.dp.R8, dut.dp.R9, dut.dp.R10, dut.dp.R11);
            $display("R12 = %h , R13 = %h , R14 = %h , R15 = %h",
                     dut.dp.R12, dut.dp.R13, dut.dp.R14, dut.dp.R15);

            $display("HI = %h , LO = %h", dut.dp.HI, dut.dp.LO);
            $display("Y = %h , Z  = %h , ZHI = %h", dut.dp.Y, dut.dp.Z, dut.dp.ZHI);
            $display("CON = %b", dut.dp.CON);
			
			//Print out specific memory after store
            if (dut.dp.IR[31:27] == 5'b10010) begin
                $display("ST: M[%h] = %h",
                         dut.dp.MAR, dut.dp.RAM.mem[dut.dp.MAR[8:0]]);
            end
			
        end
		
		//print store memory before and after
		if (dut.con.present_state == 6'd37) begin
			$display("HALT at time %0t", $time);
			$stop;
		end
    end
end

initial begin
    $dumpfile("cpu.vcd");
  $dumpvars(0, cpu_tb2);
end

endmodule
