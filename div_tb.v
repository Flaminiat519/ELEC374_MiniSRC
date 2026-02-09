`timescale 1ns/1ps

module div_tb;

    parameter n = 32;

    reg  [n-1:0] dividend;
    reg  [n-1:0] divisor;

    wire [n-1:0] quotient;
    wire [n-1:0] remainder;

    // Instantiate divider
    div #(n) DUT (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    // signed expected values
    integer exp_q;
    integer exp_r;

    task run_test;
        input [n-1:0] a;
        input [n-1:0] b;
        begin
            dividend = a;
            divisor  = b;
            #10;

            // avoid divide by zero
            if (b == 0) begin
                $display("SKIP: dividend=%h divisor=%h (divide by zero)", a, b);
            end else begin
                exp_q = $signed(a) / $signed(b);
                exp_r = $signed(a) % $signed(b);

                if (($signed(quotient) !== exp_q) || ($signed(remainder) !== exp_r)) begin
                    $display("FAIL: dividend=%h divisor=%h | got Q=%h R=%h | exp Q=%h R=%h",
                              a, b, quotient, remainder, exp_q, exp_r);
                end else begin
                    $display("PASS: dividend=%h divisor=%h | Q=%h R=%h",
                              a, b, quotient, remainder);
                end
            end
        end
    endtask


    initial begin
        $display("==== Starting Division Tests ====");

        // Basic tests
        run_test(32'd100, 32'd3);
        run_test(32'd100, 32'd10);
        run_test(32'd25,  32'd5);
        run_test(32'd7,   32'd2);

        // Edge-ish tests
        run_test(32'd0,   32'd5);
        run_test(32'd1,   32'd1);
        run_test(32'd32,  32'd7);

        // Signed tests
        run_test(-32'sd100, 32'sd3);
        run_test(32'sd100, -32'sd3);
        run_test(-32'sd100, -32'sd3);

        // Large hex patterns
        run_test(32'hF0F0F0F0, 32'd7);
        run_test(32'h80000000, 32'd2);
        run_test(32'h7FFFFFFF, 32'd11);

        // Random-ish
        run_test(32'h12345678, 32'h00001234);
        run_test(32'h89ABCDEF, 32'd9);

        $display("==== Tests Finished ====");
        $stop;
    end

endmodule
