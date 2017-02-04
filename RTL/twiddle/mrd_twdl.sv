// Output :   exp(-i* 2pi* numerator/demoniator)
// Delay :    24 clk cycles    numerator/demoniator --> dout_real/dout_imag
module mrd_twdl #(parameter
	wDataIn = 12,
	wDataOut = 16
	)
	(
	input clk,
	input rst_n,

	input [wDataIn-1:0] numerator,
	input [wDataIn-1:0] demoninator,

	output signed [wDataOut-1:0] dout_real,
	output signed [wDataOut-1:0] dout_imag
);

logic [31:0] quotient;
logic signed [wDataOut-1:0]  cosine, sine;

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
	.remainder  ()
);

localparam An = 32000/1.647;
logic [wDataOut-1:0]  xin = An;
CORDIC
cordic_inst(clk, cosine, sine, xin, 16'd0, quotient);

assign dout_real = cosine;
assign dout_imag = - sine;

endmodule