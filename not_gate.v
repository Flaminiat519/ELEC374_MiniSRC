module not_gate(
    input [31:0] x,
    output [31:0] z
);
assign z = ~x; //NOT operation
endmodule
