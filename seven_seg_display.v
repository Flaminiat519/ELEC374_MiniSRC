//Seven-segment display — shows the lower 8 bits of Out.Port across two digits
//HEX0 = lower nibble (bits [3:0]), HEX1 = upper nibble (bits [7:4])
//DE0-CV segments are active-low (0 = ON)
module seven_seg_display (
	input wire clk,
    input wire [31:0] out_port, //32-bit output port from CPU
	output reg  [7:0]  hex0, //Lower nibble display
	output reg  [7:0]  hex1 //Upper nibble display
);
	//Lower nibble → HEX0
	always @(negedge clk) begin
		case (out_port[3:0])
			4'b0000: hex0 <= 8'b11000000; //0
			4'b0001: hex0 <= 8'b11111001; //1
			4'b0010: hex0 <= 8'b10100100; //2
			4'b0011: hex0 <= 8'b10110000; //3
			4'b0100: hex0 <= 8'b10011001; //4
			4'b0101: hex0 <= 8'b10010010; //5
			4'b0110: hex0 <= 8'b10000010; //6
			4'b0111: hex0 <= 8'b11111000; //7
			4'b1000: hex0 <= 8'b10000000; //8
			4'b1001: hex0 <= 8'b10010000; //9
			4'b1010: hex0 <= 8'b10001000; //A
			4'b1011: hex0 <= 8'b10000011; //B
			4'b1100: hex0 <= 8'b11000110; //C
			4'b1101: hex0 <= 8'b10100001; //D
			4'b1110: hex0 <= 8'b10000110; //E
			4'b1111: hex0 <= 8'b10001110; //F
			default: hex0 <= 8'b11111111; //Off
		endcase
	end

	//Upper nibble → HEX1
	always @(negedge clk) begin
		case (out_port[7:4])
			4'b0000: hex1 <= 8'b11000000; //0
			4'b0001: hex1 <= 8'b11111001; //1
			4'b0010: hex1 <= 8'b10100100; //2
			4'b0011: hex1 <= 8'b10110000; //3
			4'b0100: hex1 <= 8'b10011001; //4
			4'b0101: hex1 <= 8'b10010010; //5
			4'b0110: hex1 <= 8'b10000010; //6
			4'b0111: hex1 <= 8'b11111000; //7
			4'b1000: hex1 <= 8'b10000000; //8
			4'b1001: hex1 <= 8'b10010000; //9
			4'b1010: hex1 <= 8'b10001000; //A
			4'b1011: hex1 <= 8'b10000011; //B
			4'b1100: hex1 <= 8'b11000110; //C
			4'b1101: hex1 <= 8'b10100001; //D
			4'b1110: hex1 <= 8'b10000110; //E
			4'b1111: hex1 <= 8'b10001110; //F
			default: hex1 <= 8'b11111111; //Off
		endcase
	end
endmodule
