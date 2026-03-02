`timescale 1ns/10ps
module branch_tb;
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

    parameter Default=3'b000, T0=3'b001, T1=3'b010, T2=3'b011,
              T3=3'b100, T4=3'b101, T5=3'b110, T6=3'b111;
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
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    initial begin
        #1;
        // ============================================================
        // CASE 1: brzr R3, 48 — TAKEN when R3 == 0
        //   RAM @00A = A9800030, target = 0x00A+1+48 = 0x03B
        //   NOT TAKEN: change R3_reg.q to 32'h1
        DUT.PC_reg.qTemp = 32'h00A;
        DUT.R3_reg.q     = 32'h0;

        // ============================================================
        // CASE 2: brnz R3, 48 — TAKEN when R3 != 0
        //   RAM @00B = A9880030, target = 0x03C
        //   NOT TAKEN: change R3_reg.q to 32'h0
        // DUT.PC_reg.qTemp = 32'h00B;
        // DUT.R3_reg.q     = 32'h1;

        // ============================================================
        // CASE 3: brpl R3, 48 — TAKEN when R3 >= 0
        //   RAM @00C = A9900030, target = 0x03D
        //   NOT TAKEN: change R3_reg.q to 32'h80000000
        // DUT.PC_reg.qTemp = 32'h00C;
        // DUT.R3_reg.q     = 32'h5;

        // ============================================================
        // CASE 4: brmi R3, 48 — TAKEN when R3 < 0
        //   RAM @00D = A9980030, target = 0x03E
        //   NOT TAKEN: change R3_reg.q to 32'h5
        // DUT.PC_reg.qTemp = 32'h00D;
        // DUT.R3_reg.q     = 32'h80000000;
    end

    // State Transitions
    always @(posedge Clock) begin
        case (Present_state)
            Default : Present_state = T0;
            T0      : #40 Present_state = T1;
            T1      : #40 Present_state = T2;
            T2      : #40 Present_state = T3;
            T3      : #40 Present_state = T4;
            T4      : #40 Present_state = T5;
            T5      : #40 Present_state = T6;
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
            end

            // T0: PC → MAR, IncPC
            T0: begin
                #10 PCout <= 1; MARin <= 1; IncPC <= 1;
            end

            // T1: drop T0 signals, assert Read so RAM sees address at next posedge
            T1: begin
                #10 PCout <= 0; MARin <= 0; IncPC <= 0;
                #10 Read <= 1; MDRin <= 1;
            end

            // T2: drop Read/MDRin, MDR now has instruction, load IR
            T2: begin
                #10 Read <= 0; MDRin <= 0;
                #10 MDRout <= 1; IRin <= 1;
            end

            // T3: drop IR load, put R3 on bus, latch CON FF
            T3: begin
                #10 MDRout <= 0; IRin <= 0;
                #10 Gra <= 1; Rout <= 1; CON_In <= 1;
            end

            // T4: drop T3 signals, PC+1 → Y
            T4: begin
                #10 Gra <= 0; Rout <= 0; CON_In <= 0;
                #10 PCout <= 1; Yin <= 1;
            end

            // T5: drop T4 signals, Z = Y + C (ADD)
            T5: begin
                #10 PCout <= 0; Yin <= 0;
                #10 Cout <= 1; alu_op <= 13'b0000000010000; Zin <= 1;
            end

            // T6: drop T5 signals, if CON=1 PC gets branch target
            T6: begin
                #10 Cout <= 0; alu_op <= 13'b0; Zin <= 0;
                #10 Zout <= 1; PCin <= DUT.CON;
            end

        endcase
    end

endmodule