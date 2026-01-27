module Bus (
	//Data coming out from each register
	input [31:0]BusMuxIn_R0, 
	input [31:0]BusMuxIn_R1, 
	input [31:0]BusMuxIn_R2,
	input [31:0]BusMuxIn_R3, 
	input [31:0]BusMuxIn_R4, 
	input [31:0]BusMuxIn_R5,
	input [31:0]BusMuxIn_R6, 
	input [31:0]BusMuxIn_R7, 
	input [31:0]BusMuxIn_R8,
	input [31:0]BusMuxIn_R9, 
	input [31:0]BusMuxIn_R10, 
	input [31:0]BusMuxIn_R11,
	input [31:0]BusMuxIn_R12, 
	input [31:0]BusMuxIn_R13, 
	input [31:0]BusMuxIn_R14,
	input [31:0]BusMuxIn_R15, 
	input [31:0]BusMuxIn_HI, 
	input [31:0]BusMuxIn_LO,
	input [31:0]BusMuxIn_ZHI,
	input [31:0]BusMuxIn_ZLO,
	input [31:0]BusMuxIn_PC,
	input [31:0]BusMuxIn_MAR,
	input [31:0]BusMux_Inport,
	input [31:0]C_sign_extended,
	
	//Encoder
	input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, 
	R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, ZHIout, ZLOout, PCout, MARout, Inportout, Cout

	//Data coming out from the bus
	output wire [31:0]BusMuxOut
);

reg [31:0]q;

//Initializing correct data to be sent out based on control signals
always @ (*) begin
	if(R0out) q = BusMuxIn_R0;
	else if(R1out)		q = BusMuxIn_R1;
	else if(R2out)		q = BusMuxIn_R2;
	else if(R3out)		q = BusMuxIn_R3;
	else if(R4out)		q = BusMuxIn_R4;
	else if(R5out)		q = BusMuxIn_R5;
	else if(R6out)		q = BusMuxIn_R6;
	else if(R7out)		q = BusMuxIn_R7;
	else if(R8out)		q = BusMuxIn_R8;
	else if(R9out)		q = BusMuxIn_R9;
	else if(R10out)		q = BusMuxIn_R10;
	else if(R11out) 	q = BusMuxIn_R11;
	else if(R12out) 	q = BusMuxIn_R12;
	else if(R13out) 	q = BusMuxIn_R13;
	else if(R14out) 	q = BusMuxIn_R14;
	else if(R15out) 	q = BusMuxIn_R15;
	else if(HIout)		q = BusMuxIn_HI;
	else if(LOout)		q = BusMuxIn_LO;
	else if(ZHIout) 	q = BusMuxIn_ZHI;
	else if(ZLOout) 	q = BusMuxIn_ZLO;
	else if(PCout)		q = BusMuxIn_PC;
	else if(MARout) 	q = BusMuxIn_MAR;
	else if(Inportout) 	q = BusMuxIn_Inport;
	else if(Cout)		q = C_sign_extended;
	
	else	  			q = 32'b0;
	
end

assign BusMuxOut = q;

endmodule
