//Control unit — decodes instructions and drives all datapath control signals
`timescale 1ns/10ps

//Instruction op-codes
`define ADD    5'b00000
`define SUB    5'b00001
`define AND    5'b00010
`define OR     5'b00011
`define SHR    5'b00100
`define SHRA   5'b00101
`define SHL    5'b00110
`define ROR    5'b00111
`define ROL    5'b01000
`define ADDI   5'b01001
`define ANDI   5'b01010
`define ORI    5'b01011
`define DIV    5'b01100
`define MUL    5'b01101
`define NEG    5'b01110
`define NOT    5'b01111
`define LD     5'b10000
`define LDI    5'b10001
`define ST     5'b10010
`define JR     5'b10011
`define JAL    5'b10100
`define BRANCH 5'b10101
`define IN     5'b10110
`define OUT    5'b10111
`define MFHI   5'b11000
`define MFLO   5'b11001
`define NOP    5'b11010
`define HALT   5'b11011

//ALU operation select codes (one-hot encoded)
`define AND_OP  13'b0000000000001
`define OR_OP   13'b0000000000010
`define NOT_OP  13'b0000000000100
`define NEG_OP  13'b0000000001000
`define ADD_OP  13'b0000000010000
`define SUB_OP  13'b0000000100000
`define MUL_OP  13'b0000001000000
`define DIV_OP  13'b0000010000000
`define SHL_OP  13'b0000100000000
`define SHR_OP  13'b0001000000000
`define SHRA_OP 13'b0010000000000
`define ROR_OP  13'b0100000000000
`define ROL_OP  13'b1000000000000

module control_unit (
	output reg PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin,
	output reg PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout,
	output reg Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC,
	output reg CON_In, CON_Out, OUTPORT_Out,
	output reg [12:0] alu_op,
	output wire halted,

	input [31:0] IR,
	input Clock, Reset, Stop
);

//State encodings
parameter
	reset_state = 6'd0,
	fetch0      = 6'd1,
	fetch1      = 6'd2,
	fetch2      = 6'd3,
	decode      = 6'd38,

	alu3        = 6'd4,
	alu4        = 6'd5,
	alu5        = 6'd6,

	muldiv3     = 6'd7,
	muldiv4     = 6'd8,
	muldiv5     = 6'd9,
	muldiv6     = 6'd10,

	negnot3     = 6'd11,
	negnot4     = 6'd12,

	readwrite3  = 6'd13,
	readwrite4  = 6'd14,

	st5         = 6'd15,
	st6         = 6'd16,
	st7         = 6'd17,
	st8         = 6'd18,

	load5       = 6'd19,
	load6       = 6'd20,
	load7       = 6'd21,
	load8       = 6'd22,

	loadi5      = 6'd23,

	alui3       = 6'd24,
	alui4       = 6'd25,
	alui5       = 6'd26,

	jr3         = 6'd27,
	jal3        = 6'd28,
	jal4        = 6'd29,

	mfhi3       = 6'd30,
	mflo3       = 6'd31,

	branch3     = 6'd32,
	branch4     = 6'd33,
	branch5     = 6'd34,
	branch6     = 6'd35,

	nop         = 6'd36,
	halt        = 6'd37,

	input3      = 6'd39,
	output3     = 6'd40;

reg [5:0] present_state;

//Assert halted when the CPU reaches the halt state
assign halted = (present_state == halt);

//State transitions — advance on each rising clock edge
always @(posedge Clock or posedge Reset) begin
	if (Reset)
		present_state <= reset_state;
	else begin
		case (present_state)
			reset_state: present_state <= fetch0;
			fetch0:      present_state <= fetch1;
			fetch1:      present_state <= fetch2;
			fetch2:      present_state <= decode;

			//Decode the op-code and branch to the appropriate instruction sequence
			decode: begin
				case (IR[31:27])
					`ADD, `SUB, `AND, `OR, `SHR, `SHRA, `SHL, `ROR, `ROL:
						present_state <= alu3;
					`MUL, `DIV:
						present_state <= muldiv3;
					`NEG, `NOT:
						present_state <= negnot3;
					`ST, `LD, `LDI:
						present_state <= readwrite3;
					`ADDI, `ANDI, `ORI:
						present_state <= alui3;
					`JR:
						present_state <= jr3;
					`JAL:
						present_state <= jal3;
					`MFHI:
						present_state <= mfhi3;
					`MFLO:
						present_state <= mflo3;
					`BRANCH:
						present_state <= branch3;
					`HALT:
						present_state <= halt;
					`NOP:
						present_state <= nop;
					`IN:
						present_state <= input3;
					`OUT:
						present_state <= output3;
					default:
						present_state <= fetch0;
				endcase
			end

			//ALU (ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL)
			alu3: present_state <= alu4;
			alu4: present_state <= alu5;
			alu5: present_state <= reset_state;

			//MUL/DIV
			muldiv3: present_state <= muldiv4;
			muldiv4: present_state <= muldiv5;
			muldiv5: present_state <= muldiv6;
			muldiv6: present_state <= reset_state;

			//NEG/NOT
			negnot3: present_state <= negnot4;
			negnot4: present_state <= reset_state;

			//LD/LDI/ST — shared address computation, then split by op
			readwrite3: present_state <= readwrite4;
			readwrite4: begin
				if (IR[31:27] == `ST)
					present_state <= st5;
				else if (IR[31:27] == `LD)
					present_state <= load5;
				else
					present_state <= loadi5;
			end

			load5: present_state <= load6;
			load6: present_state <= load7;
			load7: present_state <= load8;
			load8: present_state <= reset_state;

			loadi5: present_state <= reset_state;

			st5: present_state <= st6;
			st6: present_state <= st7;
			st7: present_state <= st8;
			st8: present_state <= reset_state;

			//ALU immediate (ADDI, ANDI, ORI)
			alui3: present_state <= alui4;
			alui4: present_state <= alui5;
			alui5: present_state <= reset_state;

			//Jump
			jr3:  present_state <= reset_state;
			jal3: present_state <= jal4;
			jal4: present_state <= reset_state;

			//Move from HI/LO
			mfhi3: present_state <= reset_state;
			mflo3: present_state <= reset_state;

			//Branch
			branch3: present_state <= branch4;
			branch4: present_state <= branch5;
			branch5: present_state <= branch6;
			branch6: present_state <= reset_state;

			//IN/OUT
			input3:  present_state <= reset_state;
			output3: present_state <= reset_state;

			nop:  present_state <= reset_state;
			halt: present_state <= halt;

			default: present_state <= reset_state;
		endcase
	end
end

//Control signal logic — combinationally asserted based on the current state
always @(*) begin
	//Default all signals off
	PCin = 0; IRin = 0; HIin = 0; LOin = 0; ZHIin = 0; Zin = 0; MARin = 0; MDRin = 0; OUTPORT_In = 0; Yin = 0;
	PCout = 0; HIout = 0; LOout = 0; ZHIout = 0; Zout = 0; INPORT_Out = 0; MDRout = 0; Cout = 0;
	Gra = 0; Grb = 0; Grc = 0; Rin = 0; Rout = 0; BAout = 0; Read = 0; Write = 0; IncPC = 0;
	CON_In = 0; CON_Out = 0; OUTPORT_Out = 0;
	alu_op = 13'b0;

	case (present_state)

		reset_state: begin
		end

		//Fetch — put PC on bus, load MAR, increment PC, begin memory read
		fetch0: begin
			PCout = 1;
			MARin = 1;
			IncPC = 1;
			Read = 1;
		end

		//Fetch — continue memory read, latch data into MDR
		fetch1: begin
			Read = 1;
			MDRin = 1;
		end

		//Fetch — move MDR contents into IR
		fetch2: begin
			MDRout = 1;
			IRin = 1;
		end

		decode: begin
		end

		//ALU (ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL)
		//Load Rb into Y
		alu3: begin
			Grb = 1;
			Rout = 1;
			Yin = 1;
		end

		//Perform the ALU operation with Rc, latch result into Z
		alu4: begin
			Grc = 1;
			Rout = 1;
			Zin = 1;

			if (IR[31:27] == `ADD)       alu_op = `ADD_OP;
			else if (IR[31:27] == `OR)   alu_op = `OR_OP;
			else if (IR[31:27] == `AND)  alu_op = `AND_OP;
			else if (IR[31:27] == `SUB)  alu_op = `SUB_OP;
			else if (IR[31:27] == `SHR)  alu_op = `SHR_OP;
			else if (IR[31:27] == `SHRA) alu_op = `SHRA_OP;
			else if (IR[31:27] == `SHL)  alu_op = `SHL_OP;
			else if (IR[31:27] == `ROR)  alu_op = `ROR_OP;
			else if (IR[31:27] == `ROL)  alu_op = `ROL_OP;
		end

		//Write result from Z into Ra
		alu5: begin
			Zout = 1;
			Gra = 1;
			Rin = 1;
		end

		//MUL/DIV — load Ra into Y
		muldiv3: begin
			Gra = 1;
			Rout = 1;
			Yin = 1;
		end

		//Perform MUL or DIV with Rb, latch result into Z and ZHI
		muldiv4: begin
			Grb = 1;
			Rout = 1;
			Zin = 1;
			ZHIin = 1;

			if (IR[31:27] == `MUL)      alu_op = `MUL_OP;
			else if (IR[31:27] == `DIV) alu_op = `DIV_OP;
		end

		//Move low word of result into LO
		muldiv5: begin
			Zout = 1;
			LOin = 1;
		end

		//Move high word of result into HI
		muldiv6: begin
			ZHIout = 1;
			HIin = 1;
		end

		//NEG/NOT — perform operation on Rb, latch into Z
		negnot3: begin
			Grb = 1;
			Rout = 1;
			Zin = 1;

			if (IR[31:27] == `NOT)      alu_op = `NOT_OP;
			else if (IR[31:27] == `NEG) alu_op = `NEG_OP;
		end

		//Write result from Z into Ra
		negnot4: begin
			Zout = 1;
			Gra = 1;
			Rin = 1;
		end

		//LD/LDI/ST — compute base address: put Rb on bus, load into Y
		readwrite3: begin
			Grb = 1;
			BAout = 1;
			Yin = 1;
		end

		//Add sign-extended constant to base address, latch into Z
		readwrite4: begin
			Cout = 1;
			alu_op = `ADD_OP;
			Zin = 1;
		end

		//LD — load computed address into MAR
		load5: begin
			Zout = 1;
			MARin = 1;
		end

		//LD — begin memory read
		load6: begin
			Read = 1;
		end

		//LD — continue memory read, latch data into MDR
		load7: begin
			Read = 1;
			MDRin = 1;
		end

		//LD — write MDR contents into Ra
		load8: begin
			MDRout = 1;
			Gra = 1;
			Rin = 1;
		end

		//LDI — write computed value directly into Ra
		loadi5: begin
			Zout = 1;
			Gra = 1;
			Rin = 1;
		end

		//ST — load computed address into MAR
		st5: begin
			Zout = 1;
			MARin = 1;
		end

		//ST — put Ra onto bus, latch into MDR
		st6: begin
			Gra = 1;
			Rout = 1;
			MDRin = 1;
		end

		//ST — write MDR contents to memory
		st7: begin
			Write = 1;
		end

		st8: begin
		end

		//ALU immediate (ADDI, ANDI, ORI) — load Rb into Y
		alui3: begin
			Grb = 1;
			Rout = 1;
			Yin = 1;
		end

		//Perform operation with sign-extended constant, latch into Z
		alui4: begin
			Cout = 1;
			Zin = 1;

			if (IR[31:27] == `ADDI)      alu_op = `ADD_OP;
			else if (IR[31:27] == `ORI)  alu_op = `OR_OP;
			else if (IR[31:27] == `ANDI) alu_op = `AND_OP;
		end

		//Write result from Z into Ra
		alui5: begin
			Zout = 1;
			Gra = 1;
			Rin = 1;
		end

		//JR — load Ra directly into PC
		jr3: begin
			Gra = 1;
			Rout = 1;
			PCin = 1;
		end

		//JAL — save current PC into Rb
		jal3: begin
			Grb = 1;
			Rin = 1;
			PCout = 1;
		end

		//JAL — jump to Ra
		jal4: begin
			Gra = 1;
			Rout = 1;
			PCin = 1;
		end

		//MFLO — move LO into Ra
		mflo3: begin
			Gra = 1;
			Rin = 1;
			LOout = 1;
		end

		//MFHI — move HI into Ra
		mfhi3: begin
			Gra = 1;
			Rin = 1;
			HIout = 1;
		end

		//BRANCH — evaluate condition using Ra, latch into CON
		branch3: begin
			Gra = 1;
			Rout = 1;
			CON_In = 1;
		end

		//Load current PC into Y
		branch4: begin
			PCout = 1;
			Yin = 1;
		end

		//Add sign-extended offset to PC, latch into Z
		branch5: begin
			Cout = 1;
			alu_op = `ADD_OP;
			Zin = 1;
		end

		//Write branch target into PC if condition was met
		branch6: begin
			Zout = 1;
			PCin = 1;
			CON_Out = 1;
		end

		//IN — read from input port into Ra
		input3: begin
			Gra = 1;
			Rin = 1;
			INPORT_Out = 1;
		end

		//OUT — write Ra to output port
		output3: begin
			Gra = 1;
			Rout = 1;
			OUTPORT_In = 1;
		end

		nop: begin
		end

		halt: begin
		end

		default: begin
		end
	endcase
end

endmodule
