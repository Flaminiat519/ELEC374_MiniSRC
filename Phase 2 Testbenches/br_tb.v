`timescale 1ns/10ps
module br_tb;
    reg         Clock, Clear;
    reg         PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
    reg         PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
    reg         Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    reg         CON_In, CON_Out, OUTPORT_Out;
    reg [12:0]  alu_op;
    wire [31:0] BusMuxOut;
    wire [31:0] ram_data_out;

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
        .MDatain(ram_data_out),  // RAM output feeds MDR
        .alu_op(alu_op),
        .CON_In(CON_In), .CON_Out(CON_Out),
        .BusMuxOut(BusMuxOut)
    );

    // RAM instantiated here so we can wire address from MAR directly
    ram RAM (
        .clk(Clock),
        .read(Read),
        .write(Write),
        .address(DUT.MAR_reg.q[8:0]),  // MAR internal q
        .data_in(BusMuxOut),
        .data_out(ram_data_out)
    );

    // Clock: 100ns period
    initial begin
        Clock = 0;
        forever #50 Clock = ~Clock;
    end

    initial begin
        #1;
        $display("=== BRANCH TESTBENCH START ===");
        $display("Testing CASE 1: brzr R3, 48 — TAKEN when R3 == 0");
        $display("Expected final PC: 0x03B (taken) or 0x00B (not taken)");
        $display("----------------------------------------------");

        // ============================================================
        // CASE 1: brzr R3, 48 — TAKEN when R3 == 0
        //   RAM @00A = A9800030, target = 0x00A+1+48 = 0x03B
        //   To test NOT TAKEN: set R3 to 32'h1 instead
        DUT.PC_reg.qTemp = 32'h00A;   // PC internal reg
        DUT.R3_reg.q = 32'h0;     // R3 internal reg

        // ============================================================
        // CASE 2: brnz R3, 48 — TAKEN when R3 != 0
        // DUT.PC_reg.q = 32'h00B;
        // DUT.R3_reg.q = 32'h1;

        // ============================================================
        // CASE 3: brpl R3, 48 — TAKEN when R3 >= 0
        // DUT.PC_reg.q = 32'h00C;
        // DUT.R3_reg.q = 32'h5;

        // ============================================================
        // CASE 4: brmi R3, 48 — TAKEN when R3 < 0
        // DUT.PC_reg.q = 32'h00D;
        // DUT.R3_reg.q = 32'h80000000;

        $display("[INIT] PC  = %h", DUT.PC_reg.q);
        $display("[INIT] R3  = %h", DUT.R3_reg.q);
        $display("[INIT] Checking RAM contents around fetch address:");
        $display("  RAM[009] = %h", RAM.mem[9'h009]);
        $display("  RAM[00A] = %h  <-- should be A9800030 for brzr", RAM.mem[9'h00A]);
        $display("  RAM[00B] = %h", RAM.mem[9'h00B]);
        $display("  RAM[00C] = %h", RAM.mem[9'h00C]);
        $display("  RAM[00D] = %h", RAM.mem[9'h00D]);
    end

    // Print diagnostics every rising clock edge
    always @(posedge Clock) begin
        #1;
        $display("t=%0t | state=%0d | MAR=%h | MDR=%h | IR=%h | PC=%h | R3=%h | CON=%b | RAM_out=%h | Read=%b | MDRin=%b",
            $time,
            Present_state,
            DUT.MAR_reg.q,
            DUT.MDR_reg.mdr.q,   // MDR's internal register q
            DUT.IR_reg.q,
            DUT.PC_reg.q,
            DUT.R3_reg.q,
            DUT.CON,
            ram_data_out,
            Read,
            MDRin
        );
    end

    // State entry messages
    always @(Present_state) begin
        case (Present_state)
            T0: $display("\n--- T0: PC->MAR, IncPC ---");
            T1: $display("\n--- T1: Read=1, MDRin=1 (RAM latches on next posedge) ---");
            T2: $display("\n--- T2: MDRout->IR ---");
            T3: $display("\n--- T3: R3->bus, latch CON FF ---");
            T4: $display("\n--- T4: PC->Y ---");
            T5: $display("\n--- T5: Y+imm->Z ---");
            T6: begin
                $display("\n--- T6: if CON==1, Z->PC ---");
                #15;
                $display("[T6] CON=%b | Z=%h", DUT.CON, DUT.Z_reg.q);
            end
        endcase
    end

    // Final result after T6 completes
    always @(Present_state) begin
        if (Present_state == T6) begin
            #250;
            $display("\n=== FINAL RESULTS ===");
            $display("PC  = %h", DUT.PC_reg.q);
            $display("IR  = %h", DUT.IR_reg.q);
            $display("CON = %b", DUT.CON);
            $display("Expected PC: 03B (taken) or 00B (not taken)");
            if      (DUT.PC_reg.q == 32'h03B) $display(">>> PASS: Branch TAKEN,     PC=03B <<<");
            else if (DUT.PC_reg.q == 32'h00B) $display(">>> PASS: Branch NOT TAKEN, PC=00B <<<");
            else                              $display(">>> FAIL: PC=%h (unexpected) <<<", DUT.PC_reg.q);
            $display("=====================");
            $finish;
        end
    end

    // State Transitions
    always @(posedge Clock) begin
        case (Present_state)
            Default : Present_state = T0;
            T0      : #200 Present_state = T1;
            T1      : #200 Present_state = T2;
            T2      : #200 Present_state = T3;
            T3      : #200 Present_state = T4;
            T4      : #200 Present_state = T5;
            T5      : #200 Present_state = T6;
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

            T0: begin
                #10 PCout <= 1; MARin <= 1; IncPC <= 1;
                #100 PCout <= 0; MARin <= 0; IncPC <= 0;
            end

            T1: begin
                #10 Read <= 1; MDRin <= 1;
                #100 Read <= 0; MDRin <= 0;
            end

            T2: begin
                #10 MDRout <= 1; IRin <= 1;
                #100 MDRout <= 0; IRin <= 0;
            end

            T3: begin
                #10 Gra <= 1; Rout <= 1; CON_In <= 1;
                #100 Gra <= 0; Rout <= 0; CON_In <= 0;
            end

            T4: begin
                #10 PCout <= 1; Yin <= 1;
                #100 PCout <= 0; Yin <= 0;
            end

            T5: begin
                #10 Cout <= 1; alu_op <= 13'b0000000010000; Zin <= 1;
                #100 Cout <= 0; alu_op <= 13'b0; Zin <= 0;
            end

            T6: begin
                #10 Zout <= 1; PCin <= DUT.CON;
                #100 Zout <= 0; PCin <= 0;
            end

        endcase
    end

endmodule