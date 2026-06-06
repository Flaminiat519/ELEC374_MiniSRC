//Full adder — computes a 1-bit sum and carry-out
module full_adder (
	input xi, yi, c_in,
	output si, c_out
);
	assign si    = xi ^ yi ^ c_in; //Sum bit
	assign c_out = (xi & yi) | (xi & c_in) | (yi & c_in); //Carry-out
endmodule
