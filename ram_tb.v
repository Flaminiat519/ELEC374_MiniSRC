`timescale 1ns/10ps

module ram_tb;

    reg clk;
    reg read;
    reg write;
    reg [15:0] address;
    reg [31:0] data_in;
    wire [31:0] data_out;

    memory uut (
        .clk(clk),
        .read(read),
        .write(write),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        read = 0;
        write = 0;
        address = 0;
        data_in = 0;

        // WAIT
        #10;

        // WRITE 0xAAAA5555 to address 10
        address = 10;
        data_in = 32'hAAAA5555;
        write = 1;
        #10;
        write = 0;

        // READ from address 10
        read = 1;
        #10;
        read = 0;

        // Check result
        #5;
        $display("Data read = %h", data_out);

        #20;
        $stop;
    end

endmodule
