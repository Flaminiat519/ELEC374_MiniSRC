//Register Module for PC, IR, Y, Z, MAR, HI and LO, and R0..R15

module register #(
  parameter DATA_WIDTH_IN  = 32,
  parameter DATA_WIDTH_OUT = 32,
  parameter INIT           = 32'h0
)(
  input  wire                     clear,
  input  wire                     clock,
  input  wire                     enable,
  input  wire [DATA_WIDTH_IN-1:0]  BusMuxIn,     // <-- input
  output wire [DATA_WIDTH_OUT-1:0] BusMuxOut     // <-- output
);

  reg [DATA_WIDTH_IN-1:0] q;
  initial q = INIT;

  always @(posedge clock) begin
    if (clear)       q <= {DATA_WIDTH_IN{1'b0}};
    else if (enable) q <= BusMuxIn;
  end

  assign BusMuxOut = q[DATA_WIDTH_OUT-1:0];

endmodule

