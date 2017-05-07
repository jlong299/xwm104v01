// Author : Jiang Long
// Purpose : Calculate CTA source stage addr
//-------------------------------------------------------------

module CTA_addr_source_p4 #(parameter
		wDataInOut = 12
	)
	(
	input clk,    
	input rst_n,  

	input clr_n,

	//param
	input [0:5][2:0] 	Nf,  //N1,N2,...,N6
	input [0:5][11:0]  twdl_demontr,

	output logic [0:3][wDataInOut-1:0] addr_source_CTA 
);

logic [0:5]  carry_out, carry_in;
logic [0:5][2:0] k;

// Acc k1
acc_type1 #(
		.wDataInOut (3)
	)
acc_k1 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.max_acc 	(Nf[0]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[0]),
	.out_carry 	(carry_out[0])
);

// Acc k2
acc_type1 #(
		.wDataInOut (3)
	)
acc_k2 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[0]),
	.max_acc 	(Nf[1]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[1]),
	.out_carry 	(carry_out[1])
);

// Acc k3
acc_type1 #(
		.wDataInOut (3)
	)
acc_k3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[1]),
	.max_acc 	(Nf[2]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[2]),
	.out_carry 	(carry_out[2])
);

// Acc k4
acc_type1 #(
		.wDataInOut (3)
	)
acc_k4 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[2]),
	.max_acc 	(Nf[3]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[3]),
	.out_carry 	(carry_out[3])
);

// Acc k5
acc_type1 #(
		.wDataInOut (3)
	)
acc_k5 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[3]),
	.max_acc 	(Nf[4]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[4]),
	.out_carry 	(carry_out[4])
);

// Acc k6
acc_type1 #(
		.wDataInOut (3)
	)
acc_k6 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(carry_out[4]),
	.max_acc 	(Nf[5]-3'd1),
	.inc 	(3'b1),

	.out_acc 	(k[5]),
	.out_carry 	(carry_out[5])
);

logic [wDataInOut-1:0]  addrs_all, coeff_stage;
logic [2:0]  num_radix;

// logic [wDataInOut-1:0] addr_source_CTA_r; 
// // always@(posedge clk)
// // begin
// // 	if (!rst_n)
// // 		addr_source_CTA_r <= 0;
// // 	else
// // 		addr_source_CTA_r <= k[0]*Nf[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
// // 		             + k[1]*Nf[2]*Nf[3]*Nf[4]*Nf[5]
// // 		             + k[2]*Nf[3]*Nf[4]*Nf[5]
// // 		             + k[3]*Nf[4]*Nf[5]
// // 		             + k[4]*Nf[5]
// // 		             + k[5] ;
// // end

// always@(posedge clk)
// begin
// 	if (!rst_n)
// 		addr_source_CTA_r <= 0;
// 	else
// 		addr_source_CTA_r <= k[0]*twdl_demontr[1]
// 		             + k[1]*twdl_demontr[2]
// 		             + k[2]*twdl_demontr[3]
// 		             + k[3]*twdl_demontr[4]
// 		             + k[4]*twdl_demontr[5]
// 		             + k[5] ;
// end

logic [wDataInOut-1:0] k0_x_twdl_dem1, k1_x_twdl_dem2, k2_x_twdl_dem3,
                       k3_x_twdl_dem4, k4_x_twdl_dem5;
always@(posedge clk)
begin
	if (!rst_n || !clr_n) begin
		k0_x_twdl_dem1 <= 0;
		k1_x_twdl_dem2 <= 0;
		k2_x_twdl_dem3 <= 0;
		k3_x_twdl_dem4 <= 0;
		k4_x_twdl_dem5 <= 0;
	end
	else begin
		if (carry_out[0]) 
			k0_x_twdl_dem1 <= 0;
		else if (1'b1)
			k0_x_twdl_dem1 <= k0_x_twdl_dem1 + twdl_demontr[1];
		else
			k0_x_twdl_dem1 <= k0_x_twdl_dem1;

		if (carry_out[1]) 
			k1_x_twdl_dem2 <= 0;
		else if (carry_out[0])
			k1_x_twdl_dem2 <= k1_x_twdl_dem2 + twdl_demontr[2];
		else
			k1_x_twdl_dem2 <= k1_x_twdl_dem2;

		if (carry_out[2]) 
			k2_x_twdl_dem3 <= 0;
		else if (carry_out[1])
			k2_x_twdl_dem3 <= k2_x_twdl_dem3 + twdl_demontr[3];
		else
			k2_x_twdl_dem3 <= k2_x_twdl_dem3;

		if (carry_out[3]) 
			k3_x_twdl_dem4 <= 0;
		else if (carry_out[2])
			k3_x_twdl_dem4 <= k3_x_twdl_dem4 + twdl_demontr[4];
		else
			k3_x_twdl_dem4 <= k3_x_twdl_dem4;

		if (carry_out[4]) 
			k4_x_twdl_dem5 <= 0;
		else if (carry_out[3])
			k4_x_twdl_dem5 <= k4_x_twdl_dem5 + twdl_demontr[5];
		else
			k4_x_twdl_dem5 <= k4_x_twdl_dem5;
	end		                  
end

logic [wDataInOut-1:0]  tt0, tt1;
logic [wDataInOut-1:0]  addr_source_CTA_pre, twdl_demontr_1x2;
always@(posedge clk)
begin
	tt0 <= k0_x_twdl_dem1 + k1_x_twdl_dem2 + k2_x_twdl_dem3;
	tt1 <= k3_x_twdl_dem4 + k4_x_twdl_dem5 + k[5];
	addr_source_CTA_pre <= tt0 + tt1;
	twdl_demontr_1x2 <= twdl_demontr[1] + (twdl_demontr[1] << 1);

	addr_source_CTA[0] <= addr_source_CTA_pre;
	addr_source_CTA[1] <= addr_source_CTA_pre + twdl_demontr[1];
	addr_source_CTA[2] <= addr_source_CTA_pre + (twdl_demontr[1] << 1);
	addr_source_CTA[3] <= addr_source_CTA_pre + twdl_demontr_1x2;
end

endmodule