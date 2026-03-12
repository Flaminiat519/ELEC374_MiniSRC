//CONTROL UNIT MODULE
`timescale 1ns/10ps

//OP code degine statements
`define ADD 5'b00000
`define SUB 5'b00001
`define AND 5'b00010
`define OR 5'b00011
`define SHR 5'b00100
`define SHRA 5'b00101
`define SHL 5'b00110
`define ROR 5'b00111
`define ROL 5'b01000
`define ADDI 5'b01001
`define ANDI 5'b01010
`define ORI 5'b01011
`define DIV 5'b01100
`define MUL 5'b01101
`define NEG 5'b01110
`define NOT 5'b01111
`define LD 5'b10000
`define LDI 5'b10001
`define ST 5'b10010
`define JR 5'b10011
`define JAL 5'b10100
`define BRANCH 5'b10101
`define IN 5'b10110
`define OUT 5'b10111
`define MFHI 5'b11000
`define MFLO 5'b11001
`define NOP 5'b11010
`define HALT 5'b11011

//ALU code define statements
`define AND_OP 13'b0000000000001
`define OR_OP 13'b0000000000010
`define NOT_OP 13'b0000000000100
`define NEG_OP 13'b0000000001000
`define ADD_OP 13'b0000000010000
`define SUB_OP 13'b0000000100000
`define MUL_OP 13'b0000001000000
`define DIV_OP 13'b0000010000000
`define SHL_OP 13'b0000100000000
`define SHR_OP 13'b0001000000000
`define SHRA_OP 13'b0010000000000
`define ROR_OP 13'b0100000000000
`define ROL_OP 13'b1000000000000
 
 
module control_unit (
	//output reg         Clock, Clear;
    output reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin,
    output reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout,
    output reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC,
    output reg         CON_In, CON_Out, OUTPORT_Out,
	output reg[12:0] alu_op,
	
	input [31:0] IR,
	input Clock, Reset, Stop
);
	
	parameter 	reset_state = 6'b00000, 
				fetch0 = 6'b00001, 
				fetch1 = 6'b00010, 
				fetch2 = 6'b00011,
				alu3 = 6'b00100, 
				alu4 = 6'b00101, 
				alu5 = 6'b00111,
				muldiv3 = 6'b01001, 
				muldiv4 = 6'b01010, 
				muldiv5 = 6'b01011,
				muldiv6 = 6'b01100, 
				negnot3 = 6'b01101, 
				negnot4 = 6'b01110,
				readwrite3 = 6'b01111, 
				readwrite4 = 6'b10000,
				st5 = 6'b10001, 
				st6 = 6'b10010,
				st7 = 6'b10011, 
				st8 = 6'b10100,
				load5 = 6'b10101, 
				load6 = 6'b10111,
				load7 = 6'b11000, 
				load8 = 6'b11001,
				alui3 = 6'b11010, 
				alui4 = 6'b11011, 
				alui5 = 6'b11100,
				branch3 = 6'b11101, 
				branch4 = 6'b11111,
				jal3 = 6'b100000, 
				jal4 = 6'b100001,
				nop = 6'b100010, 
				halt = 6'b100011,
				jr3 = 6'b100100,
				mfhi3 = 6'b100101,
				mflo3 = 6'b100111,
				loadi5 = 6'b101000,
				branch5 = 6'b101001,
				branch6 = 6'b101011;
 
	reg [5:0] present_state = reset_state; 
	
	always @(posedge Clock, posedge Reset) // finite state machine; if clock or reset rising-edge
	begin
		if (Reset == 1'b1)
			present_state = reset_state;
		else 
			case (present_state)
				//INSTRUCTION FETCH
				reset_state: 
					present_state = fetch0;
				fetch0: 
					present_state = fetch1;
				fetch1: 
					present_state = fetch2;
				fetch2: begin
							case (IR[31:27]) // inst. decoding based on the opcode to set the next state
								`ADD, `SUB, `AND, `OR, `SHR, `SHRA, `SHL, `ROR, `ROL: present_state = alu3; 
								`MUL, `DIV: present_state = muldiv3; 
								`NEG, `NOT: present_state = negnot3; 
								`ST, `LD, `LDI: present_state = readwrite3; 
								`ADDI,`ANDI, `ORI: present_state = alui3; 
								`JR: present_state = jr3; 
								`JAL: present_state = jal3; 
								`MFLO: present_state = mflo3; 
								`MFHI: present_state = mfhi3; 
								`HALT: present_state = halt;
								`NOP: present_state = nop;
								`BRANCH: present_state = branch3;
							endcase
						end
				//ALU OPERATIONS
				alu3: 
					present_state = alu4;
				alu4: 
					present_state = alu5;
				alu5:
					present_state = reset_state;
					
				//MUL AND DIV
				muldiv3: 
					present_state = muldiv4;
				muldiv4: 
					present_state = muldiv5;
				muldiv5: 
					present_state = muldiv6;
				muldiv6:
					present_state = reset_state;
			
				//NEG AND NOT
				negnot3: 
					present_state = negnot4;
				negnot4:
					present_state = reset_state;
					
				//READ AND WRITE
				readwrite3: 
					present_state = readwrite4;
				readwrite4:
					if (IR[31:27] == `ST)
						present_state = st5;
					 else if (IR[31:27] == `LD) 
						present_state = load5;
					 else if (IR[31:27] == `LDI) 
						present_state = loadi5;
					
				
				//STORE
				st5:
					present_state = st6;
				st6:
					present_state = st7;
				st7:
					present_state = st8;
				st8:
					present_state = reset_state;
					
				//LD
				load5:
					present_state = load6;
				load6:
					present_state = load7;
				load7:
					present_state = load8;
				load8:
					present_state = reset_state;
					
				//LDI
				loadi5:
					present_state = reset_state;

				//MFHI
				mfhi3:
					present_state = reset_state;
					
				//MFLO
				mflo3:
					present_state = reset_state;
					
				//ALU IMMEDIATE
				alui3:
					present_state = alui4;
				alui4:
					present_state = alui5;
				alui5:
					present_state = reset_state;
					
				//JR
				jr3:
					present_state = reset_state;
				//JAL 
				jal3:
					present_state = jal4;
				jal4:
					present_state = reset_state;
					
				//NOP
				nop:
					present_state = reset_state;
				
					
				//BRANCHING
				branch3:
					present_state= branch4;
				branch4:
					present_state= branch5;
				branch5:
					present_state= branch6;
				branch6:
					present_state = reset_state;
					
				
				
			endcase
	end
	
	always @(present_state) // do the job for each state
	begin
		// Default everything off
		PCin=0; IRin=0; HIin=0; LOin=0; ZHIin=0; Zin=0; MARin=0; MDRin=0; OUTPORT_In=0; Yin=0;
		PCout=0; HIout=0; LOout=0; ZHIout=0; Zout=0; INPORT_Out=0; MDRout=0; Cout=0;
		Gra=0; Grb=0; Grc=0; Rin=0; Rout=0; BAout=0; Read=0; Write=0; IncPC=0;
		CON_In=0; CON_Out=0; OUTPORT_Out=0;
		alu_op=13'b0;
		case (present_state) // assert the required signals in each state
			reset_state: begin
				PCin <=0; IRin <=0; HIin <=0; LOin <=0; ZHIin <=0; Zin <=0; MARin <=0; MDRin <=0; OUTPORT_In <=0; Yin <=0;
				PCout <=0; HIout <=0; LOout <=0; Zout <=0; ZHIout <=0; INPORT_Out <=0; MDRout <=0; Cout <=0;
				Gra <=0; Grb <=0; Grc <=0; Rin <=0; Rout <=0; BAout <=0; Read <=0; Write <=0; IncPC <=0;
				CON_In <=0; CON_Out <=0; OUTPORT_Out <=0;
			end
		
			//INSTRUCTION FETCH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			fetch0: begin
				PCout <= 1; // see if you need to de-assert these signals
				MARin <= 1;
				IncPC <= 1;
				Read <= 1;
			end
			fetch1: begin
				Read <= 1; 
				MDRin <= 1;
			end
			fetch2: begin
				MDRout <= 1;
				IRin <= 1;
			end
		
			//ADD, AND, OR, SUB, SHR, SHL, SHRA, ROL, ROR
			alu3: begin
				Grb <= 1;
				Rout <= 1;
				Yin <= 1;
			end	
			alu4: begin
				Grc <= 1;
				Rout <= 1;
				Zin <= 1;
				if (IR[31:27] == `ADD)
					alu_op = `ADD_OP; 
				 else if (IR[31:27] == `OR)
					alu_op = `OR_OP; 
				 else if (IR[31:27] == `AND)
					alu_op = `AND_OP; 
				 else if (IR[31:27] == `SUB)
					alu_op = `SUB_OP; 
				 else if (IR[31:27] == `SHR)
					alu_op = `SHR_OP; 
				 else if (IR[31:27] == `SHRA)
					alu_op = `SHRA_OP; 
				else if (IR[31:27] == `SHL)
					alu_op = `SHL_OP; 
				 else if (IR[31:27] == `ROR)
					alu_op = `ROR_OP; 
				 else if (IR[31:27] == `ROL)
					alu_op = `ROL_OP; 
				
					
			end
			alu5: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			//MUL, DIV
			muldiv3: begin
				Gra <= 1;
				Rout <= 1;
				Yin <= 1;
			end
			muldiv4: begin
				Grb <= 1;
				Rout <= 1;
				Zin <= 1;
				ZHIin <= 1;
				if (IR[31:27] == `MUL)
					alu_op = `MUL_OP;
				 else if (IR[31:27] == `DIV)
					alu_op = `DIV_OP;
				
			end
			muldiv5: begin
				Zout <= 1;
				LOin <= 1;
			end
			muldiv6: begin
				ZHIout <= 1;
				HIin <= 1;
				
			end
			
			//NEG, NOT
			negnot3: begin
				Grb <= 1;
				Rout <= 1;
				if (IR[31:27] == `NOT)
					alu_op = `NOT_OP;
				 else if (IR[31:27] == `NEG)
					alu_op = `NEG_OP;
				
				Zin <= 1;
			end
			negnot4: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			//ST,LDI,LD (beginning)
			readwrite3: begin
				Grb <= 1;
				BAout <= 1;
				Yin <= 1;
			end
			readwrite4: begin
				Cout <= 1;
				alu_op = `ADD_OP;
				Zin <= 1;
			end
			
			load5: begin
				Zout <= 1;
				MARin <= 1;
			end
			load6: begin
				Read <= 1;
			end
			load7: begin
				Read <= 1;
				MDRin <= 1;
			end
			load8: begin
				MDRout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			loadi5: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			st5: begin
				Zout <= 1;
				MARin <= 1;
			end
			st6: begin
				Gra <= 1;
				Rout <= 1;
				MDRin <= 1;
			end
			st7: begin
				Write <= 1;
			end
			st8: begin
				Read <= 1;
			end
			
			//ALU IMMEDIATE INSTRUCTIONS
			alui3: begin
				Grb <= 1;
				Rout <= 1;
				Yin <= 1;
			end
			alui4: begin
				Cout <= 1;
				if (IR[31:27] == `ADDI)
					alu_op = `ADD_OP;
				 else if (IR[31:27] == `ORI)
					alu_op = `OR_OP;
				 else if (IR[31:27] == `ANDI)
					alu_op = `AND_OP;
				
				Zin <= 1; 
			end
			alui5: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			//JUMP
			jr3: begin
				Gra <= 1;
				Rout <= 1;
				PCin <= 1;
			end
			jal3: begin
				Grb <= 1;
				Rin <= 1;
				PCout <= 1;
			end
			jal4: begin
				Gra <= 1;
				Rout <= 1;
				PCin <= 1;
			end
			//MOVING
			mflo3: begin
				Gra <= 1;
				Rin <= 1;
				LOout <= 1;
			end
			
			mfhi3: begin
				Gra <= 1;
				Rin <= 1;
				HIout <= 1;
			end
			
			halt: begin
			end
			
			nop: begin
			end
			
			//BRANCHING
			branch3: begin 
				Gra <= 1;
				Rout <= 1;
				CON_In <= 1;
			end
			branch4: begin	
				PCout <= 1;
				Yin <= 1;
			end
			branch5: begin
				Cout <= 1;
				alu_op = `ADD_OP;
				Zin <= 1;
				ZHIin <= 1;
			end
			branch6: begin
				Zout <= 1;
				PCin <= 1;
				CON_Out <= 1;
			end	
	
		endcase
	end
	endmodule