# Constrain the 50MHz input clock
create_clock -period 20.0 -name CLOCK_50 [get_ports CLOCK_50]

# Constrain the divided clock (6.25 MHz = 160ns period)
create_generated_clock -name clk_divided \
    -source [get_ports CLOCK_50] \
    -divide_by 8 \
    [get_registers {frequency_divider:fd|clk_out}]

derive_clock_uncertainty