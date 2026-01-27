//Non-Restoring Division Algorithm

module div #(parameter n = 32)(
	input [n - 1:0] dividend, divisor,
	output reg [n - 1:0] remainder, quotient
);

reg signed [n:0] A; //remainder
reg [n-1:0] Q; //quotient
reg [n-1:0] M;
integer i;

always @(*) begin
	A = '0; //Set A to 0
	Q = dividend;
	M = divisor;
	
	for(i = 0; i < n; i++) 
	begin
		//Shift A and Q by 1 bit
		{A, Q} = {A, Q} << 1;
		if(A >= 0) begin //if A is + subtract M
			A = A - M;
		end else begin //if A is - add M
			A = A + M;
		end
		
		if(A >= 0) begin //Change bit of quotient based off sign of A
			Q[0] = 1'b1;
		end else begin
			Q[0] = 1'b0;
		end
	end
	
	if (A < 0) begin //Restore if A is negative
		A = A + M;
	end
	
	quotient = Q;
	remainder = A[n-1:0];
end
endmodule
