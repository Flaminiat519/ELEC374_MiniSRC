`timescale 1ns/10ps
//Defines for different ALU operations
`define ADD 13'b0000000010000
`define AND 13'b0000000000001
`define OR 13'b0000000000010

module ALU_immediate_instructions_tb;

	//Initialize DUT signals
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
              T2  = 4'b0011, T3  = 4'b0100, T4  = 4'b0101,
              T5  = 4'b0110;

    reg [3:0] Present_state = Default;

    initial Clear = 0;

	//Instantiate data_path	
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

	//Preload registers and set PC
    initial begin
        //ADDI instrcution addi R7, R4, -9.
		DUT.R7_reg.q = 32'd420;
        DUT.R4_reg.q = 32'd100;
        DUT.PC_reg.qTemp = 32'd6; //instruction located at 0x6 in ram
		
		//ANDI instruction andi R7, R4, 0x71
		//DUT.R7_reg.q = 32'h42;
		//DUT.R4_reg.q = 32'h34;
        //DUT.PC_reg.qTemp = 32'd8; //instruction located at 0x8 in ram
		
		//ORI instruction ori R7, R4, 0x71
		//DUT.R7_reg.q = 32'h42;
		//DUT.R4_reg.q = 32'h34;
        //DUT.PC_reg.qTemp = 32'd9; //instruction located at 0x9 in ram

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
        endcase
    end

    //State Outputs
    always @(Present_state) begin
		//Deassert all enables
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;

        case (Present_state)
		
		

            //FETCH from ram.hex at location in PC
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

            // EXECUTE instruction
            T3: begin
                Grb <= 1; Rout <= 1; Yin <= 1;// Y = R4
                #40 Grb <= 0; Rout <= 0; Yin <= 0;
            end

            T4: begin
                Cout <= 1; 
				//Comment Out instructions not being tested
				alu_op <= `ADD;
				//alu_op <= `AND;
				//alu_op <= `OR;
				Zin <= 1;  // Z = Y + C
                #40 Cout <= 0; Zin <= 0;
            end

            T5: begin
                Zout <= 1; Gra <= 1; Rin <= 1; // R7 = Z
                #40 Zout <= 0; Gra <= 0; Rin <= 0;
            end
        endcase
    end

endmodule