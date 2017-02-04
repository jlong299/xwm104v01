// Pipeline divider
// Output delay : 8 clk cycles
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

localparam w_pipe = 4;   // Each pipeline handles 4 bits width
localparam n_stages = (w_divident-w_divisor)/w_pipe; // Num of stages

logic [w_divident-1 : 0]  remd_quot_r_0;  
logic [w_divident-1 : 0]  remd_quot_r [1 : n_stages];  
wire  [w_pipe-1:0]  quot [0 : n_stages-1];
wire  [w_divisor-1:0]  remd [0 : n_stages-1];

genvar i;
generate
	for (i=1; i < n_stages; i++) begin : div_gen
		divider_type2 #(
			.w_divident (w_divisor+w_pipe), //16
			.w_divisor (w_divisor) //12
			)
		divider_inst (
			.dividend (remd_quot_r[i]
				       [w_divident-1 : w_divident-w_divisor-w_pipe]),  
			.divisor (divisor),

			.quotient (quot[i]),
			.remainder (remd[i])
		);
	end
endgenerate
		divider_type2 #(
					.w_divident (w_divisor+w_pipe), //16
					.w_divisor (w_divisor) //12
					)
				divider_inst_0 (
					.dividend (remd_quot_r_0
						       [w_divident-1 : w_divident-w_divisor-w_pipe]),  
					.divisor (divisor),

					.quotient (quot[0]),
					.remainder (remd[0])
				);

assign remd_quot_r_0 = dividend; 
integer j;
always@(posedge clk)
begin
	if (!rst_n)
		for (j=1; j <= n_stages; j++) begin
			remd_quot_r[j] <= 0;
		end
	else begin
		for (j=2; j <= n_stages; j++) begin
			remd_quot_r[j][w_divident-1:w_divident-w_divisor] <= remd[j-1];
			remd_quot_r[j][w_pipe-1:0] <= quot[j-1];
			remd_quot_r[j][w_divident-w_divisor-1:w_pipe] <=
			           remd_quot_r[j-1][w_divident-w_divisor-1-w_pipe:0];
		end
			remd_quot_r[1][w_divident-1:w_divident-w_divisor] <= remd[0];
			remd_quot_r[1][w_pipe-1:0] <= quot[0];
			remd_quot_r[1][w_divident-w_divisor-1:w_pipe] <=
			           remd_quot_r_0[w_divident-w_divisor-1-w_pipe:0];
	end
end

assign quotient = remd_quot_r[n_stages][w_divident-w_divisor-1:0];
assign remainder = remd_quot_r[n_stages][w_divident-1:w_divident-w_divisor];

endmodule