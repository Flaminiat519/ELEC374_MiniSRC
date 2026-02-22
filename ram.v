module memory (
    input clk,
    input read,
    input write,
    input [15:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    // 256 words of 32-bit memory (you can adjust size)
    reg [31:0] mem [0:255];

    always @(posedge clk) begin
        if (write) begin
            mem[address] <= data_in;
        end
        if (read) begin
            data_out <= mem[address];
        end
    end

endmodule
