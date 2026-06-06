//Switch input — maps SW[7:0] to the lower 8 bits of In.Port; upper 24 bits are 0
//SW0 = PIN_U13, SW1 = PIN_V13, SW2 = PIN_T13, SW3 = PIN_T12
//SW4 = PIN_AA15, SW5 = PIN_AB15, SW6 = PIN_AA14, SW7 = PIN_AA13
module switch_input (
    input wire [7:0] sw, //Physical slide switches SW[7:0]
    output wire [31:0] in_port //32-bit In.Port to CPU
);
	assign in_port = {24'b0, sw[7:0]};
endmodule
