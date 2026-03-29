//Drives LEDR5 (PIN_N1) as the Run.Out signal
//LED is ON  when CPU is running (run = 1)
//LED is OFF when CPU is halted  (run = 0)
//DE0-CV LEDs are active-high

module led_indicator (
    input  wire run,        //Run.Out signal from CPU (1 = running, 0 = halted)
    output wire ledr5       //Connected to LEDR5, PIN_N1
);

    assign ledr5 = run;

endmodule