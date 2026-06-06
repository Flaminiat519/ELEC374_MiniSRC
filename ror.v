//32-bit rotate right
module ror (
	input wire [31:0] a, b,
	output wire [31:0] z
);
	reg [31:0] temp;

	always @(*) begin
		//Rotate a right by b positions
		temp = (a >> b) | (a << (32 - b));
	end

	assign z = temp;
endmodule
