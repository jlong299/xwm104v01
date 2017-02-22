// Author : Jiang Long
// Purpose : Calculate CTA twddle numerator
//-------------------------------------------------------------

module CTA_twdl_numrtr #(parameter
		wDataInOut = 12
	)
	(
	input clk,    
	input rst_n,  

	input clr_n,

	//param
	input [0:5][2:0] 	Nf,  //N1,N2,...,N6
	input [2:0] current_stage,
	input [0:5][11:0] twdl_demontr,

	output reg [0:4][wDataInOut-1:0] twdl_numrtr
	
);

logic [0:5]  carry_out, carry_in;
logic [0:5][2:0] n;

// Acc n6
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n6 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd5))),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[5]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[5]),
	.out_carry 	(carry_out[5])
);

// Acc n5
assign carry_in[4] = (current_stage==3'd5)? 1'b1 : carry_out[5];
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n5 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd4))),
	.ena_top 	(1'b1),
	.in_carry 	(carry_in[4]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[4]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[4]),
	.out_carry 	(carry_out[4])
);

// Acc n4
assign carry_in[3] = (current_stage==3'd4)? carry_out[5] : carry_out[4];
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n4 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd3))),
	.ena_top 	(1'b1),
	.in_carry 	(carry_in[3]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[3]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[3]),
	.out_carry 	(carry_out[3])
);

// Acc n3
assign carry_in[2] = (current_stage==3'd3)? carry_out[4] : carry_out[3];
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd2))),
	.ena_top 	(1'b1),
	.in_carry 	(carry_in[2]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[2]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[2]),
	.out_carry 	(carry_out[2])
);

// Acc n2
assign carry_in[1] = (current_stage==3'd2)? carry_out[3] : carry_out[2];
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n2 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd1))),
	.ena_top 	(1'b1),
	.in_carry 	(carry_in[1]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[1]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[1]),
	.out_carry 	(carry_out[1])
);

// Acc n1
assign carry_in[0] = (current_stage==3'd1)? carry_out[2] : carry_out[1];
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_n1 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (!(current_stage==3'd0))),
	.ena_top 	(1'b1),
	.in_carry 	(carry_in[0]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[0]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[0]),
	.out_carry 	(carry_out[0])
);

logic [wDataInOut-1:0]  twdl_numrtr_base;
always@(posedge clk)
begin
	if (!rst_n)
		twdl_numrtr_base <= 0;
	else begin
		case (current_stage)
		3'd0 :
		twdl_numrtr_base <= n[1]*twdl_demontr[2]
		                  + n[2]*twdl_demontr[3]
		                  + n[3]*twdl_demontr[4]
		                  + n[4]*twdl_demontr[5]
		                  + n[5] ;
		3'd1 :
		twdl_numrtr_base <= n[2]*twdl_demontr[3]
		                  + n[3]*twdl_demontr[4]
		                  + n[4]*twdl_demontr[5]
		                  + n[5] ;
		3'd2 :
		twdl_numrtr_base <= n[3]*twdl_demontr[4]
		                  + n[4]*twdl_demontr[5]
		                  + n[5] ;
		3'd3 :
		twdl_numrtr_base <= n[4]*twdl_demontr[5]
		                  + n[5] ;
		3'd4 :
		twdl_numrtr_base <= n[5] ;
		3'd5 :
		twdl_numrtr_base <= 0 ;
		default :
		twdl_numrtr_base <= 0;
		endcase
	end
end

// always@(posedge clk) begin
// 	twdl_numrtr[0] <= 0; 
// 	twdl_numrtr[1] <= twdl_numrtr_base; 
// 	twdl_numrtr[2] <= 3'd2*twdl_numrtr_base; 
// 	twdl_numrtr[3] <= 3'd3*twdl_numrtr_base; 
// 	twdl_numrtr[4] <= 3'd4*twdl_numrtr_base; 
// end

reg [0:4][wDataInOut-1:0] twdl_numrtr_r;
always@(posedge clk) begin
	twdl_numrtr_r[0] <= 0; 
	twdl_numrtr_r[1] <= twdl_numrtr_base; 
	twdl_numrtr_r[2] <= 3'd2*twdl_numrtr_base; 
	twdl_numrtr_r[3] <= 3'd3*twdl_numrtr_base; 
	twdl_numrtr_r[4] <= 3'd4*twdl_numrtr_base; 
end
always@(posedge clk) begin
	twdl_numrtr <= twdl_numrtr_r;
end

endmodule