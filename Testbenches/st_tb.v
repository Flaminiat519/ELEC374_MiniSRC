//ST test bench
`timescale 1ns/10ps
module st_tb;
    //Initialize registers
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

    //Initialize states
    parameter Default = 4'b0000;
    parameter T0  = 4'b0001, T1  = 4'b0010, T2  = 4'b0011,
              T3  = 4'b0100, T4  = 4'b0101, T5  = 4'b0110,
              T6  = 4'b0111, T7  = 4'b1000, T8  = 4'b1001;

    reg [3:0] Present_state = Default;
    initial Clear = 0;

    //Initialize datapath
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
        //Case 1
        DUT.PC_reg.qTemp = 32'd4;
        //Case 2
        //DUT.PC_reg.qTemp = 32'd5;
        //For both cases
        DUT.R6_reg.q = 32'h00000063;

        
        //Read Memory and display #1;
        $display("BEFORE WRITE");
        $display("RAM[0x1F] = 0x%08h  (initial value, expect 0x000000D4)", DUT.RAM.mem[8'h1F]);
        $display("RAM[0x82] = 0x%08h  (initial value, expect 0x000000A7)", DUT.RAM.mem[8'h82]);

        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    //State transitions
    always @(posedge Clock) begin
        case (Present_state)
            Default : #30 Present_state = T0;
            T0      : #30 Present_state = T1;
            T1      : #30 Present_state = T2;
            T2      : #30 Present_state = T3;
            T3      : #30 Present_state = T4;
            T4      : #30 Present_state = T5;
            T5      : #30 Present_state = T6;
            T6      : #30 Present_state = T7;
            T7      : #30 Present_state = T8;
        endcase
    end

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

            //Instruction fetch T0-T2
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; IncPC <= 1;
                #20 PCout <= 0; MARin <= 0; Read <= 0; IncPC <= 0;
            end
            T1: begin
                Read <= 1; MDRin <= 1;
                #40 Read <= 0; MDRin <= 0;
            end
            T2: begin
                MDRout <= 1; IRin <= 1;
                #40 MDRout <= 0; IRin <= 0;
            end
            //Case 1 (Rb=R0): BAout forces 0x00 onto bus
            //Case 2 (Rb=R6): BAout passes R6 = 0x63
            T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
                #40 Grb <= 0; BAout <= 0; Yin <= 0;
            end
            T4: begin //Z=Y+Sign extended C
                Cout <= 1; alu_op <= 13'b0000000010000; Zin <= 1;
                #40 Cout <= 0; Zin <= 0;
            end
            T5: begin
                Zout <= 1; MARin <= 1;
                #40 Zout <= 0; MARin <= 0;
            end
            T6: begin
                Gra <= 1; Rout <= 1; MDRin <= 1;
                #40 Gra <= 0; Rout <= 0; MDRin <= 0;
            end
            T7: begin
                Write <= 1;
                #40 Write <= 0;
                $display("AFTER WRITE");
                $display("RAM[0x1F] = 0x%08h  (Case 1 expects 0x00000063, Case 2 unchanged 0x000000D4)", DUT.RAM.mem[8'h1F]);
                $display("RAM[0x82] = 0x%08h  (Case 2 expects 0x00000063, Case 1 unchanged 0x000000A7)", DUT.RAM.mem[8'h82]);
            end
            T8: begin //verify correctness by reading the address back
                Read <= 1; MDRin <= 1;
                #40 Read <= 0; MDRin <= 0;

                $display("READ-BACK to verify");
                $display("MDR = 0x%08h  (expects 0x00000063)", DUT.MDR_reg.Q);
            end

        endcase
    end

endmodule


