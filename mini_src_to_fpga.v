//Top-level FPGA module — connects the CPU to physical I/O on the DE0-CV board
`timescale 1ns/10ps
module mini_src_to_fpga(
	input wire CLOCK_50,
	input wire [1:0] KEY,
	input wire [7:0] SWITCHES,
	output wire [9:0] LEDS,
	output [7:0] HEX0, HEX1
);
	wire reset_in, stop_in;
	wire [31:0] inport, outport;
	wire halted;
	wire run;
	wire [31:0] bus;
	wire divided_clk;

	//CPU is running when neither halted nor stopped
	assign run = ~halted & ~stop_in;

	//Divide 50MHz clock down to a simulation-friendly frequency
	frequency_divider fd(.CLOCK_50(CLOCK_50), .reset(reset_in), .div_clk(divided_clk));

	//Only LEDS[5] is used — clear the rest
	assign LEDS[9:6] = 4'b0;
	assign LEDS[4:0] = 5'b0;

	//Map push buttons to reset and stop signals
	push_button buttons(.key0(KEY[0]), .key1(KEY[1]), .reset_in(reset_in), .stop_in(stop_in));
	//Map switches to the CPU input port
	switch_input switches(.sw(SWITCHES), .in_port(inport));

	//CPU instance
	CPU cpu(.Clock(divided_clk), .Reset(reset_in), .Stop(stop_in), .Inport(inport), .Outport(outport), .Halted(halted), .BusMuxOut(bus));

	//LEDS[5] shows run/halt status
	led_indicator leds(.run(run), .ledr5(LEDS[5]));
	//HEX displays show the CPU output port value
	seven_seg_display hex_display(.clk(CLOCK_50), .out_port(outport), .hex0(HEX0), .hex1(HEX1));

endmodule
