//MDR multiplexer module
`timescale 1ns/10ps

module mdr_mux (
    input wire [31:0] BusMuxOut,
    input wire Read,
    input wire [31:0] MDAtain,
    output reg [31:0] Q
);
    always @(*) begin
        if (Read) 
            Q = MDAtain;
        else
            Q = BusMuxOut;
    end
endmodule
