//32-bit rotate left
module rol (
	input wire [31:0] a, b,
	output wire [31:0] z
);
	reg [31:0] temp;

	always @(*) begin
		//Rotate a left by b positions
		temp = (a << b) | (a >> (32 - b));
	end

	assign z = temp;
endmodule
