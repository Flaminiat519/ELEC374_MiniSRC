`timescale 1ns/10ps

module cpu_tb;

reg Clock;
reg Reset;
reg Stop;

wire [31:0] BusMuxOut;

// Instantiate CPU
CPU dut(
    .Clock(Clock),
    .Reset(Reset),
    .Stop(Stop),
    .BusMuxOut(BusMuxOut)
);

//
// CLOCK GENERATOR
//
initial begin
    Clock = 0;
    forever #10 Clock = ~Clock;
end

//
// MAIN TEST
//
initial begin

    $display("=====================================");
    $display("      MiniSRC Phase 3 Simulation     ");
    $display("=====================================");

    Stop = 0;
    Reset = 1;

    #50;
    Reset = 0;

    // allow program to run
    #60000;

    $display("Simulation timeout reached.");
    $stop;

end


//
// INSTRUCTION TRACE
//
always @(posedge Clock) begin

    if(!Reset) begin

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


//
// HALT DETECTOR
//
always @(posedge Clock) begin

    if(dut.dp.IR == 32'hD8000000) begin
        $display("HALT instruction detected at time %0t", $time);
        $display("Program execution completed.");
        #50;
        $stop;
    end

end


//
// WAVEFORM OUTPUT
//
initial begin

    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_tb);

end

endmodule