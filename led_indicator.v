//LED indicator — drives LEDR5 (PIN_N1) to show whether the CPU is running or halted
module led_indicator (
	input  wire run, //Run.Out signal (1 = running, 0 = halted)
	output wire ledr5 //Active-high, connected to LEDR5 PIN_N1
);
	assign ledr5 = run;
endmodule
