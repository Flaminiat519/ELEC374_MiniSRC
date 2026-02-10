//32 Bit multiplication operation module
module mult_32b #(parameter n = 32)(
		 input [n-1:0] m,q,
		 output reg [2*n-1:0] result
	);
	//create q prime as a valid wire to be used
	//concatinate q and 0 to make q prime
	//ensures that 0 is one bit, not 32 bits
	wire [n:0] qp = {q,1'b0};

	//this is to store the partial products
	//first parameter is bits of q + m
	//second is bits of q
	reg [2*n-1:0] pp [n-1:0];

	//declare integer variable for for-loop
	integer i, j;
	//create for loop to itereate through qp
	//and assign booth's!

	//Loop to compute booth's and the
	//relevant partial products
	always @(*) begin
		 for (i=0; i<n; i=i+1) begin
			  if (!qp[i]) begin
					if (!qp[i+1])
						 pp[i] = {2*n{1'b0}};
					else
						 pp[i] = -{{n{m[n-1]}}, m};
			  end
			  else begin
					if (qp[i+1])
						 pp[i] = {2*n{1'b0}};
					else
						 pp[i] = {{n{m[n-1]}}, m};
			  end
			  pp[i] = pp[i] << i;
		 end
	end

	//adding all of the partial products together to
	//get the final sum
	always @(*) begin
		 result = {2*n{1'b0}};
		 for (j=0; j < n; j=j+1) begin
			  result = result + pp[j];
		 end
	end

endmodule
