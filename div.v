//Non restorive division operation module
module div #(parameter n = 32)(
	 //define 32-bit input and output
	input  [n-1:0] RA, //dividend
    input  [n-1:0] RB, //divisor
    output reg [n-1:0] remainder, 
    output reg [n-1:0] quotient
);
	reg signed [n:0] A; //intermediate remainder
	reg [n-1:0] Q; //intermediate quotient
	reg [n-1:0] M; //intermediate divisor
    integer i;

	//use always statement to compute the algorithm
    always @(*) begin
        A = 0;
		//set Q to the dividend input
        Q = RA;
		//set M to the divisor input
        M = RB;

        for (i = 0; i < n; i = i + 1) begin
			//Shift A and Q left by 1 bit
            {A, Q} = {A, Q} << 1;

			// if A is positive, subtract M
            if (A >= 0)
                A = A - M;
			// if A is negative, add M
            else
                A = A + M;

			//Set quotient bit based on sign of A
            Q[0] = (A >= 0) ? 1'b1 : 1'b0;
        end

		//check if negative
        if (A < 0)
            A = A + M;

        quotient = Q; //quotient
        remainder = A[31:0]; //remainder
    end
endmodule

