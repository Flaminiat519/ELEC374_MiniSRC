//RAM MODULE
module ram (
    input clk,
    input read,
    input write,
    input [8:0] address,   
    input [31:0] data_in,
    output wire [31:0] data_out
);
reg [31:0] mem [511:0];
integer i;                   

initial begin
    for (i = 0; i < 512; i = i + 1)
        mem[i] = 32'h0;
    $readmemh("C:/Users/flami/Documents/ELEC374_MiniSRC/ram.hex", mem); //ram.hex location on Flaminia's computer
	//$readmemh("C:/ELEC374_Repo/ELEC374_MiniSRC/ram.hex", mem); //ram.hex location on Duncan's computer
end

always @(posedge clk) begin
    if (write)
        mem[address] <= data_in;
end

assign data_out = read ? mem[address] : 32'bz;
endmodule

