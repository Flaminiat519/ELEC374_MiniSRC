// Non-Restoring Division Algorithm
module div #(parameter n = 32)(
    input  [n - 1:0] dividend, divisor,
    output reg [n - 1:0] remainder, quotient
);

    reg signed [n:0] A;      // remainder
    reg [n-1:0] Q;           // quotient
    reg [n-1:0] M;           // divisor
    integer i;

    always @(*) begin
        A = 0;               // Set A to 0
        Q = dividend;
        M = divisor;
        
        for (i = 0; i < n; i = i + 1) begin
            // Shift A and Q left by 1 bit
            {A, Q} = {A, Q} << 1;

            if (A >= 0) begin        // if A is positive, subtract M
                A = A - M;
            end else begin           // if A is negative, add M
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
