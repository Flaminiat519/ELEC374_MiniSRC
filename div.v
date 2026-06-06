//Non-restoring division algorithm — computes quotient and remainder for 32-bit inputs
module div #(parameter n = 32)(
	input  [n-1:0] dividend, divisor,
	output reg [n-1:0] remainder, quotient
);
	//Working registers for the algorithm
	reg signed [n:0] A; //Accumulator (one extra bit for sign)
	reg [n-1:0] Q; //Shifted dividend, becomes the quotient
	reg [n-1:0] M; //Absolute value of the divisor
	integer i;

	always @(*) begin
		//Initialize accumulator to 0
		A = 32'b0;

		//Work with absolute values — track sign separately for correction at the end
		M = divisor[31]  ? -divisor  : divisor;
		Q = dividend[31] ? -dividend : dividend;

		//Non-restoring division loop
		for (i = 0; i < n; i = i + 1) begin
			//Shift A and Q left by 1 bit
			{A, Q} = {A, Q} << 1;

			//Subtract or add M depending on the sign of A
			if (A >= 0)
				A = A - M;
			else
				A = A + M;

			//Set the current quotient bit based on the sign of A
			Q[0] = (A >= 0) ? 1'b1 : 1'b0;
		end

		//Restore remainder if it ended up negative
		if (A < 0)
			A = A + M;

		quotient  = Q;
		remainder = A[n-1:0];

		//Apply sign corrections based on the original operand signs
		if (divisor[31])
			quotient = -quotient;

		if (dividend[31]) begin
			quotient  = -quotient;
			remainder = -remainder;
		end
	end
endmodule
