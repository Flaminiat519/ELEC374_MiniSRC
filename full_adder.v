module full_adder (
    input xi,yi,c_in,
    output si,c_out //this output will be a wire 
);

assign si = xi ^ yi ^ c_in; //XOR to get correct output
assign c_out = (xi&yi) | (xi&c_in) | (yi&c_in); //equation to get carry out

endmodule

