/*// Non-Restoring Division Algorithm
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
        A = 32'b0;               
        //set Q to the dividend input
        Q = dividend;

        //set M to the divisor input
        //check if negative
        if (divisor[31]) 
            M = -divisor; 
        else
            M = divisor;
		
		if (dividend[31]) 
            Q = -dividend; 
        else
            Q = dividend;

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
		//check if divisor is negative
        //if so, 2s comp the result
        if (divisor[31]) begin
            quotient = -quotient;
        end
		if (dividend[31]) begin
			quotient = -quotient;
			remainder = -remainder;
		end
    end
endmodule*/

module div #(parameter n = 32)(
    input  [n-1:0] RA,   // dividend
    input  [n-1:0] RB,   // divisor
    output reg [n-1:0] remainder, 
    output reg [n-1:0] quotient
);
    reg signed [n:0] A;
    reg [n-1:0] Q;
    reg [n-1:0] M;
    integer i;

    always @(*) begin
        A = 0;
        Q = RA;
        M = RB;

        for (i = 0; i < n; i = i + 1) begin
            {A, Q} = {A, Q} << 1;

            if (A >= 0)
                A = A - M;
            else
                A = A + M;

            Q[0] = (A >= 0) ? 1'b1 : 1'b0;
        end

        if (A < 0)
            A = A + M;

        quotient  = Q;           // quotient
        remainder = A[31:0];     // remainder
    end
endmodule

