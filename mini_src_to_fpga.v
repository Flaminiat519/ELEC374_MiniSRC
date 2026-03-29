`timescale 1ns/10ps

module mini_src_to_fpga{
	input wire CLOCK_50,
	input wire [1:0] KEY,
	input wire [7:0] SWITCHES,
	output wire [9:0] LEDS,
	output [7:0] HEX0, HEX1
};
	
	wire reset_in, stop_in;
	wire [31:0] inport, outport;
	wire halted;
	wire run;
	wire [31:0] bus;
	
	assign run = ~halted & ~stop_in; //Running when not halted or stopped
	//Only need LED 5
	assign LEDS[9:6] = 4'b0;
	assign LEDS[4:0] = 5'b0;
	
	//Set up bottons and switches for input
	push_button buttons(.key0(KEY[0]), .key1(KEY[1]), .reset_in(reset_in), .stop_in(stop_in));
	switch_input switches(.sw(SWITCHES), .inport(inport));
	
	//Instantiate CPU
	CPU cpu(.Clock(CLOCK_50), .Reset(reset_in), .Stop(stop_in), .Inport(inport), .Outport(outport), .Halted(halted), .BusMuxOut(bus));
	
	//Set up led 5 and hex displays for output
	led_indicator leds (.run(run), .ledr5(LEDS[5]));
	seven_seg_display hex_display(.clk(CLOCK_50), .out_port(outport), .hex0(HEX0), .hex1(HEX1));
	
endmodule
	
	
	