//CONTROL UNIT MODULE
`timescale 1ns/10ps
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
	
	parameter 	reset_state = 4’b0000, 
				fetch0 = 4’b0001, 
				fetch1 = 4’b0010, 
				fetch2 = 4’b0011,
				add3 = 4’b0100, 
				add4 = 4’b0101, 
				add5 = 4’b0110;
 
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
								`MUL, `DIV: present_state = muldiv1; 
								`NEG, `NOT: present_state = negnot1; 
								`ST, `LD, `LDI: present_state = readwrite1; 
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
				muldiv1: 
					present_state = muldiv2;
				muldiv2: 
					present_state = muldiv3;
				muldiv3: 
					present_state = muldiv4;
				muldiv4;
					present_state = reset_state;
			
				
					
				//NEG AND NOT
				negnot1: 
					present_state = negnot2;
				negnot2:
					present_state = reset_state;
				
					
				//READ AND WRITE
				readwrite1: 
					present_state = readwrite2;
				readwrite2:
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
				Grb
				Rout
				Yin
			end	
			alu4: begin
				Grc
				Rout
				Zin
				if (IR[31:17] == `ADD){
					alu_op = `ADD_OP; 
				} else if (IR[31:17] == `OR){
					
				} else if (IR[31:17] == `AND){
				
				} else if (IR[31:17] == `SUB){
				
				} else if (IR[31:17] == `SHR){
				
				} else if (IR[31:17] == `SHRA){
				
				} else if (IR[31:17] == `ROR){
				
				} else if (IR[31:17] == `ROL){
				
				}
					
			end
			alu5: begin
				Zout
				Gra
				Rin
			end
			
			//MUL, DIV
			muldiv1: begin
				Gra
				Rout
				Yin
			end
			muldiv2: begin
				Grb
				Rout
				Zin
				ZHi
				alu_op = ADD_OP;
			end
			muldiv3: begin
				Zout
				Loin
			end
			muldiv4: begin
				ZHIout
				HIin
				
			end
			
			//NEG, NOT
			negnot1: begin
				Grb
				Rout
				if (IR[31:17] == `NOT){
					alu_op = 
				} else if (IR[31:17] == `NEG){
					alu_op = 
				}
				Zin
			end
			negnot2: begin
				Zout
				Gra
				Rin
			end
			
			//ST,LDI,LD (beginning)
			readwrite1: begin
				Grb
				BAout
				Yin
			end
			readwrite2: begin
				Cout
				alu_op = ADD_OP;
				Zin
			end
			
			load5: begin
				Zout
				MARin
			end
			load6: begin
				Read
			end
			load7: begin
				Read
				MRin
			end
			load8: begin
				MDRout
				GRa
				Rin
			end
			
			loadi5: begin
				Zout
				Gra
				Rin
			end
			
			st5: begin
				zout
				MARin
			end
			st6: begin
				GRA
				Rout
				MDRin
			end
			st7: begin
				Write
			end
			st8: begin
				Read
			end
			
			//ALU IMMEDIATE INSTRUCTIONS
			alui3: begin
				Grb
				Rout
				Yin
			end
			alui4: begin
				Cout
				if (IR[31:17] == `ADDI){
					alu_op = 
				} else if (IR[31:17] == `ORI){
					
				} else if (IR[31:17] == `ANDI){
				
				}
				Zin
			end
			alui5: begin
				zout
				gra
				Rin
			end
			
			//JUMP
			jr3: begin
				Gra
				Rout
				PCin
			end
			jal3: begin
				Grb
				Rin
				Pcout
			end
			jal4: begin
				Gra
				Rout
				PCin
			
			//MOVING
			mflo3: begin
				Gra
				Rin
				LOout
			end
			
			mfhi3: begin
				Gra
				Rin
				Hiout
			end
			
			halt: begin
			end
			
			nop: begin
			end
			
			//BRANCHING
			branch3: begin 
				Gra
				Rout
				CON_In
				Gra
			end
			branch4: begin	
				Pcout
				Yin
			end
			branch5: begin
				Cout
				alu_op = ADD_OP;
				Zin
				ZHIin
			end
				
	
		endcase
	end
	endmodule