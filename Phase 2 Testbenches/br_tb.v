`timescale 1ns/10ps
module br_tb;
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;
    parameter Default = 3'b000;
    parameter T0 = 3'b001, T1 = 3'b010, T2 = 3'b011,
              T3 = 3'b100, T4 = 3'b101, T5 = 3'b110,
              T6 = 3'b111;
    reg [2:0] Present_state = Default;
    initial Clear = 0;
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
    initial begin
	
		//When taken: CON_Out goes HIGH in T6, PCin pulses, PC updates to 0xB + 0x30 = 0x3B (or whichever offset+PC)
        //When not taken: CON_Out stays LOW, PCin never pulses, PC stays at the incremented value from T0
		
        
		//DUT.R3_reg.q = 32'h00000001; //not taken
		DUT.R3_reg.q = 32'h00000000; //taken
		DUT.PC_reg.qTemp = 32'hA; //brzr R3, 48
		
		//DUT.PC_reg.qTemp = 32'hB; //brnz R3, 48
		//DUT.R3_reg.q = 32'h00000001; //taken
		//DUT.R3_reg.q = 32'h00000000; //not taken
		
		//DUT.PC_reg.qTemp = 32'hC;//brpl R3, 48
		//DUT.R3_reg.q = 32'h00000001; //taken
		//DUT.R3_reg.q = 32'hFFFFFFFF; //not taken
		
		//DUT.PC_reg.qTemp = 32'hD; //brmi R3, 48
		//DUT.R3_reg.q = 32'h00000001; // not taken
		//DUT.R3_reg.q = 32'hFFFFFFFF; //taken
		
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
            T3      : #30 Present_state = T4;
            T4      : #30 Present_state = T5;
            T5      : #30 Present_state = T6;
        endcase
    end
    //State Outputs
    always @(Present_state) begin
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;
        case (Present_state)
            Default: begin
                {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
                {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
                {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
                CON_In <= 0;
                alu_op <= 13'b0;
            end
            //Fetch instruction from RAM[PC=0] into MDR
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; IncPC <= 1;
                #20 PCout <= 0; MARin <= 0; Read <= 0; IncPC <= 0;
            end

            T1: begin
                Read <= 1; MDRin <= 1;
                #40 Read <= 0; MDRin <= 0;
            end
			
            T2: begin
                MDRout <= 1; IRin <= 1; // IR <= instruction
                #40 MDRout <= 0; IRin <= 0;
            end
            //Y = Rb (0 if Rb=R0 due to BAout masking)
            T3: begin
                Gra <= 1; Rout <= 1; CON_In <= 1;
                #40 Gra <= 0; Rout <= 0; CON_In <= 0;
            end
            T4: begin
                PCout <= 1; Yin <= 1;
                #40 PCout <= 0; Yin <= 0;
            end
            T5: begin
                Cout <= 1; alu_op <= 13'b00010; Zin <= 1; ZHIin <= 1;
                #40 Cout <= 0; Zin <= 0; ZHIin <= 0;
            end
            T6: begin
                Zout <= 1; 
				#5 PCin <= DUT.CON_Out;
                #35 Zout <= 0; PCin <= 0;
            end
        endcase
    end
endmodule