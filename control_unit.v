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

module control_unit (
	output reg         Clock, Clear;
    output reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    output reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    output reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    output reg         CON_In, CON_Out, OUTPORT_Out;
	
	input [31:0] IR,
	input Clock, Reset, Stop);
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
				reset_state: 
					present_state = fetch0;
				fetch0: 
					present_state = fetch1;
				fetch1: 
					present_state = fetch2;
				fetch2: begin
							case (IR[31:27]) // inst. decoding based on the opcode to set the next state
								5’b00000: present_state = add3; // this is the add instruction
							endcase
						end
				add3: 
					present_state = add4;
				add4: 
					present_state = add5;
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
			add3: begin
				Grb <= 1; Rout <= 1;
				Yin <= 1;
			end
		endcase
	end
	endmodule