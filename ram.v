module ram (
    input clk,
    input read,
    input write,
    input [8:0] address,   
    input [31:0] data_in,
    output reg [31:0] data_out
);

reg [31:0] mem [511:0];

initial begin
    $readmemh("ram.hex", mem);
end

always @(posedge clk) begin
    if (write)
        mem[address] <= data_in;

    if (read)
        data_out <= mem[address];
end

endmodule

/*always @(*) begin
    if (read)
        data_out = mem[address];
end*/

//only ld and st use RAM