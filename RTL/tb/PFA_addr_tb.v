`timescale 1 ns / 1 ns
module PFA_addr_tb (

	);

localparam wDataInOut = 16;

reg clk;    // Clock
reg rst_n;  // Asynchronous reset active low

reg clr;

//param
reg [wDataInOut-1:0] 	Nf1;  //N1
reg [wDataInOut-1:0] 	Nf2;  //N2
reg [wDataInOut-1:0] 	Nf3;  //N3
reg [wDataInOut-1:0] 	q_p;  //q'
reg [wDataInOut-1:0] 	r_p;  //r'

reg [wDataInOut-1:0] n1;
reg [wDataInOut-1:0] n2;
reg [wDataInOut-1:0] n3;

assign Nf1 = 16'd3;
assign Nf2 = 16'd4;
assign Nf3 = 16'd5;
assign q_p = 16'd2;
assign r_p = 16'd1;


initial	begin
	rst_n = 0;
	clk = 0;
	clr = 1'b1;

	# 100 rst_n = 1'b1;
	# 100 clr = 1'b0;
end

always # 5 clk = ~clk; //100M



PFA_addr_trans #(
		.wDataInOut (16)
	)
PFA_addr_trans_inst
	(
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(clr),

	//param
	.Nf1 	(Nf1),  
	.Nf2 	(Nf2),  
	.Nf3 	(Nf3),  
	.q_p 	(q_p),  
	.r_p 	(r_p),  

	.n1 	(n1),
	.n2 	(n2),
	.n3 	(n3)
	
);

reg [wDataInOut-1:0]  N_out;
always@(*)
	N_out = n1*Nf2*Nf3 + n2*Nf3 + n3;


reg [11:0] 	cnt_dividend;
always@(posedge clk)
begin
	if (!rst_n)
		cnt_dividend <= 0;
	else
		cnt_dividend <= (cnt_dividend==12'd2048) ? 12'd0 : cnt_dividend+1'b1;
end

divider_7 divider_7_inst (
	.dividend 	(cnt_dividend),  

	.quotient 	(),
	.remainder 	()
	
);

endmodule