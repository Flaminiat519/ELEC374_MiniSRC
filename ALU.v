//ALU module — handles arithmetic, logical, and shift operations
//Operation select codes for ALU_op (one-hot encoded)
`define AND_ALU 0
`define OR_ALU 1
`define NOT_ALU 2
`define NEG_ALU 3
`define ADD_ALU 4
`define SUB_ALU 5
`define MUL_ALU 6
`define DIV_ALU 7
`define SLL_ALU 8
`define SRL_ALU 9
`define SRA_ALU 10
`define ROR_ALU 11
`define ROL_ALU 12

module ALU (
	input wire [31:0] RA, RB,   //Source operands
	input wire [12:0] ALU_op,   //One-hot operation select
	output reg [63:0] RZ        //64-bit result (upper half used for MUL/DIV)
);

	//Result wires for each operation
	wire [31:0] and_result;
	wire [31:0] or_result;
	wire [31:0] not_result;
	wire [31:0] neg_result;
	wire c_out;
	wire c_in;
	wire [31:0] add_sub_result;
	wire [63:0] mul_result;
	wire [31:0] sll_result;
	wire [31:0] srl_result;
	wire [31:0] sra_result;
	wire [31:0] ror_result;
	wire [31:0] rol_result;
	wire [31:0] RB_sub;

	//For subtraction, invert RB and set carry-in to 1 (two's complement negation)
	assign RB_sub = ALU_op[`SUB_ALU] ? ~RB : RB;
	assign c_in = ALU_op[`SUB_ALU];

	//Operation module instances
	and_gate and_instance (RA, RB, and_result);
	or_gate or_instance (RA, RB, or_result);
	not_gate not_instance (RB, not_result);
	negate neg (RB, neg_result);
	CLA_32 add_sub (RA, RB_sub, c_in, add_sub_result, c_out);

	wire [31:0] div_quotient;
	wire [31:0] div_remainder;

	div div_instance (
		.dividend(RA),
		.divisor(RB),
		.quotient(div_quotient),
		.remainder(div_remainder)
	);

	mult_32b mul (RA, RB, mul_result);
	rol rol_instance (RA, RB, rol_result);
	ror ror_instance (RA, RB, ror_result);
	sll sll_instance (RA, RB, sll_result);
	sra sra_instance (RA, RB, sra_result);
	srl srl_instance (RA, RB, srl_result);

	//Select the result based on the active operation bit
	always @(*) begin
		RZ = 64'b0;
		if (ALU_op[`AND_ALU]) begin
			RZ[31:0] = and_result;
		end
		else if (ALU_op[`OR_ALU]) begin
			RZ[31:0] = or_result;
		end
		else if (ALU_op[`NOT_ALU]) begin
			RZ[31:0] = not_result;
		end
		else if (ALU_op[`NEG_ALU]) begin
			RZ[31:0] = neg_result;
		end
		else if (ALU_op[`ADD_ALU] || ALU_op[`SUB_ALU]) begin
			RZ[31:0] = add_sub_result;
			RZ[63:32] = 32'b0;
		end
		else if (ALU_op[`MUL_ALU]) begin
			RZ = mul_result;
		end
		else if (ALU_op[`DIV_ALU]) begin
			RZ[31:0] = div_quotient;   // Lower word → ZLO
			RZ[63:32] = div_remainder; // Upper word → ZHI
		end
		else if (ALU_op[`SLL_ALU]) begin
			RZ[31:0] = sll_result;
			RZ[63:32] = 32'b0;
		end
		else if (ALU_op[`SRL_ALU]) begin
			RZ[31:0] = srl_result;
			RZ[63:32] = 32'b0;
		end
		else if (ALU_op[`SRA_ALU]) begin
			RZ[31:0] = sra_result;
			RZ[63:32] = 32'b0;
		end
		else if (ALU_op[`ROR_ALU]) begin
			RZ[31:0] = ror_result;
			RZ[63:32] = 32'b0;
		end
		else if (ALU_op[`ROL_ALU]) begin
			RZ[31:0] = rol_result;
			RZ[63:32] = 32'b0;
		end
	end

endmodule
