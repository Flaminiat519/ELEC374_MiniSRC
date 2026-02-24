`timescale 1ns/10ps

module andi_tb;

    reg clock, clear;

    // Encoder control
    reg Gra, Grb, Grc, Rin, Rout, BAout;

    // Special registers
    reg HIin, HIout;
    reg LOin, LOout;
    reg Zin, Zout, ZHIout, ZHIin;
    reg PCin, PCout;
    reg MARin, MARout;
    reg MDRin, MDRout;
    reg IRin, IRout;
    reg Yin, Yout;

    reg OUTPORT_In, INPORT_Out, OUTPORT_Out;

    reg IncPC, Read, Write;
    reg CON_In;
    wire CON_Out;

    reg [31:0] MDatain;
    wire [31:0] BusMuxOut;

    parameter Default = 4'b0000,
              T0 = 4'b0001,
              T1 = 4'b0010,
              T2 = 4'b0011,
              T3 = 4'b0100,
              T4 = 4'b0101,
              T5 = 4'b0110;

    reg [3:0] Present_state = Default;

    // ✅ CORRECT instantiation using named mapping
    data_path DUT(
        .clock(clock),
        .clear(clear),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout),

        .HIin(HIin), .HIout(HIout),
        .LOin(LOin), .LOout(LOout),

        .Zin(Zin), .Zout(Zout),
        .ZHIout(ZHIout), .ZHIin(ZHIin),

        .PCin(PCin), .PCout(PCout),
        .MARin(MARin), .MARout(MARout),
        .MDRin(MDRin), .MDRout(MDRout),
        .IRin(IRin), .IRout(IRout),
        .Yin(Yin), .Yout(Yout),

        .OUTPORT_In(OUTPORT_In),
        .INPORT_Out(INPORT_Out),
        .OUTPORT_Out(OUTPORT_Out),

        .IncPC(IncPC),
        .Read(Read),
        .Write(Write),

        .MDatain(MDatain),
        .BusMuxOut(BusMuxOut),

        .CON_In(CON_In),
        .CON_Out(CON_Out)
    );

    // Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // State progression
    always @(posedge clock) begin
        case (Present_state)
            Default : Present_state <= T0;
            T0 : Present_state <= T1;
            T1 : Present_state <= T2;
            T2 : Present_state <= T3;
            T3 : Present_state <= T4;
            T4 : Present_state <= T5;
        endcase
    end

    // Control sequence for ANDI
    always @(Present_state) begin

        // default all signals low
        {Gra,Grb,Grc,Rin,Rout,BAout,
         HIin,HIout,LOin,LOout,
         Zin,Zout,ZHIout,ZHIin,
         PCin,PCout,MARin,MARout,
         MDRin,MDRout,IRin,IRout,
         Yin,Yout,
         OUTPORT_In,INPORT_Out,OUTPORT_Out,
         IncPC,Read,Write,
         CON_In} = 0;

        case (Present_state)

            // Fetch
            T0: begin
                PCout = 1; MARin = 1; IncPC = 1;
            end

            T1: begin
                Read = 1; MDRin = 1;
            end

            T2: begin
                MDRout = 1; IRin = 1;
            end

            // T3: Grb, Rout, Yin
            T3: begin
                Grb = 1; Rout = 1; Yin = 1;
            end

            // T4: immediate (C) AND Y → Z
            T4: begin
                Zin = 1;
                force DUT.alu_op = (13'b1 << 0);  // AND
            end

            // T5: Zout, Gra, Rin
            T5: begin
                Zout = 1; Gra = 1; Rin = 1;
                release DUT.alu_op;
            end

        endcase
    end

    initial begin
        clear = 1;
        #20 clear = 0;
    end

endmodule