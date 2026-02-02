//Define ALU components control variables
`define AND 0
`define OR 1
`define NOT 2
`define SLL 3
`define SRL 4
`define SRA 5
`define ADD 6
`define SUB 7
`define MUL 8
`define DIV 9
`define NEG 10
`define ROR 11
`define ROL 12


module ALU (
	input wire [31:0] RA, RB,
	input wire [12:0] ALU_op;
	output reg [63:0] RZ
);

	wire [31:0] and_result;
	wire [31:0] or_result;
	wire [31:0] not_result;
	wire [31:0] neg_result;
	wire carry;
	wire [31:0] add_result;
	wire [31:0] sub_result;
	wire [63:0] mul_result;
	wire [63:0] div_result;
	
	and_gate and_instance (RA, RB, and_result);
	or_gate or_instance (RA, RB, or_result);
	negate neg (RA, neg_result);
	full_adder add (RA, RB, 1'd0, carry, add_result);
	not_gate not_instance (RA, not_result);
	div div (RA, RB, div_result[63:32], div_result[31:0]);
	mult_32b mul (RA, RB, mul_result);
	

	always @(*) begin
		RZ = 64'b0;

		if (ALU_op[`AND]) begin
			RZ[31:0] = and_result;
		end
		else if (ALU_op[`OR]) begin
			RZ[31:0] = or_result;
		end
		else if (ALU_op[`NOT]) begin
			RZ[31:0] = not_result;
		end
		else if (ALU_op[`NEG]) begin
			RZ[31:0] = neg_result;
		end
		else if (ALU_op[`ADD]) begin
			RZ[31:0] = add_result;
		end
		else if (ALU_op[`SUB]) begin
			RZ[31:0] = sub_result;
		end
		else if (ALU_op[`MUL]) begin
			RZ = mul_result;
		end
		else if (ALU_op[`DIV]) begin
			RZ = div_result;
		end
		else if (ALU_op[`SLL]) begin
			RZ[31:0] = {RA[30:0], 1'b0};
		end
		else if (ALU_op[`SRL]) begin
			RZ[31:0] = {1'b0, RA[31:1]};
		end
		else if (ALU_op[`SRA]) begin
			RZ[31:0] = {RA[31], RA[31:1]};
		end
		else if (ALU_op[`ROR]) begin
			RZ[31:0] = {RA[0], RA[31:1]};
		end
		else if (ALU_op[`ROL]) begin
			RZ[31:0] = {RA[30:0], RA[31]};
		end
	end
	
endmodule