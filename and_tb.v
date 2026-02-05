<<<<<<< Updated upstream
/*`timescale 1ns/10ps
module and_tb;

<<<<<<< Updated upstream
    reg clock;
=======
    // ---------------- Control signals ----------------
    reg Zlowout, MDRout, R5out, R6out;
    reg Zin, MDRin;
    reg AND;
    reg R2in, R5in, R6in;
    reg Clock;

    reg [31:0] Mdatain;

    // ---------------- FSM states ----------------
    parameter Default     = 4'b0000,
              Reg_load1a  = 4'b0001,
              Reg_load1b  = 4'b0010,
              Reg_load2a  = 4'b0011,
              Reg_load2b  = 4'b0100,
              T0          = 4'b0101,
              T1          = 4'b0110,
              T2          = 4'b0111,
              T3          = 4'b1000,
              T4          = 4'b1001;

    reg [3:0] Present_state = Default;

    // ---------------- DUT ----------------
    Datapath DUT (
        .Zlowout(Zlowout),
        .MDRout(MDRout),
        .R5out(R5out),
        .R6out(R6out),
        .Zin(Zin),
        .MDRin(MDRin),
        .AND(AND),
        .R2in(R2in),
        .R5in(R5in),
        .R6in(R6in),
        .Clock(Clock),
        .Mdatain(Mdatain)
    );

    // ---------------- Clock ----------------
>>>>>>> Stashed changes
    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

<<<<<<< Updated upstream
    reg R2in, R5in, R6in;
    reg R2out, R5out, R6out;
    reg Zin, Zout;
=======
`timescale 1ns/10ps
module and_tb; 	
	reg   R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
	reg 	PCin, IRin, HIin, LOin, ZHighin, ZLowin, MARin, MDRin, OutPort, Cin, Yin;
	reg   R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
	reg 	PCout, HIout, LOout, ZHighout, ZLowout, InPort, MDRout, MARout, Cout;
	reg	Clock, Clear;
	reg 	IncPC, Read;
	reg [12:0] ALU_op;
	reg	[31:0] Mdatain;

parameter	Default = 4'b0000, Reg_load1a= 4'b0001, Reg_load1b= 4'b0010,
					Reg_load2a= 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101,
					Reg_load3b = 4'b0110, T0= 4'b0111, T1= 4'b1000,T2= 4'b1001, T3= 4'b1010, T4= 4'b1011, T5= 4'b1100;
reg	[3:0] Present_state= Default;

initial Clear = 0;
>>>>>>> Stashed changes

data_path datapath_instance(
	Clock, Clear,
	R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
	PCin, IRin, HIin, LOin, ZHighin, ZLowin, MARin, MDRin, OutPort, Cin, Yin,
	R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
	PCout, HIout, LOout, ZHighout, ZLowout, InPort, MDRout, MARout, Cout,
	Read, Mdatain, IncPC
	);
	

initial 
	begin
		Clock = 0;
		forever #15 Clock = ~ Clock;
end

always @(posedge Clock)//finite state machine; if clock rising-edge
begin
	case (Present_state)
		Default			:	#40 Present_state = Reg_load1a;
		Reg_load1a		:	#40 Present_state = Reg_load1b;
		Reg_load1b		:	#40 Present_state = Reg_load2a;
		Reg_load2a		:	#40 Present_state = Reg_load2b;
		Reg_load2b		:	#40 Present_state = Reg_load3a;
		Reg_load3a		:	#40 Present_state = Reg_load3b;
		Reg_load3b		:	#40 Present_state = T0;
		T0					:	#40 Present_state = T1;
		T1					:	#40 Present_state = T2;
		T2					:	#40 Present_state = T3;
		T3					:	#40 Present_state = T4;
		T4					:	#40 Present_state = T5;
		endcase
	end

<<<<<<< Updated upstream
    register R5_reg (.clear(0),.clock(clock),.enable(R5in),.BusMuxOut(load_val),.BusMuxIn(R5));

    register R6_reg (.clear(0),.clock(clock),.enable(R6in),.BusMuxOut(load_val),.BusMuxIn(R6));

    register R2_reg (.clear(0),.clock(clock),.enable(R2in),.BusMuxOut(Bus),.BusMuxIn(R2));

    register Z_reg (.clear(0),.clock(clock),.enable(Zin),.BusMuxOut(ALU_Z[31:0]),.BusMuxIn(Zreg));

    ALU alu_inst (.RA(R5),.RB(R6),.ALU_op(ALU_op),.RZ(ALU_Z));

    Bus bus_inst (
        .RA(32'b0), .RB(32'b0), .R0(32'b0),.R1(32'b0), .R2(R2), .R3(32'b0), .R4(32'b0),
        .R5(R5), .R6(R6), .R7(32'b0),
        .R8(32'b0), .R9(32'b0), .R10(32'b0), .R11(32'b0),
        .R12(32'b0), .R13(32'b0), .R14(32'b0), .R15(32'b0),

        .HI(32'b0), .LO(32'b0), .Z(Zreg),
        .PC(32'b0), .MAR(32'b0), .MDR(32'b0),.IR(32'b0), .Y(32'b0),

        .RAout(0), .RBout(0), .R0out(0),.R1out(0), .R2out(R2out), .R3out(0), .R4out(0),
        .R5out(R5out), .R6out(R6out), .R7out(0),
        .R8out(0), .R9out(0), .R10out(0), .R11out(0),.R12out(0), .R13out(0), .R14out(0), .R15out(0),

        .HIout(0), .LOout(0), .Zout(Zout),
        .PCout(0), .MARout(0), .MDRout(0),
        .IRout(0), .Yout(0),

        .BusMuxOut(Bus)
    );

    initial begin
        //Init
=======
    // ---------------- FSM sequencing ----------------
    always @(posedge Clock) begin
        case (Present_state)
            Default    : Present_state <= Reg_load1a;
            Reg_load1a : Present_state <= Reg_load1b;
            Reg_load1b : Present_state <= Reg_load2a;
            Reg_load2a : Present_state <= Reg_load2b;
            Reg_load2b : Present_state <= T0;
            T0         : Present_state <= T1;
            T1         : Present_state <= T2;
            T2         : Present_state <= T3;
            T3         : Present_state <= T4;
        endcase
    end

    // ---------------- Control logic ----------------
    always @(Present_state) begin
        // -------- default deassert --------
        Zlowout = 0; MDRout = 0; R5out = 0; R6out = 0;
        Zin = 0; MDRin = 0;
        AND = 0;
>>>>>>> Stashed changes
        R2in = 0; R5in = 0; R6in = 0;
        Mdatain = 32'h00000000;

<<<<<<< Updated upstream
        //Load R5
        #20 load_val = 32'hF0F0F0F0; R5in = 1;
        #20 R5in = 0;

        //Load R6
        #20 load_val = 32'h0FF00FF0; R6in = 1;
        #20 R6in = 0;

        //AND operation
        #20 ALU_op[0] = 13'b1;//op code equivalent
        Zin = 1;
        #20 Zin = 0;

        //Move Z to r2
        #20 Zout = 1; R2in = 1;
        #20 Zout = 0; R2in = 0;

        #50 $finish;
=======
        case (Present_state)

        // -------- Load R5 = 0x34 --------
        Reg_load1a: begin
            Mdatain = 32'h00000034;
            MDRin   = 1;
        end

        Reg_load1b: begin
            MDRout = 1;
            R5in   = 1;
        end

        // -------- Load R6 = 0x45 --------
        Reg_load2a: begin
            Mdatain = 32'h00000045;
            MDRin   = 1;
        end

        Reg_load2b: begin
            MDRout = 1;
            R6in   = 1;
        end

        // -------- T0–T2: symbolic fetch (no-op) --------
        T0: begin end
        T1: begin end
        T2: begin end

        // -------- T3: AND execute --------
        T3: begin
            AND = 1;
            Zin = 1;
        end

        // -------- T4: writeback --------
        T4: begin
            Zlowout = 1;
            R2in    = 1;
        end

        endcase
>>>>>>> Stashed changes
    end

endmodule*/
=======
always @(Present_state)// do the required job ineach state
begin
	case (Present_state)              //assert the required signals in each clock cycle
		Default: begin
				{R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in} <= 0;
				{PCin, IRin, HIin, LOin, ZHighin, ZLowin, MARin, MDRin, OutPort, Cin, Yin} <= 0;
				{R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out} <= 0;
				{PCout, HIout, LOout, ZHighout, ZLowout, InPort, MDRout, MARout, Cout} <= 0;
				Read <= 0;   Mdatain <= 32'h00000000;   IncPC <= 0;   ALU_op <= 13'b0000000000000;   
		end
		Reg_load1a: begin 
				Mdatain<= 32'h00000012;
				Read = 0; MDRin = 0;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load1b: begin
				#10 MDRout<= 1; R2in <= 1;  
				#15 MDRout<= 0; R2in <= 0;     
		end
		Reg_load2a: begin 
				Mdatain <= 32'h00000014;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load2b: begin
				#10 MDRout<= 1; R3in <= 1;  
				#15 MDRout<= 0; R3in <= 0;
		end
		Reg_load3a: begin 
				Mdatain <= 32'h00000018;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load3b: begin
				#10 MDRout<= 1; R1in <= 1;  
				#15 MDRout<= 0; R1in <= 0;
		end
	
		T0: begin
				#10 PCout<= 1; MARin <= 1; IncPC <= 1;
				#10 PCout <= 0; MARin <= 0; IncPC <= 0;
		end
		T1: begin
				#10 PCin <= 1; Read <= 1; MDRin <= 1;
				Mdatain <= 32'h28918000;
				#10 PCin <= 0; Read <= 0; MDRin <= 0;
				
		end
		T2: begin
				#10 MDRout<= 1; IRin <= 1;  
				#10 MDRout<= 0; IRin <= 0; 
		end
		T3: begin
				#10 R2out<= 1; Yin <= 1;  
				#15 R2out<= 0; Yin <= 0;
		end
		T4: begin
				#10 R3out<= 1; ALU_op[0] = 13'b1; ZLowin <= 1; ZHighin <= 1;
				#15 R3out<= 0; ZLowin <= 0; ZHighin <= 0;
		end
		T5: begin
				#10 ZLowout<= 1; R1in <= 1; 
				#15 ZLowout<= 0; R1in <= 0;
		end
	endcase
end
endmodule
>>>>>>> Stashed changes
