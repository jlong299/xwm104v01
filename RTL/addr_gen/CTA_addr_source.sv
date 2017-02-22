// Author : Jiang Long
// Purpose : Calculate CTA source stage addr
//-------------------------------------------------------------

module CTA_addr_source #(parameter
		wDataInOut = 12
	)
	(
	input clk,    
	input rst_n,  

	input clr_n,

	//param
	input [0:5][2:0] 	Nf,  //N1,N2,...,N6

	output logic [wDataInOut-1:0] addr_source_CTA 
	
);

logic [0:5]  carry_out, carry_in;
logic [0:5][2:0] k;

// Acc k1
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k1 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[0]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[0]),
	.out_carry 	(carry_out[0])
);

// Acc k2
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k2 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[0]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[1]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[1]),
	.out_carry 	(carry_out[1])
);

// Acc k3
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[1]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[2]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[2]),
	.out_carry 	(carry_out[2])
);

// Acc k4
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k4 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[2]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[3]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[3]),
	.out_carry 	(carry_out[3])
);

// Acc k5
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k5 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[3]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[4]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[4]),
	.out_carry 	(carry_out[4])
);

// Acc k6
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_k6 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[4]),
	.max_acc 	({{wDataInOut-3{1'b0}}, Nf[5]-3'd1}),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k[5]),
	.out_carry 	(carry_out[5])
);

logic [wDataInOut-1:0]  addrs_all, coeff_stage;
logic [2:0]  num_radix;

// always@(posedge clk)
// begin
// 	if (!rst_n)
// 		addr_source_CTA <= 0;
// 	else
// 		addr_source_CTA <= k[0]*Nf[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
// 		             + k[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
// 		             + k[2]*Nf[3]*Nf[4]*Nf[5]
// 		             + k[3]*Nf[4]*Nf[5]
// 		             + k[4]*Nf[5]
// 		             + k[5] ;
// end

logic [wDataInOut-1:0] addr_source_CTA_r; 
always@(posedge clk)
begin
	if (!rst_n)
		addr_source_CTA_r <= 0;
	else
		addr_source_CTA_r <= k[0]*Nf[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
		             + k[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
		             + k[2]*Nf[3]*Nf[4]*Nf[5]
		             + k[3]*Nf[4]*Nf[5]
		             + k[4]*Nf[5]
		             + k[5] ;
end
always@(posedge clk)
begin
	addr_source_CTA <= addr_source_CTA_r;
end

endmodule