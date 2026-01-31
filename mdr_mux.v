`timescale 1ns/10ps

module mdr_mux (
	input wire [31:0] BusMuxOut,
	input wire Read,
	input wire [31:0] MDAtain,
	output wire [31:0] Q
	);
	
	reg [31:0] qTemp;
	always @ (*)
		begin
			if (Read) begin
				qTemp <= MDAtain;
			end
			else begin
				qTemp <= BusMuxOut;
			end
		end
	assign Q = qTemp;
endmodule 