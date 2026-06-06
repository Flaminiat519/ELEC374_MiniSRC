//Push button interface — converts active-low DE0-CV button signals to active-high for the CPU
//KEY0 (PIN_U7) → Reset.In, KEY1 (PIN_W9) → Stop.In
module push_button (
	input  wire key0, //KEY0 (PIN_U7) — active-low Reset
	input  wire key1, //KEY1 (PIN_W9) — active-low Stop
	output wire reset_in, //Active-high Reset to CPU
	output wire stop_in //Active-high Stop to CPU
);
	//Invert active-low button signals to active-high for the CPU
	assign reset_in = ~key0;
	assign stop_in  = ~key1;
endmodule
