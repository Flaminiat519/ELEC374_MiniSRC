//32-bit and gate module
module and_gate (
    //define 32-bit inputs and output
    input [31:0] x,y,
    output [31:0] z
);
//AND operation
assign z = x & y; 
    
endmodule 
