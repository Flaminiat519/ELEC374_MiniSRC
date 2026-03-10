//inport testbench
`timescale 1ns/10ps

module inport_tb;

    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

    parameter Default = 4'b0000;
    parameter T0  = 4'b0001, T1  = 4'b0010,
              T2  = 4'b0011, T3  = 4'b0100;

    reg [3:0] Present_state = Default;

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
		//OUT instruction out R5
		//loading number into R5
		DUT.R5_reg.q = 32'h40;
		//loading number into IN register
		DUT.INPORT_reg.q = 32'h77;
        DUT.PC_reg.qTemp = 32'h12; //instruction located at 0x12 in ram

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

			//Fetch from ram.hex (in PC)
			// start read
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; IncPC <= 1;     
                #20 PCout <= 0; MARin <= 0; Read <= 0; IncPC <= 0;
            end

			// latch stable mem_data_out
            T1: begin
                Read <= 1; MDRin <= 1;                 
                #40 Read <= 0; MDRin <= 0;
            end

			// IR <- instruction
            T2: begin
                MDRout <= 1; IRin <= 1;                
                #40 MDRout <= 0; IRin <= 0;
            end
			
            //Execute instruction
			//Gra, Rin, INPORT_Out
            T3: begin
                Gra <= 1; Rin <= 1; INPORT_Out <= 1;         
                #40 Gra <= 0; Rin <= 0; INPORT_Out <= 0;
            end
			
        endcase
    end

endmodule
