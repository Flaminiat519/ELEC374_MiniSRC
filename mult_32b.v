//32-bit Booth's algorithm multiplier — produces a 64-bit result
module mult_32b #(parameter n = 32)(
	input [n-1:0] m, q,
	output reg [2*n-1:0] result
);
	//Append a 0 bit below Q to form Q' for Booth's recoding
	wire [n:0] qp = {q, 1'b0};

	//Partial products array — one per bit of Q, each 64 bits wide
	reg [2*n-1:0] pp [n-1:0];

	integer i, j;

	//Compute Booth-encoded partial products
	always @(*) begin
		for (i = 0; i < n; i = i + 1) begin
			if (!qp[i]) begin
				if (!qp[i+1])
					pp[i] = {2*n{1'b0}};        // 00 — add 0
				else
					pp[i] = -{{n{m[n-1]}}, m};  // 01 — subtract M
			end
			else begin
				if (qp[i+1])
					pp[i] = {2*n{1'b0}};        // 11 — add 0
				else
					pp[i] = {{n{m[n-1]}}, m};   // 10 — add M
			end
			//Shift partial product into position
			pp[i] = pp[i] << i;
		end
	end

	//Sum all partial products to get the final result
	always @(*) begin
		result = {2*n{1'b0}};
		for (j = 0; j < n; j = j + 1) begin
			result = result + pp[j];
		end
	end
endmodule
