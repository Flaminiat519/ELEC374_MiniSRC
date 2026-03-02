//CONDITIONAL LOGIC MODULE
`timescale 1ns/10ps

module con_ff (
    input wire clk,
    input wire clear,
    input wire CONin,
    input wire [1:0] C2, //IR[20:19]
    input wire [31:0] Bus_Data,
    output reg CON
);

wire zero = (Bus_Data == 32'b0);
wire negative = Bus_Data[31];
wire positive = (~Bus_Data[31]) & (Bus_Data != 32'b0);

reg condition;

always @(*) begin
    case (C2)
        2'b00: condition = zero;      //brzr instruction
        2'b01: condition = ~zero;     //brnz instruction
        2'b10: condition = positive;  //brpl instruction
        2'b11: condition = negative;  //brmi instruction
    endcase
end

always @(posedge clk or posedge clear) begin
    if (clear)
        CON <= 1'b0;
    else if (CONin)
        CON <= condition;
end

endmodule
