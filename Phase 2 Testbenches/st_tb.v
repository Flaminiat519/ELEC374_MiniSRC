`timescale 1ns/10ps
module branch_tb;
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
        // ================================================================
        // SELECT ONE CASE AT A TIME — comment/uncomment as needed
        // Expected branch target when TAKEN = PC_after_fetch + 48
        //   PC_after_fetch = PC+1 (IncPC happens in T0)
        //   So target = initial_PC + 1 + 48
        //
        // Case 1 brzr: PC=0x00A → target = 0x00A+1+48 = 0x03B  (taken when R3==0)
        // Case 2 brnz: PC=0x00B → target = 0x00B+1+48 = 0x03C  (taken when R3!=0)
        // Case 3 brpl: PC=0x00C → target = 0x00C+1+48 = 0x03D  (taken when R3>=0)
        // Case 4 brmi: PC=0x00D → target = 0x00D+1+48 = 0x03E  (taken when R3<0)
        //
        // NOT TAKEN: PC stays at initial_PC+1 (e.g. 0x00B for case 1)
        // ================================================================

        // ---- CASE 1: brzr R3, 48 ----
        // Memory[0x00A] = A9800030 (fetched automatically via Read in T0)
        // TAKEN:     R3 = 0           → CON_FF=1 → PC becomes 0x03B
        // NOT TAKEN: R3 = 32'h1       → CON_FF=0 → PC stays  0x00B
        DUT.PC_reg.qTemp = 32'h00A;
        DUT.R3.qTemp     = 32'h0;        // Change to 32'h1 for NOT TAKEN

        // ---- CASE 2: brnz R3, 48 ----
        // Memory[0x00B] = A9880030
        // TAKEN:     R3 = 32'h1       → CON_FF=1 → PC becomes 0x03C
        // NOT TAKEN: R3 = 32'h0       → CON_FF=0 → PC stays  0x00C
        // DUT.PC_reg.qTemp = 32'h00B;
        // DUT.R3.qTemp     = 32'h1;    // Change to 32'h0 for NOT TAKEN

        // ---- CASE 3: brpl R3, 48 ----
        // Memory[0x00C] = A9900030
        // TAKEN:     R3 = 32'h5       → CON_FF=1 → PC becomes 0x03D
        // NOT TAKEN: R3 = 32'h80000000→ CON_FF=0 → PC stays  0x00D
        // DUT.PC_reg.qTemp = 32'h00C;
        // DUT.R3.qTemp     = 32'h5;    // Change to 32'h80000000 for NOT TAKEN

        // ---- CASE 4: brmi R3, 48 ----
        // Memory[0x00D] = A9980030
        // TAKEN:     R3 = 32'h80000000→ CON_FF=1 → PC becomes 0x03E
        // NOT TAKEN: R3 = 32'h5       → CON_FF=0 → PC stays  0x00E
        // DUT.PC_reg.qTemp = 32'h00D;
        // DUT.R3.qTemp     = 32'h80000000; // Change to 32'h5 for NOT TAKEN

        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // ================================================================
    // State Transitions
    // ================================================================
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

    // ================================================================
    // State Outputs
    // ================================================================
    always @(Present_state) begin
        // Clear all control signals at the start of every state
        {PCin,IRin,HIin,LOin,ZHIin,Zin,MARin,MDRin,OUTPORT_In,Yin} <= 0;
        {PCout,HIout,LOout,ZHIout,Zout,INPORT_Out,MDRout,Cout}      <= 0;
        {Gra,Grb,Grc,Rin,Rout,BAout,Read,Write,IncPC,OUTPORT_Out}   <= 0;
        CON_In <= 0; CON_Out <= 0;
        alu_op <= 13'b0;

        case (Present_state)
            Default: begin
                // All zeroed above — nothing to do
            end

            // ----------------------------------------------------------
            // T0: Instruction Fetch
            //   PC → MAR, assert Read so RAM puts instruction on MDatain,
            //   MDRin latches it, IncPC bumps PC to PC+1
            // ----------------------------------------------------------
            T0: begin
                PCout <= 1; MARin <= 1; Read <= 1; MDRin <= 1; IncPC <= 1;
                #20;
                PCout <= 0; MARin <= 0; Read <= 0; MDRin <= 0; IncPC <= 0;
            end

            // ----------------------------------------------------------
            // T1: Instruction Decode
            //   MDR → IR so the control unit can see the opcode/operands
            // ----------------------------------------------------------
            T1: begin
                MDRout <= 1; IRin <= 1;
                #40;
                MDRout <= 0; IRin <= 0;
            end

            // ----------------------------------------------------------
            // T2: Settling — IR contents (opcode, Ra field) propagate
            //   to the control unit and sign-extender.  No bus activity.
            // ----------------------------------------------------------
            T2: begin
                // Intentionally empty
            end

            // ----------------------------------------------------------
            // T3: Read Ra (R3) onto bus → latch into CON FF
            //   Gra selects the register named in IR[26:23]
            //   CON_In tells the CON FF to sample the bus MSB (sign bit)
            //   and compare against the branch condition in IR[28:27]
            // ----------------------------------------------------------
            T3: begin
                Gra <= 1; Rout <= 1; CON_In <= 1;
                #40;
                Gra <= 0; Rout <= 0; CON_In <= 0;
            end

            // ----------------------------------------------------------
            // T4: PC+1 → Y
            //   PC was already incremented during T0 (IncPC), so Y now
            //   holds the "return / sequential" address
            // ----------------------------------------------------------
            T4: begin
                PCout <= 1; Yin <= 1;
                #40;
                PCout <= 0; Yin <= 0;
            end

            // ----------------------------------------------------------
            // T5: Z = Y + C  (branch target = PC+1 + sign-extended offset)
            //   Cout puts the sign-extended immediate (from IR[18:0]=48)
            //   on the bus; ALU adds it to Y; result latches into Z
            //   ADD opcode — adjust the bit pattern to match YOUR ALU
            // ----------------------------------------------------------
            T5: begin
                Cout <= 1; alu_op <= 13'b0000000000011; Zin <= 1;
                #40;
                Cout <= 0; alu_op <= 13'b0; Zin <= 0;
            end

            // ----------------------------------------------------------
            // T6: Conditionally update PC
            //   Zout drives the branch target onto the bus.
            //   PCin is gated by CON_Out (the stored CON FF value):
            //     CON_Out=1 → PCin=1 → PC ← branch target  (TAKEN)
            //     CON_Out=0 → PCin=0 → PC unchanged         (NOT TAKEN)
            // ----------------------------------------------------------
            T6: begin
                Zout <= 1; PCin <= CON_Out;
                #40;
                Zout <= 0; PCin <= 0;
            end

        endcase
    end

endmodule