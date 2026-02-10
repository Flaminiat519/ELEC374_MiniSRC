//NEGATE operation module
module negate(
    //wire initialization
    input [31:0] x,
    output [31:0] z
);
//Negate operation
assign z = ~x + 1; 
endmodule
