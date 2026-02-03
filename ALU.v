//Define ALU components control variables
//for the different inputs
`define AND 0
`define OR 1
`define NOT 2
`define NEG 3
`define ADD 4
`define SUB 5
`define MUL 6
`define DIV 7
`define SLL 8
`define SRL 9
`define SRA 10
`define ROR 11
`define ROL 12

//create the ALU module
module ALU (
	//define the input and outputs wires and reg
	input wire [31:0] RA, RB,
	input wire [12:0] ALU_op,
	output reg [63:0] RZ
);
	//define wires correponding to different results
	wire [31:0] and_result;
	wire [31:0] or_result;
	wire [31:0] not_result;
	wire [31:0] neg_result;
	wire c_out;
	wire c_in;
	wire [31:0] add_sub_result;
	wire [63:0] mul_result;
	wire [63:0] div_result;
	wire [31:0] RB_sub;

	//check if sub is active, if so, make RB negative
	assign RB_sub = ALU_op[`SUB] ? ~RB : RB;
	assign c_in = ALU_op[`SUB];

	//create instances of each operation
	//accessing the different module files
	and_gate and_instance (RA, RB, and_result);
	or_gate or_instance (RA, RB, or_result);
	negate neg (RA, neg_result);
	CLA_32 add_sub (RA, RB_sub, c_in, add_sub_result, c_out);
	not_gate not_instance (RA, not_result);
	div div (RA, RB, div_result[63:32], div_result[31:0]);
	mult_32b mul (RA, RB, mul_result);
	
	//always statement to check which input component
	//was selected, then sets RZ to the result
	//of the corresponding operation
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
		else if (ALU_op[`ADD] || ALU_op[`SUB]) begin
			RZ[31:0] = add_sub_result;
			RZ[63:32] = 32'b0;
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
