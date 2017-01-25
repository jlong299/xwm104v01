// Pipeline divider
module divider_pipe0  #(parameter
	integer w_divident = 44,
	integer w_divisor = 12
	)
	(
	input clk,  
	input rst_n,

	input [w_divident-1:0] dividend,  
	input [w_divisor-1:0]  divisor,

	output logic [w_divident-w_divisor-1:0] quotient,
	output logic [w_divisor-1:0] remainder
	
);

endmodule