`timescale 1ns/10ps


module jump_instructions_tb;
	
	//Initalzie DUT input and outpurt signals
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

	//Setup state machine
    parameter Default = 4'b0000;
     parameter T0  = 4'b0001, T1  = 4'b0010,
              T2  = 4'b0011, T3  = 4'b0100, T4  = 4'b0101;

    reg [3:0] Present_state = Default;

    initial Clear = 0;
	
	//Instatiate data_path 
    data_path DUT (
        .clock(Clock), .clear(Clear),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .HIin(HIin), .HIout(HIout),
        .LOin(LOin), .LOout(LOout),
        .Zin(Zin), .Zout(Zout), .ZHIout(ZHIout), .ZHIin(ZHIin),
        .PCin(PCin), .PCout(PCout),
        .MARin(MARin), .MARout(),
        .MDRin(MDRin), .MDRout(MDRout),
        .IRin(IRin), .IRout(),
        .Yin(Yin), .Yout(),
        .OUTPORT_In(OUTPORT_In), .INPORT_Out(INPORT_Out), .OUTPORT_Out(OUTPORT_Out),
        .Cout(Cout),
        .IncPC(IncPC), .Read(Read), .Write(Write),
        .MDatain(32'b0),
        .alu_op(alu_op),
        .CON_In(CON_In), .CON_Out(CON_Out),
        .BusMuxOut(BusMuxOut)
    );
	
	//Preload registers and set up PC to point to the correct instruction
    initial begin
        //jump instruction jr R12
        DUT.R12_reg.q = 32'hff;
        DUT.PC_reg.qTemp = 32'h10; //instruction located at 0x10 in ram
		
		//jal instruction jal R4
		//DUT.R4_reg.q = 32'h32;
		//DUT.R12_reg.q = 32'hff;
        //DUT.PC_reg.qTemp = 32'hf; //instruction located at 0xf in ram


        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    //State Transitions
    always @(posedge Clock) begin
        case (Present_state)
            Default : #30 Present_state = T0;
            T0      : #30 Present_state = T1;
            T1      : #30 Present_state = T2;
            T2      : #30 Present_state = T3;
			T3		: #30 Present_state = T4;
        endcase
    end

    //State Outputs
    always @(Present_state) begin
		//Deassert all enable signals
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;

        case (Present_state)
           // Fetch from ram.hex at PC value
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; IncPC <= 1;     
                #20 PCout <= 0; MARin <= 0; Read <= 0; IncPC <= 0;
            end

            T1: begin
                Read <= 1; MDRin <= 1; //MDR = value stored in memory
                #40 Read <= 0; MDRin <= 0;
            end
			
            T2: begin
                MDRout <= 1; IRin <= 1; // IR = instruction
                #40 MDRout <= 0; IRin <= 0;
            end

            // EXECUTE instruction
            T3: begin
				//jr R12 instruction
                Gra <= 1; Rout <= 1; PCin <= 1;  // PC = RA (R12)
                #40 Gra <= 0; Rout <= 0; PCin <= 0;
				//jal R4 instruction
				//Grb <= 1; Rin <= 1; PCout <= 1;	//R12 = PC + 1
				//#40 Grb <= 0; Rin <= 0; PCout <= 0; 
				
            end
			
			//Only for jal R4
			//T4: begin
			//	Gra <= 1; Rout <= 1; PCin <= 1; //PC = R4
			//	#40 Gra <= 0; Rout <= 0; PCin <= 0;
			//end

        endcase
    end

endmodule