`timescale 1 ns / 1 ns
module divider_pipe0_tb  (
	);

	localparam w_divident = 44;
	localparam w_divisor = 12;
	
	logic clk;  
	logic rst_n;

	logic [w_divident-1:0] dividend;  
	logic [w_divisor-1:0]  divisor;

	logic [w_divident-w_divisor-1:0] quotient;
	logic [w_divisor-1:0] remainder;


	
initial	begin
	rst_n = 0;
	clk = 0;

	# 100 rst_n = 1'b1;
end
always # 5 clk = ~clk; //100M

always@(posedge clk)
begin
	if (!rst_n)	begin
		dividend <= 44'h1_0000_0000;
		divisor <= 12'd1200;
	end
	else begin
		dividend <= dividend + 1;
	end
end


divider_pipe0  #(
	.w_divident  (44),
	.w_divisor  (12)
	)
divider_pipe0_inst (
	.clk  (clk),  
	.rst_n  (rst_n),

	.dividend  (dividend),  
	.divisor  (divisor),

	.quotient  (quotient),
	.remainder  (remainder)
);

endmodule