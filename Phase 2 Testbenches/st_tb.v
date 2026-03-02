`timescale 1ns/10ps
module st_tb;

    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;

    parameter Default = 4'b0000;
    parameter T0  = 4'b0001, T1  = 4'b0010, T2  = 4'b0011,
              T3  = 4'b0100, T4  = 4'b0101, T5  = 4'b0110,
              T6  = 4'b0111, T7  = 4'b1000, T8  = 4'b1001;

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
        // ---------------------------------------------------------------
        // Case 1: st 0x1F, R6          --> RAM[0x04] = 32'h9300001F
        //   Rb = R0, BAout forces 0 onto bus
        //   Effective address = 0x00 + 0x1F = 0x1F
        //   Writes R6 (0x63) --> mem[0x1F]
        //   Verify: mem[0x1F] changes from 0xD4 --> 0x63
        //
        // Case 2: st 0x1F(R6), R6      --> RAM[0x05] = 32'h9330001F
        //   Rb = R6 = 0x63, BAout passes R6 onto bus
        //   Effective address = 0x63 + 0x1F = 0x82
        //   Writes R6 (0x63) --> mem[0x82]
        //   Verify: mem[0x82] changes from 0xA7 --> 0x63
        // ---------------------------------------------------------------

        // Case 1: PC points to RAM[0x04]
        DUT.PC_reg.qTemp = 32'd4;

        // To run Case 2 instead, comment the line above and uncomment:
        // DUT.PC_reg.qTemp = 32'd5;

        // Preload R6 = 0x63 -- required for both cases
        DUT.R6_reg.q = 32'h00000063;

        // Let hierarchy resolve before reading memory
        #1;
        $display("=== BEFORE WRITE ===");
        $display("RAM[0x1F] = 0x%08h  (initial value, expect 0x000000D4)", DUT.RAM.mem[8'h1F]);
        $display("RAM[0x82] = 0x%08h  (initial value, expect 0x000000A7)", DUT.RAM.mem[8'h82]);

        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // ---------------------------------------------------------------
    // State Transitions
    // ---------------------------------------------------------------
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

    // ---------------------------------------------------------------
    // State Outputs
    //
    // Control Sequence for st:
    //   T0: PCout, MARin, Read, IncPC    -- fetch: PC->MAR, read RAM, PC++
    //   T1: Read, MDRin                  -- latch instruction word into MDR
    //   T2: MDRout, IRin                 -- IR <= instruction word
    //   T3: Grb, BAout, Yin              -- Y <= Rb (0 if Rb=R0, else Rb contents)
    //   T4: Cout, ADD, Zin               -- Z <= Y + sign_extended(C)
    //   T5: Zout, MARin                  -- MAR <= effective address
    //   T6: Gra, Rout, MDRin             -- MDR <= Ra (data to write)
    //   T7: Write                        -- RAM[MAR] <= MDR
    //   T8: Read, MDRin                  -- read-back for verification
    // ---------------------------------------------------------------
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

            // T0: PC -> MAR, begin RAM read, PC++
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; IncPC <= 1;
                #20 PCout <= 0; MARin <= 0; Read <= 0; IncPC <= 0;
            end

            // T1: Latch instruction word from RAM into MDR
            T1: begin
                Read <= 1; MDRin <= 1;
                #40 Read <= 0; MDRin <= 0;
            end

            // T2: IR <= instruction word
            T2: begin
                MDRout <= 1; IRin <= 1;
                #40 MDRout <= 0; IRin <= 0;
            end

            // T3: Y <= Rb
            //   Case 1 (Rb=R0): BAout forces 0x00 onto bus --> Y = 0
            //   Case 2 (Rb=R6): BAout passes R6 = 0x63     --> Y = 0x63
            T3: begin
                Grb <= 1; BAout <= 1; Yin <= 1;
                #40 Grb <= 0; BAout <= 0; Yin <= 0;
            end

            // T4: Z <= Y + sign_extended(C)
            //   Case 1: 0x00 + 0x1F = 0x1F
            //   Case 2: 0x63 + 0x1F = 0x82
            T4: begin
                Cout <= 1; alu_op <= 13'b0000000010000; Zin <= 1;
                #40 Cout <= 0; Zin <= 0;
            end

            // T5: MAR <= Z (effective address)
            T5: begin
                Zout <= 1; MARin <= 1;
                #40 Zout <= 0; MARin <= 0;
            end

            // T6: MDR <= Ra (R6 = 0x63, the value to store)
            T6: begin
                Gra <= 1; Rout <= 1; MDRin <= 1;
                #40 Gra <= 0; Rout <= 0; MDRin <= 0;
            end

            // T7: RAM[MAR] <= MDR  (the actual write)
            T7: begin
                Write <= 1;
                #40 Write <= 0;

                $display("=== AFTER WRITE (T7) ===");
                $display("RAM[0x1F] = 0x%08h  (Case 1 expects 0x00000063, Case 2 unchanged 0x000000D4)", DUT.RAM.mem[8'h1F]);
                $display("RAM[0x82] = 0x%08h  (Case 2 expects 0x00000063, Case 1 unchanged 0x000000A7)", DUT.RAM.mem[8'h82]);
            end

            // T8: Read-back -- verify the write by reading the address back
            //   MDR should show 0x63 for whichever case is active
            T8: begin
                Read <= 1; MDRin <= 1;
                #40 Read <= 0; MDRin <= 0;

                $display("=== READ-BACK (T8) ===");
                $display("MDR = 0x%08h  (expects 0x00000063 -- confirms write succeeded)", DUT.MDR_reg.Q);
            end

        endcase
    end

endmodule


