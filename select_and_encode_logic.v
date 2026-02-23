module select_and_encode_logic (
	input [31:0] IR,
	input Gra, Grb, Grc, Rin, Rout, BAout,
	output [31:0] C,
	output [15:0] R_in, R_out //each bit corresponds to a reg
);

//Define IR feilds
wire [3:0] RA, RB, RC;
assign RA = IR[26:23];
assign RB = IR[22:19];
assign RC = IR[18:15];

//Sign extend C by fanning out the msb of the IR feild that relates to RC
assign C = {{13{IR[18]}}, {IR[18:0]}};

//Select which register feild to use
wire [3:0] Rsel = (RA & {4{Gra}}) | (RB & {4{Grb}}) | (RC & {4{Grc}});

//4-to-16 decoder
wire [15:0] dec;
assign dec = (16'b1 << Rsel);

	
//Gate decoder based of Rin and Rout
assign R_in = dec & {16{Rin}};
assign R_out = dec & {16{Rout}};

//Remember to implement BAout functionality later
endmodule