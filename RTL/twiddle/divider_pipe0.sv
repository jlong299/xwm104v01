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

localparam w_pipe = 4;   // Each pipeline handles 4 bits width
localparam n_stages = (w_divident-w_divisor)/w_pipe; // Num of stages

logic [w_divident-1 : 0]  remd_quot_r [0 : n_stages];  
wire  [w_pipe-1:0]  quot [0 : n_stages-1];
wire  [w_divisor-1:0]  remd [0 : n_stages-1];

genvar i;
generate
	for (i=0; i < n_stages; i++) begin
		divider_type2 #(
			.w_divident (w_divisor+w_pipe), //16
			.w_divisor (w_divisor) //12
			)
			(
			.dividend (remd_quot_r[i]
				       [w_divident-1 : w_divident-w_divisor-w_pipe]),  
			.divisor (divisor),

			.quotient (quot[i]),
			.remainder (remd[i])
		);
	end
endgenerate

assign remd_quot_r[0] = dividend; 
integer j;
always@(posedge clk)
begin
	if (!rst_n)
		for (j=1; j <= n_stages; j++) begin
			remd_quot_r[j] <= 0;
		end
	else begin
		for (j=1; j <= n_stages; j++) begin
			remd_quot_r[j][w_divident-1:w_divident-w_divisor] <= remd[j-1];
			remd_quot_r[j][w_pipe-1:0] <= quot[j-1];
			remd_quot_r[j][w_divident-w_divisor-1:w_pipe] <=
			           remd_quot_r[j-1][w_divident-w_divisor-1-w_pipe:0];
		end
	end
end


endmodule