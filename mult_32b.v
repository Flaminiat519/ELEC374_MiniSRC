module mult_32b #(parameter n = 32)(
    input [n-1:0] m,q,
    output [2*n-1:0] result
);
//create q prime as a valid wire to be used
//concatinate q and 0 to make q prime
//ensures that 0 is one bit, not 32 bits
wire [n:0] qp = {q,1'b0};

//this is to store the partial products
//first parameter is bits of q + m
//second is bits of q
reg [2*n-1:0] pp [n-1:0]

//declare integer variable for for-loop
integer i;
//create for loop to itereate through qp
//and assign booth's!

//ASSIGNMENT TO COMPLETE

//shift each a bit over using i (like i always would)
//instead of pp[i], to pp[i>>1], shift operator
//if and e
always @ (*) begin
    for (i=0; i<n; i=i+1) begin
        if (!qp[i]) begin
            if (!qp[i+1])
                pp[i] = 64'b0;
            else
                pp [i] = {{32{-m[31]}}, -m};
        end
        else begin
            if (qp[i+1])
                pp[i] = 64'b0;
            else
                pp [i] = {{32{m[31]}}, m};
        end
    end
end

//adding all of the partial products together to
//get the final sum
always @(*) begin
    for (j = 0; j<n; j=j+1) begin
        result = result += pp[j>>1];
    end
end

endmodule