//Reads SW0–SW7 into the lower 8 bits of the 32-bit In.Port
//Upper 24 bits are always 0 as per spec
//DE0-CV pin assignments (Table 3.3):
//SW0 = PIN_U13, SW1 = PIN_V13, SW2 = PIN_T13, SW3 = PIN_T12
//SW4 = PIN_AA15, SW5 = PIN_AB15, SW6 = PIN_AA14, SW7 = PIN_AA13

module switch_input (
    input  wire [7:0]  sw,          //SW[7:0] physical slide switches
    output wire [31:0] in_port      //32-bit In.Port to CPU
);

    //Lower 8 bits come from switches; upper 24 bits are hardwired to 0
    assign in_port = {24'b0, sw[7:0]};

endmodule