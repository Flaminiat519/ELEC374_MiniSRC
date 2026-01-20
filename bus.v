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
	input [31:0]BusMuxIn_MDR,
	input [31:0]BusMux_Inport,
	input [31:0]C_sign_extended,
	
	//Encoder
	input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, 
	R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, ZHIout, ZLOout, PCout, MDRout, Inportout, Cout

	//Data coming out from the bus
	output wire [31:0]BusMuxOut
);

reg [31:0]q;

//Initializing correct data to be sent out based on control signals
always @ (*) begin
	if(RZout) q = BusMuxInRZ;
	if(RAout) q = BusMuxInRA;
	if(RBout) q = BusMuxInRB;
end

assign BusMuxOut = q;

endmodule
