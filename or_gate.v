//OR gate module
module or_gate(
    //start wires
    input [31:0] x,y,
    output [31:0] z
);
    //OR operation
    assign z = x|y; 
endmodule
