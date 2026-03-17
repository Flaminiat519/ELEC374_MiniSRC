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

initial begin
    Clock = 0;
    forever #10 Clock = ~Clock;
end

initial begin
	
	#50
    Stop = 0;
	#50
    Reset = 1;

    #50;
    Reset = 0;

    #60000;

    $stop;

end

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




initial begin

    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_tb);

end

endmodule