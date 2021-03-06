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

localparam w_pipe = 1;   // Each pipeline handles 1 bits width
localparam n_stages = (w_divident-w_divisor)/w_pipe; // Num of stages

logic [w_divident-1 : 0]  remd_quot_r [0 : n_stages];  
logic  [w_pipe-1:0]  quot [0 : n_stages-1];
logic  [w_divisor-1:0]  remd [0 : n_stages-1];
logic  [w_divisor:0]  subtr [0 : n_stages-1];

genvar i;
generate
	for (i=0; i < n_stages; i++) begin : gen0
		assign subtr[i] = remd_quot_r[i]
		            [w_divident-1 : w_divident-w_divisor-w_pipe] - divisor;
		assign quot[i] = ~(subtr[i][w_divisor]);
		assign remd[i] = (subtr[i][w_divisor])? remd_quot_r[i]
		            [w_divident-2 : w_divident-w_divisor-w_pipe] : 
		            subtr[i][w_divisor-1:0] ;
	end
endgenerate

assign remd_quot_r[0] = dividend; 
generate
for (i=1; i <= n_stages; i++) begin : gen1
	assign remd_quot_r[i][w_divident-1:w_divident-w_divisor] = remd[i-1];
	assign remd_quot_r[i][w_pipe-1:0] = quot[i-1];
	assign remd_quot_r[i][w_divident-w_divisor-1:w_pipe] =
	           remd_quot_r[i-1][w_divident-w_divisor-1-w_pipe:0];
end
endgenerate

assign quotient = remd_quot_r[n_stages][w_divident-w_divisor-1:0];
assign remainder = remd_quot_r[n_stages][w_divident-1:w_divident-w_divisor];

endmodule