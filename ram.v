module ram (
    input clk,
    input read,
    input write,
    input [8:0] address,   
    input [31:0] data_in,
    output reg [31:0] data_out
);
reg [31:0] mem [511:0];
integer i;                    // moved here, outside initial block

initial begin
    for (i = 0; i < 512; i = i + 1)
        mem[i] = 32'h0;
    mem[9'h065] = 32'h00000084;
    mem[9'h0C9] = 32'h0000002B;
    mem[9'h01F] = 32'h000000D4;
    mem[9'h082] = 32'h000000A7;
    $readmemh("C:/Users/flami/Documents/ELEC374_MiniSRC/ram.hex", mem);
end

always @(posedge clk) begin
    if (write)
        mem[address] <= data_in;
    if (read)
        data_out <= mem[address];
end
endmodule