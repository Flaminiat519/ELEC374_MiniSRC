//Handles Reset.In and Stop.In signals from DE0-CV push buttons
//DE0-CV push buttons are active-LOW (pressing = 0, released = 1)
//Pin assignments (Table 3.2):
//KEY0 = PIN_U7  -> Reset.In
//KEY1 = PIN_W9  -> Stop.In

module push_button (
    input  wire key0,           //KEY0 (PIN_U7)  – active-low Reset
    input  wire key1,           //KEY1 (PIN_W9)  – active-low Stop
    output wire reset_in,       //Reset.In to CPU – active-high
    output wire stop_in         //Stop.In to CPU  – active-high
);

    //Invert active-low button signals to active-high for the CPU
    assign reset_in = ~key0;
    assign stop_in  = ~key1;

endmodule