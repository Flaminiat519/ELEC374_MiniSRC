//Select and encode logic — decodes IR register fields into register file enable signals
module select_and_encode_logic (
	input [31:0] IR,
	input Gra, Grb, Grc, Rin, Rout, BAout,
	output [31:0] C,
	output [15:0] R_in, R_out //One bit per register
);
	//Extract register select fields from IR
	wire [3:0] RA, RB, RC;
	assign RA = IR[26:23];
	assign RB = IR[22:19];
	assign RC = IR[18:15];

	//Sign-extend the immediate constant field from IR[18:0]
	assign C = {{13{IR[18]}}, {IR[18:0]}};

	//Select which register field is active based on Gra/Grb/Grc
	wire [3:0] Rsel = (RA & {4{Gra}}) | (RB & {4{Grb}}) | (RC & {4{Grc}});

	//4-to-16 one-hot decoder
	wire [15:0] dec;
	assign dec = (16'b1 << Rsel);

	//Gate decoder output with Rin/Rout to drive register enables
	assign R_in  = dec & {16{Rin}};
	assign R_out = dec & {16{Rout | BAout}};
endmodule
