`timescale 1ns/10ps

module con_ff (
	input wire [1:0] IR_Bits,
	input wire [31:0] Bus_Data,
	input wire CON_In,
	output wire CON_Out
	);
		
	wire [3:0] dOut;
	reg flag;
	initial flag = 0;
	
	decoder_2_4 decoder_2_4_instance (IR_Bits, dOut);
	
	always @ (posedge CON_In)
		begin
			case (dOut)
				4'b0001 : flag <= (Bus_Data == 32'b0) ? 1 : 0;
				4'b0010 : flag <= (Bus_Data != 32'b0) ? 1 : 0;
				4'b0100 : flag <= (Bus_Data[31] == 1'b0) ? 1 : 0;
				4'b1000 : flag <= (Bus_Data[31] == 1'b1) ? 1 : 0;
				default : flag <= 0;
			endcase
		end
	
	d_ff d_ff_instance (flag, CON_In, CON_Out);
	
endmodule