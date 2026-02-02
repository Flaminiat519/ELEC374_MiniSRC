module negate(
    input [31:0] x,
    output [31:0] z
);
assign z = ~x + 1; //Negate operation
endmodule
