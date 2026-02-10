//NOT operation module
module not_gate(
    //start wires
    input [31:0] x,
    output [31:0] z
);
//NOT operation
assign z = ~x; 
endmodule
