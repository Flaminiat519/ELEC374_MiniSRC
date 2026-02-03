// Non-Restoring Division Algorithm
module div #(parameter n = 32)(
    //define 32-bit input and output
    input  [n - 1:0] dividend, divisor,
    output reg [n - 1:0] remainder, quotient
);

    //define intermediate register for the remainder
    reg signed [n:0] A;
    //define intermediate register for the quotient
    reg [n-1:0] Q;  
    //define intermediate register for the divisor
    reg [n-1:0] M;    
    integer i;

    //use always statement to compute the algorithm
    always @(*) begin
        //set A register to 0
        A = 0;               
        //set Q to the dividend input
        Q = dividend;
        //set M to the divisor input
        M = divisor;

        for (i = 0; i < n; i = i + 1) begin
            // Shift A and Q left by 1 bit
            {A, Q} = {A, Q} << 1;

            // if A is positive, subtract M
            if (A >= 0) begin        
                A = A - M;
            // if A is negative, add M
            end else begin           
                A = A + M;
            end
            
            // Set quotient bit based on sign of A
            if (A >= 0) begin
                Q[0] = 1'b1;
            end else begin
                Q[0] = 1'b0;
            end
        end
        
        // Final restore if A is negative
        if (A < 0) begin
            A = A + M;
        end
        
        quotient  = Q;
        remainder = A[n-1:0];
    end
endmodule
