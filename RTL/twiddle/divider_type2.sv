// Type2 : the quotient lacks 1 bit deliberately

module divider_type2 #(parameter
	integer w_divident = 16,
	integer w_divisor = 12
	)
	(
	input [w_divident-1:0] dividend,  
	input [w_divisor-1:0]  divisor,

	output reg [w_divident-w_divisor-1:0] quotient,
	output reg [w_divisor-1:0] remainder
);


// reg [3:0] 	dividend_t [8:0];
// reg [3:0] 	remainder_t [8:0];

// assign quotient[11:9] = 3'b000;

// assign dividend_t[8] = dividend[11:8];

// genvar i;
// generate 
// 	for ( i = 0; i < 8; i++) begin
// 		assign remainder_t[8-i] = dividend_t[8-i] - 4'd7;
// 		assign quotient[8-i] = (remainder_t[8-i][3])? 1'b0 : 1'b1;
// 		assign dividend_t[8-i-1] =(remainder_t[8-i][3]) ? 
// 		       { dividend_t[8-i][2:0], dividend[8-i-1] } :
// 		       { remainder_t[8-i][2:0], dividend[8-i-1] };
// 	end
// endgenerate

// assign remainder_t[0] = dividend_t[0][3:0] - 4'd7;
// assign quotient[0] = (remainder_t[0][3])? 1'b0 : 1'b1;

// assign remainder =(remainder_t[0][3])? dividend_t[0][2:0] : remainder_t[0];

endmodule