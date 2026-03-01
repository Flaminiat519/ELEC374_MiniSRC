`timescale 1ns/10ps
module st_tb;
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

    parameter Default = 3'b000;
    parameter T0 = 3'b001, T1 = 3'b010, T2 = 3'b011,
              T3 = 3'b100, T4 = 3'b101, T5 = 3'b110;
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
        // Case 1: st 0x1F, R6  →  mem[0x1F] = R6 = 0x63
        // RAM file already has mem[0x1F] = 0xD4 preloaded at @01F
        DUT.PC_reg.qTemp = 32'd4;        // PC points to instruction @004: 9300001F
        DUT.R6_reg.q     = 32'h00000063; // preload R6 = 0x63

        // Case 2: st 0x1F(R6), R6  →  mem[0x82] = R6 = 0x63
        // RAM file already has mem[0x82] = 0xA7 preloaded at @082
        // DUT.PC_reg.qTemp = 32'd5;        // PC points to instruction @005: 9330001F
        // DUT.R6_reg.q     = 32'h00000063; // preload R6 = 0x63

        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // State Transitions
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

    // State Outputs
    always @(Present_state) begin
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;

        case (Present_state)
            Default: begin
                // All signals already zeroed above
            end

            // T0: Fetch — MAR <- PC, read RAM[PC] into MDR, PC++
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; MDRin <= 1; IncPC <= 1;
                #20 PCout <= 0; MARin <= 0; Read <= 0; MDRin <= 0; IncPC <= 0;
            end

            // T1: Decode — IR <- MDR
            T1: begin
                MDRout <= 1; IRin <= 1;
                #40 MDRout <= 0; IRin <= 0;
            end

            // T2: Y <- Rb (BAout: R0=0 for Case1; R6 for Case2)
            T2: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
                #40 Grb <= 0; BAout <= 0; Yin <= 0;
            end

            // T3: Z <- Y + C (sign-extended immediate)
            T3: begin
                Cout <= 1; alu_op <= 13'b0000000010000; Zin <= 1;
                #40 Cout <= 0; Zin <= 0;
            end

            // T4: MAR <- Z (effective address)
            T4: begin
                Zout <= 1; MARin <= 1;
                #40 Zout <= 0; MARin <= 0;
            end

            // T5: MDR <- Ra (Grc selects R6), then Write to RAM
            T5: begin
                Grc <= 1; Rout <= 1; MDRin <= 1;
                #20 Grc <= 0; Rout <= 0; MDRin <= 0;
                Write <= 1;
                #20 Write <= 0;
            end
        endcase
    end

endmodule