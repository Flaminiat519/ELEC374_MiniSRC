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
        // ============================================================
        // CASE 1: brzr R3, 48  — branch taken when R3 == 0
        //   PC=0x00A, fetch gets A9800030 from RAM
        //   TAKEN:     R3=0            → PC after T6 = 0x00A+1+48 = 0x03B
        //   NOT TAKEN: R3=32'h1        → PC after T6 = 0x00B
        DUT.PC_reg.qTemp = 32'h00A;
        DUT.R3_reg.q     = 32'h0;       // swap to 32'h1 for NOT TAKEN

        // ============================================================
        // CASE 2: brnz R3, 48  — branch taken when R3 != 0
        //   PC=0x00B, fetch gets A9880030 from RAM
        //   TAKEN:     R3=32'h1        → PC after T6 = 0x03C
        //   NOT TAKEN: R3=32'h0        → PC after T6 = 0x00C
        // DUT.PC_reg.qTemp = 32'h00B;
        // DUT.R3_reg.q     = 32'h1;    // swap to 32'h0 for NOT TAKEN

        // ============================================================
        // CASE 3: brpl R3, 48  — branch taken when R3 >= 0
        //   PC=0x00C, fetch gets A9900030 from RAM
        //   TAKEN:     R3=32'h5        → PC after T6 = 0x03D
        //   NOT TAKEN: R3=32'h80000000 → PC after T6 = 0x00D
        // DUT.PC_reg.qTemp = 32'h00C;
        // DUT.R3_reg.q     = 32'h5;    // swap to 32'h80000000 for NOT TAKEN

        // ============================================================
        // CASE 4: brmi R3, 48  — branch taken when R3 < 0
        //   PC=0x00D, fetch gets A9980030 from RAM
        //   TAKEN:     R3=32'h80000000 → PC after T6 = 0x03E
        //   NOT TAKEN: R3=32'h5        → PC after T6 = 0x00E
        // DUT.PC_reg.qTemp = 32'h00D;
        // DUT.R3_reg.q     = 32'h80000000; // swap to 32'h5 for NOT TAKEN

        Clock = 0;
        forever #10 Clock = ~Clock;
    end

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

    always @(Present_state) begin
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;

        case (Present_state)
            // T0: PC → MAR, read RAM → MDR, IncPC
            T0: begin
                PCout<=1; MARin<=1; Read<=1; MDRin<=1; IncPC<=1;
                #20;
                PCout<=0; MARin<=0; Read<=0; MDRin<=0; IncPC<=0;
            end
            // T1: MDR → IR
            T1: begin
                MDRout<=1; IRin<=1;
                #40;
                MDRout<=0; IRin<=0;
            end
            // T2: IR settles, no bus activity
            T2: begin end
            // T3: Ra (R3) → bus, latch CON FF
            T3: begin
                Gra<=1; Rout<=1; CON_In<=1;
                #40;
                Gra<=0; Rout<=0; CON_In<=0;
            end
            // T4: PC+1 → Y
            T4: begin
                PCout<=1; Yin<=1;
                #40;
                PCout<=0; Yin<=0;
            end
            // T5: Z = Y + C  (PC+1 + sign-extended 48)
            T5: begin
                Cout<=1; alu_op<=13'b0000000000011; Zin<=1;
                #40;
                Cout<=0; alu_op<=13'b0; Zin<=0;
            end
            // T6: if CON_FF=1, PC ← branch target; else PC unchanged
            T6: begin
                Zout<=1; PCin<=CON_Out;
                #40;
                Zout<=0; PCin<=0;
            end
        endcase
    end
endmodule