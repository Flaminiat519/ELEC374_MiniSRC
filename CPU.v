`timescale 1ns/10ps

module CPU(
	input wire Clock, Reset, Stop,
	input wire [31:0] Inport,
	output wire [31:0] Outport,
	output wire Halted,
	output wire [31:0] BusMuxOut
);

	wire PCin, IRin, HIin, LOin, ZHIin, Zin, MARin, MDRin, OUTPORT_In, Yin;
	wire PCout, HIout, LOout, ZHIout, Zout, INPORT_Out, MDRout, Cout;
	wire Gra, Grb, Grc, Rin, Rout, BAout, Read, Write, IncPC;
    wire CON_In, CON_Out, OUTPORT_Out;
	wire [12:0] alu_op;
	wire [31:0] IR_out;
	
	control_unit con(  
		.PCin(PCin), .IRin(IRin), .HIin(HIin), .LOin(LOin),
        .ZHIin(ZHIin), .Zin(Zin), .MARin(MARin), .MDRin(MDRin),
        .OUTPORT_In(OUTPORT_In), .Yin(Yin),
        .PCout(PCout), .HIout(HIout), .LOout(LOout), .ZHIout(ZHIout),
        .Zout(Zout), .INPORT_Out(INPORT_Out), .MDRout(MDRout), .Cout(Cout),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout),
        .BAout(BAout), .Read(Read), .Write(Write), .IncPC(IncPC),
        .CON_In(CON_In), .CON_Out(CON_Out), .OUTPORT_Out(OUTPORT_Out),
        .alu_op(alu_op),
        .IR(IR_out),   // IR fed from datapath bus
        .Clock(Clock), .Reset(Reset), .Stop(Stop), .halted(Halted)
	);
	
	data_path dp(
		.clock(Clock), .clear(Reset),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .HIin(HIin), .HIout(HIout), .LOin(LOin), .LOout(LOout),
        .Zin(Zin), .Zout(Zout), .ZHIout(ZHIout), .ZHIin(ZHIin),
        .PCin(PCin), .PCout(PCout),
        .MARin(MARin), .MARout(1'b0),
        .MDRin(MDRin), .MDRout(MDRout),
        .IRin(IRin), .IRout(1'b0),
        .Yin(Yin), .Yout(1'b0),
        .OUTPORT_In(OUTPORT_In), .INPORT_Out(INPORT_Out), .OUTPORT_Out(OUTPORT_Out),
        .Cout(Cout), .IncPC(IncPC),
        .Read(Read), .Write(Write),
		.Inport(Inport),
		.Outport(Outport),
        .MDatain(32'b0),
        .BusMuxOut(BusMuxOut),
        .CON_In(CON_In), .CON_Out(CON_Out),
        .alu_op(alu_op), .IR_out(IR_out)
	);
	
endmodule