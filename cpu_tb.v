`timescale 1ns/10ps

module cpu_tb;

    reg        Clock;
    reg        Reset;
    reg        Stop;
    wire [31:0] BusMuxOut;

    // Instantiate CPU (no MDatain needed)
    CPU DUT (
        .Clock(Clock),
        .Reset(Reset),
        .Stop(Stop),
        .BusMuxOut(BusMuxOut)
    );

    // 10ns clock
    initial Clock = 0;
    always #5 Clock = ~Clock;

    // Waveform dump
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end

    // -------------------------------------------------------
    // Helper: wait N clock cycles then print state
    // -------------------------------------------------------
    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge Clock);
            #1; // small delta after edge to read stable values
        end
    endtask

    // -------------------------------------------------------
    // Helper: print current CPU state
    // -------------------------------------------------------
    task print_state;
        input [255:0] label;
        begin
            $display("[%0t] %s", $time, label);
            $display("  PC=%h  IR=%h  Bus=%h",
                DUT.dp.PC,
                DUT.dp.IR,
                BusMuxOut);
            $display("  R0=%h R1=%h R2=%h R3=%h",
                DUT.dp.R0, DUT.dp.R1, DUT.dp.R2, DUT.dp.R3);
            $display("  R4=%h R5=%h R6=%h R7=%h",
                DUT.dp.R4, DUT.dp.R5, DUT.dp.R6, DUT.dp.R7);
            $display("  HI=%h  LO=%h",
                DUT.dp.HI, DUT.dp.LO);
            $display("");
        end
    endtask

    // -------------------------------------------------------
    // Reset task
    // -------------------------------------------------------
    task do_reset;
        begin
            Reset = 1; Stop = 0;
            @(posedge Clock); #1;
            Reset = 0;
            $display("[%0t] === Reset Released ===\n", $time);
        end
    endtask

    // -------------------------------------------------------
    // Main test
    // -------------------------------------------------------
    // Cycle counts per instruction type (fetch=3 + execute):
    //   LDI:   3+5 = 8  cycles
    //   LD:    3+8 = 11 cycles
    //   ST:    3+8 = 11 cycles
    //   ADDI:  3+5 = 8  cycles
    //   ANDI:  3+5 = 8  cycles
    //   ORI:   3+5 = 8  cycles
    //   BRANCH:3+6 = 9  cycles
    //   MFHI:  3+3 = 6  cycles
    //   MFLO:  3+3 = 6  cycles
    //   JAL:   3+4 = 7  cycles
    //   JR:    3+1 = 4  cycles
    //   IN/OUT:3+? = ~8 cycles (check your CU states)
    // -------------------------------------------------------

    initial begin
        $display("======================================");
        $display("        CPU Testbench Start           ");
        $display("======================================\n");

        do_reset;

        // --------------------------------------------------
        // @000: ldi R7, 0x65
        // R7 should become 0x00000065
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@000 LDI R7, 0x65 -- expect R7=0x00000065");

        // --------------------------------------------------
        // @001: ldi R0, 0x72(R2)  (R2=0, so addr=0x72, R0=sign_ext(0x72))
        // R0 should become 0x00000072
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@001 LDI R0, 0x72(R2) -- expect R0=0x00000072");

        // --------------------------------------------------
        // @002: ld R7, 0x65  (loads mem[0x65]=0x84 into R7)
        // R7 should become 0x00000084
        // --------------------------------------------------
        wait_cycles(11);
        print_state("@002 LD R7, 0x65 -- expect R7=0x00000084");

        // --------------------------------------------------
        // @003: ld R0, 0x72(R2)  (R2=0, mem[0x72] -- check what's there)
        // R0 = mem[0x72] (likely 0 unless written)
        // --------------------------------------------------
        wait_cycles(11);
        print_state("@003 LD R0, 0x72(R2) -- expect R0=mem[0x72]");

        // --------------------------------------------------
        // @004: st 0x1F, R6  (store R6 into mem[0x1F])
        // mem[0x1F] was 0xD4, now should be R6's value (0 after reset)
        // --------------------------------------------------
        wait_cycles(11);
        print_state("@004 ST 0x1F, R6 -- mem[0x1F] should now = R6");
        $display("  mem[0x1F] = %h (expect R6 value)\n",
            DUT.dp.RAM.mem[8'h1F]);

        // --------------------------------------------------
        // @005: st 0x1F(R6), R6  (R6=0, so same address 0x1F)
        // --------------------------------------------------
        wait_cycles(11);
        print_state("@005 ST 0x1F(R6), R6 -- mem[0x1F] = R6 again");
        $display("  mem[0x1F] = %h\n", DUT.dp.RAM.mem[8'h1F]);

        // --------------------------------------------------
        // @006: addi R7, R4, -9  (R4=0, so R7 = 0 + (-9) = 0xFFFFFFF7)
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@006 ADDI R7, R4, -9 -- expect R7=0xFFFFFFF7");

        // --------------------------------------------------
        // @007: addi R7, R4, 0x71  (R4=0, R7 = 0x71)
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@007 ADDI R7, R4, 0x71 -- expect R7=0x00000071");

        // --------------------------------------------------
        // @008: andi R7, R4, 0x71  (R4=0, R7 = 0 & 0x71 = 0)
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@008 ANDI R7, R4, 0x71 -- expect R7=0x00000000");

        // --------------------------------------------------
        // @009: ori R7, R4, 0x71  (R4=0, R7 = 0 | 0x71 = 0x71)
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@009 ORI R7, R4, 0x71 -- expect R7=0x00000071");

        // --------------------------------------------------
        // @00A: brzr R3, 48  (R3=0 so branch taken, PC += 48)
        // --------------------------------------------------
        wait_cycles(9);
        print_state("@00A BRZR R3, 48 -- R3=0 so branch TAKEN, expect PC jump");

        // --------------------------------------------------
        // @00B: brnz R3, 48  (R3=0 so branch NOT taken)
        // --------------------------------------------------
        wait_cycles(9);
        print_state("@00B BRNZ R3, 48 -- R3=0 so branch NOT taken");

        // --------------------------------------------------
        // @00C: brpl R3, 48  (R3=0, not positive so NOT taken)
        // --------------------------------------------------
        wait_cycles(9);
        print_state("@00C BRPL R3, 48 -- R3=0 not positive, NOT taken");

        // --------------------------------------------------
        // @00D: brmi R3, 48  (R3=0, not negative so NOT taken)
        // --------------------------------------------------
        wait_cycles(9);
        print_state("@00D BRMI R3, 48 -- R3=0 not negative, NOT taken");

        // --------------------------------------------------
        // @00E: mfhi R5  (R5 = HI register)
        // --------------------------------------------------
        wait_cycles(6);
        print_state("@00E MFHI R5 -- expect R5=HI");

        // --------------------------------------------------
        // @00F: jal R4  (R15=PC, PC=R4)
        // --------------------------------------------------
        wait_cycles(7);
        print_state("@00F JAL R4 -- expect R15=return addr, PC=R4(=0)");

        // --------------------------------------------------
        // @010: jr R12  (PC = R12, likely 0 after reset)
        // --------------------------------------------------
        wait_cycles(4);
        print_state("@010 JR R12 -- expect PC=R12");

        // --------------------------------------------------
        // @011: mflo R1  (R1 = LO register)
        // --------------------------------------------------
        wait_cycles(6);
        print_state("@011 MFLO R1 -- expect R1=LO");

        // --------------------------------------------------
        // @012: in R5
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@012 IN R5");

        // --------------------------------------------------
        // @013: out R7
        // --------------------------------------------------
        wait_cycles(8);
        print_state("@013 OUT R7");

        $display("======================================");
        $display("        Testbench Complete            ");
        $display("======================================");
        $finish;
    end

    // Watchdog
    initial begin
        #50000;
        $display("TIMEOUT - simulation ran too long");
        $finish;
    end

endmodule