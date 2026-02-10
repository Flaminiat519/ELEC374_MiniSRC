//Multiply test bench
`timescale 1ns/10ps
module datapath_tb_mul;

    reg clock, clear;

    reg R0in, RAin, RBin, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;

    reg R0out, RAout, RBout, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;

    reg HIin, HIout, LOin, LOout, Zin, Zout, ZHIin, ZHIout;
    reg PCin, PCout, MARin, MARout, MDRin, MDRout, IRin, IRout, Yin, Yout;

    reg IncPC, Read;
    reg [31:0] MDatain;

    wire [31:0] BusMuxOut;

    //FSM states
    parameter Default=4'b0000, L1a=4'b0001, L1b=4'b0010, L2a=4'b0011, L2b=4'b0100;
    parameter T0=4'b0101, T1=4'b0110, T2=4'b0111, T3=4'b1000, T4=4'b1001, T5=4'b1010, T6=4'b1011, T7=4'b1100;
    reg [3:0] Present_state = Default;

    //DUT initialization
    data_path DUT(
        .clock(clock), .clear(clear),
        .R0in(R0in), .RAin(RAin), .RBin(RBin), .R1in(R1in), .R2in(R2in), .R3in(R3in),
        .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in), .R8in(R8in), .R9in(R9in),
        .R10in(R10in), .R11in(R11in), .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .R0out(R0out), .RAout(RAout), .RBout(RBout), .R1out(R1out), .R2out(R2out),
        .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
        .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIin(HIin), .HIout(HIout), .LOin(LOin), .LOout(LOout),
        .Zin(Zin), .Zout(Zout), .ZHIin(ZHIin), .ZHIout(ZHIout),
        .PCin(PCin), .PCout(PCout), .MARin(MARin), .MARout(MARout),
        .MDRin(MDRin), .MDRout(MDRout),
        .IRin(IRin), .IRout(IRout),
        .Yin(Yin), .Yout(Yout),
        .IncPC(IncPC), .Read(Read),
        .MDatain(MDatain),
        .BusMuxOut(BusMuxOut)
    );

    //Clock start
    initial begin
        clock = 0;
        forever #20 clock = ~clock;
    end

    //task to deassert all signals
    task deassert_all; begin
        {R0in,RAin,RBin,R1in,R2in,R3in,R4in,R5in,R6in,R7in,R8in,R9in,R10in,R11in,R12in,R13in,R14in,R15in} = 0;
        {R0out,RAout,RBout,R1out,R2out,R3out,R4out,R5out,R6out,R7out,R8out,R9out,R10out,R11out,R12out,R13out,R14out,R15out} = 0;
        {HIin,HIout,LOin,LOout,Zin,Zout,ZHIin,ZHIout,PCin,PCout,MARin,MARout,MDRin,MDRout,IRin,IRout,Yin,Yout,IncPC,Read} = 0;
    end endtask

    //FSM
    always @(posedge clock) begin
        if(clear) Present_state <= Default;
        else case(Present_state)
            Default: Present_state <= L1a;
            L1a: Present_state <= L1b;
            L1b: Present_state <= L2a;
            L2a: Present_state <= L2b;
            L2b: Present_state <= T0;
            T0: Present_state <= T1;
            T1: Present_state <= T2;
            T2: Present_state <= T3;
            T3: Present_state <= T4;
            T4: Present_state <= T5;
            T5: Present_state <= T6;
            T6: Present_state <= T7;
            T7: Present_state <= T7; 
        endcase
    end

    //Control logic
    always @(Present_state) begin
        deassert_all();
        case(Present_state)
          
            L1a: begin 
                MDatain <= 32'h12345678; Read <= 1; MDRin <= 1; 
            end
            
            L1b: begin 
                MDRout <= 1; R3in <= 1; 
            end
         
            L2a: begin 
                MDatain <= 32'h10000000; Read <= 1; MDRin <= 1; 
            end
            
            L2b: begin 
                MDRout <= 1; R1in <= 1; 
            end
            
            T0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            
            T1: begin
                Zout <= 1; //PCin <= 1;
                Read <= 1; MDRin <= 1;
                MDatain <= 32'b01101000000000000000000000000000;
            end
            
            T2: begin
                MDRout <= 1; IRin <= 1;
            end

            T3: begin 
                R3out <= 1; 
                Yin <= 1; 
            end

            T4: begin
                R1out <= 1;
                Zin <= 1;
                ZHIin <= 1;
                //perform multiplication
                force DUT.alu_op = (13'b1 << 6);
            end
            
            T5: begin
                Zout <= 1;
                LOin <= 1;
            end

            T6: begin
                ZHIout <= 1;
                HIin <= 1;
                release DUT.alu_op;
            end
            
            //observe final values
            T7: begin
            end
        endcase
    end
    
    //clear
    initial begin
        clear = 1; #20 clear = 0;
        #500; 
        
        $finish;
    end

endmodule
