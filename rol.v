//Rotate left module
module rol (
	//wire inputs
	input wire [31:0] a,b,
	output wire [31:0] z
);
	//rotate left operation
	reg [31:0] temp;
	always @ (*)
		begin
			temp = ((a << b) | (a >> (32 - b)));
		end
	assign z = temp;
endmodule
