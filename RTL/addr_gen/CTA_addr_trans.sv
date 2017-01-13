// Author : Jiang Long
// Purpose : Calculate CTA addr
//-------------------------------------------------------------

module CTA_addr_trans #(parameter
		wDataInOut = 16
	)
	(
	input clk,    
	input rst_n,  

	input clr_n,

	//param
	input [0:5][2:0] 	Nf,  //N1,N2,...,N6
	input [2:0] current_stage,

	output reg [0:4][wDataInOut-1:0] addrs_butterfly 
	
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
	.in_carry 	(carry_out[4]),
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
	.in_carry 	(carry_out[3]),
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
	.in_carry 	(carry_out[2]),
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
	.in_carry 	(carry_out[1]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[0]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(n[0]),
	.out_carry 	(carry_out[0])
);

logic [wDataInOut-1:0]  addrs_all, coeff_stage;
logic [2:0]  num_radix;
always@(*)
begin
	case (current_stage)
	3'd0:
		coeff_stage = Nf[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5];
	3'd1:
		coeff_stage = Nf[2]*Nf[3]*Nf[4]*Nf[5];
	3'd2:
		coeff_stage = Nf[3]*Nf[4]*Nf[5];
	3'd3:
		coeff_stage = Nf[4]*Nf[5];
	3'd4:
		coeff_stage = Nf[5];
	3'd5:
		coeff_stage = 'd1;
	endcase
end

always@(*)
begin
	case (current_stage)
	3'd0:
		num_radix = Nf[0];
	3'd1:
		num_radix = Nf[1];
	3'd2:
		num_radix = Nf[2];
	3'd3:
		num_radix = Nf[3];
	3'd4:
		num_radix = Nf[4];
	3'd5:
		num_radix = Nf[5];
	endcase
end

always@(posedge clk)
begin
	if (!rst_n)
		addrs_all <= 0;
	else
		addrs_all <= n[0]*Nf[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
		             + n[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
		             + n[2]*Nf[3]*Nf[4]*Nf[5]
		             + n[3]*Nf[4]*Nf[5]
		             + n[4]*Nf[5]
		             + n[5] ;
end
assign addrs_butterfly[0] = addrs_all; 
assign addrs_butterfly[1] = addrs_all + coeff_stage; 
assign addrs_butterfly[2] = (num_radix < 3'd3)? 'd0 : 
                              addrs_all + 3'd2*coeff_stage; 
assign addrs_butterfly[3] = (num_radix < 3'd4)? 'd0 : 
                              addrs_all + 3'd3*coeff_stage; 
assign addrs_butterfly[4] = (num_radix < 3'd5)? 'd0 : 
                              addrs_all + 3'd3*coeff_stage; 


endmodule