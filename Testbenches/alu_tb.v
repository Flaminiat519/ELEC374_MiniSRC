//ALU testbench (every operation)
`timescale 1ns/1ps
module alu_tb;
	
	reg clk;
	reg [31:0] RA;
	reg [31:0] RB;
	reg [4:0] opcode;
	reg [12:0] ALU_op;
	wire [63:0] RZ;
	
	ALU ALU_instance(.RA(RA), .RB(RB), 
	.ALU_op(ALU_op), .RZ(RZ));
	
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
	
	always @(*) begin
		ALU_op = 13'b0;
		ALU_op[opcode] = 1'b1;
	end
	
	initial begin
		//Testing with RA = 4 and RB = 5
		RA = 32'd4;
		RB = 32'd5;
		
		opcode = 5'd0; //AND (RZ = 4)
		#10;
		
		opcode = 5'd1; //OR (RZ = 5)
		#10;
		
		opcode = 5'd2; //NOT (RZ = 11)
		#10;
		
		opcode = 5'd3; //NEG (RZ = -4)
		#10;
		
		opcode = 5'd4; //ADD (RZ = 9)
		#10;
		
		opcode = 5'd5; //SUB (RZ = -1)
		#10;
		
		opcode = 5'd6; //MUL (RZ = 20)
		#10;
		
		opcode = 5'd7; //DIV (0R4)
		#10;
		
		opcode = 5'd8; //SLL (RZ = 8)
		#10;
		
		opcode = 5'd9; //SRL (RZ = 2)
		#10;
		
		opcode = 5'd10; //SRA (RZ = 2)
		#10;
		
		opcode = 5'd11; //ROR (RZ = 2)
		#10;
		
		opcode = 5'd12; //ROL (RZ = 8)
		#10;
		
		$stop;
	end
endmodule
		
