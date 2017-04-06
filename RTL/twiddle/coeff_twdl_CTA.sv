// Output :   exp(-i* 2pi* numerator/demoniator)
// Delay :    24 clk cycles    numerator/demoniator --> dout_real/dout_imag
module coeff_twdl_CTA #(parameter
	wDataIn = 12,
	wDataOut = 16,
	An = 16384/1.647
	)
	(
	input clk,
	input rst_n,

	input twdl_sop,
	input [wDataIn-1:0] numerator,
	input [wDataIn-1:0] demoninator,
  	input [20-1:0] twdl_quotient,
  	input [12-1:0] twdl_remainder,

	output signed [wDataOut-1:0] dout_real,
	output signed [wDataOut-1:0] dout_imag
);

// logic [31:0] quotient, quotient_round;
logic [20-1:0] quotient;
logic signed [wDataOut-1:0]  cosine, sine;
logic [wDataIn-1:0]  remainder;

// divider_pipe0  #(
// 	.w_divident  (44),
// 	.w_divisor  (12)
// 	)
// divider_pipe0_inst (
// 	.clk  (clk),  
// 	.rst_n  (rst_n),

// 	.dividend  ({numerator, 32'd0}),  
// 	.divisor  (demoninator),

// 	.quotient  (quotient),
// 	.remainder  (remainder)
// );

 // ----------------------------------------------
 // quotient = numerator * 2^32 / demoninator
 // remainder = numerator * 2^32 % demoninator
 // ----------------------------------------------

 //----- Only 1200 --------
 // 2^20 = 1200 * 873 + 976
 // 2^20 = 300 * 3495 + 76
 // 2^20 = 75 * 13981 + 1
 // 2^20 = 15 * 69905 + 1
 // 2^20 = 3 * 349525 + 1

logic [20-1:0]  quotient_temp;
logic [12-1:0]  remainder_temp, remainder_remain;
logic remainder_carry_in;
logic [12-1:0] cnt_numerator;
always@(posedge clk) begin
	if (!rst_n) begin
		cnt_numerator <= 0;
	end
	else begin
		if (twdl_sop)
			cnt_numerator <= 12'd1;
		else 
			cnt_numerator <= (cnt_numerator == numerator-12'd1)? 12'd0 : cnt_numerator+12'd1;
	end
end
always@(posedge clk) begin
	if (!rst_n) begin
		quotient <= 0;
		remainder <= 0;
	end
	else begin
		if (twdl_sop==1'b1 || cnt_numerator==12'd0) begin
			quotient <= 0;
			remainder <= 0;
		end
		else begin
			quotient <= quotient_temp + remainder_carry_in;
			remainder <= remainder_remain;
		end
	end
end

assign quotient_temp = quotient + twdl_quotient;
assign remainder_temp = remainder + twdl_remainder;
assign remainder_carry_in = (remainder_temp < demoninator)? 1'd0 : 1'd1;
assign remainder_remain = (remainder_temp < demoninator)? remainder_temp : remainder_temp-demoninator;

// assign quotient_round = (remainder > (demoninator >>1)) ?
//                         quotient + 1'd1 : quotient;


// localparam An = 32000/1.647;
// localparam An = 16384/1.647;
logic [wDataOut-1:0]  xin = An;
CORDIC
cordic_inst(clk, cosine, sine, xin, 16'd0, quotient);

assign dout_real = cosine;
assign dout_imag = - sine;

endmodule