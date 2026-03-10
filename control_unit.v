//CONTROL UNIT MODULE
`timescale 1ns/10ps

//OP code degine statements
`define ADD 00000
`define SUB 00001
`define AND 00010
`define OR 00011
`define SHR 00100
`define SHRA 00101
`define SHL 00110
`define ROR 00111
`define ROL 01000
`define ADDI 01001
`define ANDI 01010
`define ORI 01011
`define DIV 01100
`define MUL 01101
`define NEG 01110
`define NOT 01111
`define LD 10000
`define LDI 10001
`define ST 10010
`define JR 10011
`define JAL 10100
`define BRANCH 10101
`define IN 10110
`define OUT 10111
`define MFHI 11000
`define MFLO 11001
`define NOP 11010
`define HALT 11011

//ALU code define statements
`define AND_OP 1b'0000000000001
`define OR_OP 1b'0000000000010
`define NOT_OP 1b'0000000000100
`define NEG_OP 1b'0000000001000
`define ADD_OP 1b'0000000010000
`define SUB_OP 1b'0000000100000
`define MUL_OP 1b'0000001000000
`define DIV_OP 1b'0000010000000
`define SLL_OP 1b'0000100000000
`define SRL_OP 1b'0001000000000
`define SRA_OP 1b'0010000000000
`define ROR_OP 1b'0100000000000
`define ROL_OP 1b'1000000000000
 
 
module control_unit (
	output reg         Clock, Clear;
    output reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    output reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    output reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    output reg         CON_In, CON_Out, OUTPORT_Out, alu_op;
	
	input [31:0] IR,
	input Clock, Reset, Stop
);
	
	parameter 	reset_state = 6’b00000, 
				fetch0 = 6’b00001, 
				fetch1 = 6’b00010, 
				fetch2 = 6’b00011,
				alu3 = 6’b00100, 
				alu4 = 6’b00101, 
				alu5 = 6’b00111,
				muldiv3 = 6’b01001, 
				muldiv4 = 6’b01010, 
				muldiv5 = 6’b01011,
				muldiv6 = 6’b01100, 
				negnot3 = 6’b01101, 
				negnot4 = 6’b01110,
				readwrite3 = 6’b01111, 
				readwrite4 = 6’b10000,
				st5 = 6’b10001, 
				st6 = 6’b10010,
				st7 = 6’b10011, 
				st8 = 6’b10100,
				load5 = 6’b10101, 
				load6 = 6’b10111,
				load7 = 6’b11000, 
				load8 = 6’b11001,
				alui3 = 6’b11010, 
				alui4 = 6’b11011, 
				alui5 = 6’b11100,
				branch3 = 6’b11101, 
				branch4 = 6’b11111,
				jal3 = 6’b100000, 
				jal4 = 6’b100001,
				nop = 6’b100010, 
				halt = 6’b100011;
 
	reg [3:0] present_state = reset_state; 
	
	always @(posedge Clock, posedge Reset) // finite state machine; if clock or reset rising-edge
	begin
		if (Reset == 1’b1) 
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
								`NEG, `NOT: present_state = negnot4; 
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
				muldiv6;
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
					`ST: present_state = st5; 
					`LD: present_state = load5;
					`LDI: present_state = loadi5;
				
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
					present_state = ja4;
				jal4:
					present_state = reset_state;
					
				//NOP
				nop:
					present_state = reset_state;
				
					
				//BRANCHING
				branch3:
					present_state= branch4;
				branch4:
					present_state = reset_state;
					
				
				
			endcase
	end
	
	always @(present_state) // do the job for each state
	begin
		case (present_state) // assert the required signals in each state
			reset_state: begin
				PCin <=0; IRin <=0; HIin <=0; LOin <=0; ZHIin <=0; Zin <=0; MARin <=0; MDRin <=0; OUTPORT_In <=0; Yin <=0;
				PCout <=0; HIout <=0; LOout <=0; ZHIout <=0; INPORT_Out <=0; MDRout <=0; Cout <=0;
				Gra <=0; Grb <=0; Grc <=0; Rin <=0; Rout <=0; BAout <=0; Read <=0; Write <=0; IncPC <=0;
				CON_In <=0; CON_Out <=0; OUTPORT_Out <=0;
			end
		
			//INSTRUCTION FETCH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
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
				if (IR[31:17] == `ADD){
					alu_op = `ADD_OP; 
				} else if (IR[31:17] == `OR){
					alu_op = `OR_OP; 
				} else if (IR[31:17] == `AND){
					alu_op = `AND_OP; 
				} else if (IR[31:17] == `SUB){
					alu_op = `SUB_OP; 
				} else if (IR[31:17] == `SHR){
					alu_op = `SHR_OP; 
				} else if (IR[31:17] == `SHRA){
					alu_op = `SHRA_OP; 
				} else if (IR[31:17] == `ROR){
					alu_op = `ROR_OP; 
				} else if (IR[31:17] == `ROL){
					alu_op = `ROL_OP; 
				}
					
			end
			alu5: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			//MUL, DIV
			muldiv1: begin
				Gra <= 1;
				Rout <= 1;
				Yin <= 1;
			end
			muldiv2: begin
				Grb <= 1;
				Rout <= 1;
				Zin <= 1;
				ZHi <= 1;
				alu_op = ADD_OP;
			end
			muldiv3: begin
				Zout <= 1;
				Loin <= 1;
			end
			muldiv4: begin
				ZHIout <= 1;
				HIin <= 1;
				
			end
			
			//NEG, NOT
			negnot1: begin
				Grb <= 1;
				Rout <= 1;
				if (IR[31:17] == `NOT){
					alu_op = 
				} else if (IR[31:17] == `NEG){
					alu_op = 
				}
				Zin <= 1;
			end
			negnot2: begin
				Zout <= 1;
				Gra <= 1;
				Rin <= 1;
			end
			
			//ST,LDI,LD (beginning)
			readwrite1: begin
				Grb <= 1;
				BAout <= 1;
				Yin <= 1;
			end
			readwrite2: begin
				Cout <= 1;
				alu_op = ADD_OP;
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
				MRin <= 1;
			end
			load8: begin
				MDRout <= 1;
				GRa <= 1;
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
				GRA <= 1;
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
				if (IR[31:17] == `ADDI){
					alu_op = 
				} else if (IR[31:17] == `ORI){
					
				} else if (IR[31:17] == `ANDI){
				
				}
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
				Pcout <= 1;
			end
			jal4: begin
				Gra <= 1;
				Rout <= 1;
				PCin <= 1;
			
			//MOVING
			mflo3: begin
				Gra <= 1;
				Rin <= 1;
				LOout <= 1;
			end
			
			mfhi3: begin
				Gra <= 1;
				Rin <= 1;
				Hiout <= 1;
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
				Gra <= 1;
			end
			branch4: begin	
				Pcout <= 1;
				Yin <= 1;
			end
			branch5: begin
				Cout <= 1;
				alu_op = ADD_OP;
				Zin <= 1;
				ZHIin <= 1;
			end
				
	
		endcase
	end
	endmodule