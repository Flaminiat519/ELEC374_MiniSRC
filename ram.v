`timescale 1ns/10ps

module ram(
	input wire [31:0] D,
	input wire [8:0] address,
	input wire clock,
	input wire read,
	input wire write,
	output wire [31:0] Q
	);
	
	reg [31:0] memory [0:511];
	initial $readmemh("ram.hex", memory);
	
	initial begin
            // ORG 0
            memory[0] = 32'h08800002; // ldi R1, 2 ; R1 = 2
            memory[1] = 32'h08080000; // ldi R0, 0(R1) ; R0 = 2
            memory[2] = 32'h01000068; // ld R2, $68 ; R2 = ($68) = $55
            memory[3] = 32'h0917FFFC; // ldi R2, -4(R2) ; R2 = $51
            memory[4] = 32'h00900001; // ld R1, 1(R2) ; R1 = ($52) = $26
            memory[5] = 32'h09800069; // ldi R3, $69 ; R3 = $69
            memory[6] = 32'h99980004; // brmi R3, 4 ; continue with the next instruction (will not branch)
            memory[7] = 32'h09980002; // ldi R3, 2(R3) ; R3 = $6B
            memory[8] = 32'h039FFFFD; // ld R7, -3(R3) ; R7 = ($6B - 3) = $55
            memory[9] = 32'hD0000000; // nop
            memory[10] = 32'h9B900002; // brpl R7, 2 ; continue with the instruction at “target” (will branch)
            memory[11] = 32'h09040005; // ldi R2, 5(R0) ; this instruction will not execute (also R0 is a forbidden register!)
            memory[12] = 32'h09880002; // ldi R3, 2(R1) ; this instruction will not execute

            // Target
            memory[13] = 32'h19918000; // add R3, R2, R3 ; R3 = $BC
            memory[14] = 32'h63B80002; // addi R7, R7, 2 ; R7 = $57
            memory[15] = 32'h8BB80000; // neg R7, R7 ; R7 = $FFFFFFA9
            memory[16] = 32'h93B80000; // not R7, R7 ; R7 = $56
            memory[17] = 32'h6BB8000F; // andi R7, R7, $0F ; R7 = 6
            memory[18] = 32'h50880000; // ror R1, R1, R0 ; R1 = $80000009
            memory[19] = 32'h7388001C; // ori R7, R1, $1C ; R7 = $8000001D
            memory[20] = 32'h43B80000; // shra R7, R7, R0 ; R7 = $E0000007
            memory[21] = 32'h39180000; // shr R2, R3, R0 ; R2 = $2F
            memory[22] = 32'h11000052; // st $52, R2 ; ($52) = $2F new value in memory with address $52
            memory[23] = 32'h59100000; // rol R2, R2, R0 ; R2 = $BC
            memory[24] = 32'h31180000; // or R2, R3, R0 ; R2 = $BE
            memory[25] = 32'h28908000; // and R1, R2, R1 ; R1 = $8
            memory[26] = 32'h11880060; // st $60(R1), R3 ; ($68) = $BC new value in memory with address $68
            memory[27] = 32'h21918000; // sub R3, R2, R3 ; R3 = 2
            memory[28] = 32'h48900000; // shl R1, R2, R0 ; R1 = $2F8
            memory[29] = 32'h0A000006; // ldi R4, 6 ; R4 = 6
            memory[30] = 32'h0A800032; // ldi R5, $32 ; R5 = $32
            memory[31] = 32'h7AA00000; // mul R5, R4 ; HI = 0; LO = $12C
            memory[32] = 32'hC3800000; // mfhi R7 ; R7 = 0
            memory[33] = 32'hCB000000; // mflo R6 ; R6 = $12C
            memory[34] = 32'h82A00000; // div R5, R4 ; HI = 2, LO = 8
            memory[35] = 32'h0C27FFFF; // ldi R8, -1(R4) ; R8 = 5 setting up argument registers
            memory[36] = 32'h0CAFFFED; // ldi R9, -19(R5) ; R9 = $1F R8, R9, R10, and R11
            memory[37] = 32'h0D300000; // ldi R10, 0(R6) ; R10 = $12C
            memory[38] = 32'h0DB80000; // ldi R11, 0(R7) ; R11 = 0
            memory[39] = 32'hAD000000; // jal R10 ; address of subroutine subA in R10 - return address in R15

            // Phase 4
            memory[40] = 32'hB2000000; // in R4 ; set 8 switches (SW[0] to SW[7]) to $88 – read it into the lower 8 bits
            memory[41] = 32'h12000095; // st $95, R4 ; of R4 (set other input bits to 0), and save it for the next time around
            memory[42] = 32'h0880002D; // ldi R1, $2D ; address of loop in R1
            memory[43] = 32'h0B800001; // ldi R7, 1 ; R7 = 1
            memory[44] = 32'h0A800028; // ldi R5, 40 ; R5 = 40, loop counter (5 times)
				
            memory[45] = 32'hBA000000; // $2D loop out R4 ; display the lower 8 bits of R4 on the two 7-segment displays
            memory[46] = 32'h0AAFFFFF; // ldi R5, -1(R5) ; is the loop done?
            memory[47] = 32'h9A800008; // brzr R5, 8 ; yes – branch to done
            memory[48] = 32'h030000F0; // ld R6, $F0 ; no – set R6 = $FFFF; delay, so you can see the numbers on the
				
            memory[49] = 32'h0B37FFFF; // loop2 ldi R6, -1(R6) ; two 7-segment displays
            memory[50] = 32'hD0000000; // nop
            memory[51] = 32'h9B0FFFFD; // brnz R6, -3 ; branch to loop2 if R6 ≠ 0 – delay is not done yet
            memory[52] = 32'h3A238000; // shr R4, R4, R7 ; delay is done - shift the number in R4 right once
            memory[53] = 32'h9A0FFFF7; // brnz R4, -9 ; back to loop and display the shifted number if it is not zero
            memory[54] = 32'h02000095; // ld R4, $95 ; if it is zero, start over with the number $88
            memory[55] = 32'hA0800000; // jr R1 ; branch to loop using address in R1
            memory[56] = 32'h0A0000A5; // done ldi R4, $A5 ; final display value $A5
            memory[57] = 32'hBA000000; // out R4 ; display the final display value $5A on the two 7-segment displays
            
            memory[58] = 32'hD8000000; // halt ; upon return, the program halts

            // subA @ $12C (300)
            memory[300] = 32'h1EC50000; // add R13, R8, R10 ; R12 and R13 are return value registers
            memory[301] = 32'h264D8000; // sub R12, R9, R11 ; R13 = $131, R12 = $1F
            memory[302] = 32'h26EE0000; // sub R13, R13, R12 ; R13 = $112
            memory[303] = 32'hA7800000; // jr R15 ; return from procedure

            memory[104] = 32'h55;
            memory[82] = 32'h26;
            memory[240] = 32'hFFFF;
    end
	
	reg [31:0] qTemp = 32'b0;
	always @ (posedge write, posedge read) begin
		if (write) begin
			memory[address] <= D;
		end
		else if (read) begin
			qTemp <= memory[address];
		end
	end
	assign Q = qTemp;
endmodule