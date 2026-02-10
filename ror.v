//Rotate right module
module ror (
	//wire initialization
	input wire [31:0] a, b,
	output wire [31:0] z
);
	//rotate right operation
	reg [31:0] temp;
	always @ (*)
		begin
			temp = ((a >> b) | (a << (32 - b)));
		end
	assign z = temp;
endmodule
