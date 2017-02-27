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

	input [wDataIn-1:0] numerator,
	input [wDataIn-1:0] demoninator,

	output signed [wDataOut-1:0] dout_real,
	output signed [wDataOut-1:0] dout_imag
);

logic [31:0] quotient, quotient_round;
logic signed [wDataOut-1:0]  cosine, sine;
logic [wDataIn-1:0]  remainder;

divider_pipe0  #(
	.w_divident  (44),
	.w_divisor  (12)
	)
divider_pipe0_inst (
	.clk  (clk),  
	.rst_n  (rst_n),

	.dividend  ({numerator, 32'd0}),  
	.divisor  (demoninator),

	.quotient  (quotient),
	.remainder  (remainder)
);

assign quotient_round = (remainder > (demoninator >>1)) ?
                        quotient + 1'd1 : quotient;

// localparam An = 32000/1.647;
// localparam An = 16384/1.647;
logic [wDataOut-1:0]  xin = An;
CORDIC
cordic_inst(clk, cosine, sine, xin, 16'd0, quotient_round);

assign dout_real = cosine;
assign dout_imag = - sine;

endmodule