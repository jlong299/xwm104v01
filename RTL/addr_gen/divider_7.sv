
module divider_7 (
	input [11:0] dividend,  
	//input [2:0]  divisor = 7 

	output reg [11:0] quotient,
	output reg [2:0] remainder
	
);


reg [8:0][3:0] 	dividend_t;
reg [8:0][3:0] 		remainder_t;

assign quotient[11:9] = 3'b000;

assign dividend_t[8] = dividend[11:8];

genvar i;
generate 
	for ( i = 0; i < 8; i=i+1) begin : gen0
		assign remainder_t[8-i] = dividend_t[8-i] - 4'd7;
		assign quotient[8-i] = (remainder_t[8-i][3])? 1'b0 : 1'b1;
		assign dividend_t[8-i-1] =(remainder_t[8-i][3]) ? 
		       { dividend_t[8-i][2:0], dividend[8-i-1] } :
		       { remainder_t[8-i][2:0], dividend[8-i-1] };
	end
endgenerate

assign remainder_t[0] = dividend_t[0][3:0] - 4'd7;
assign quotient[0] = (remainder_t[0][3])? 1'b0 : 1'b1;

assign remainder =(remainder_t[0][3])? dividend_t[0][2:0] : remainder_t[0][2:0];

endmodule