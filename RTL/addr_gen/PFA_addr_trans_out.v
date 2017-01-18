// Author : Jiang Long
// Purpose : Transformation between CTA addr & PFA addr
//----------------------------------------------------------------------------------
//                   PFA (Prime factor algorithm)
// ---- PART 1 ----------------- 
//   for DFT size N = N1*N2*N3       N1=2^a, N2=5^b, N3=3^c
//
//     n= (N2*N3*n1 + A1*n2~) mod N   n1,k1 = 0,1,...,N1-1
//     k= (B1*k1 + N1*k2~) mod N      n2~,k2~ = 0,1,...,N2*N3-1     (11)
//
//     n2~= (N3*n2 + A2*n3) mod N2*N3,  n2,k2 = 0,1,...,N2-1
//     k2~= (B2*k2 + N2*k3) mod N2*N3,  n3,k3 = 0,1,...,N3-1        (12)
//
//     In the case of CTA, A1=B1=A2=B2=1
//     In the case of PFA:
//        p1*N1 = q1*N2*N3 + 1
//        p2*N2 = q2*N1*N3 + 1
//        p3*N3 = q3*N1*N2 + 1           (13)
//
//   Then we get (14) (15) from  (11) (12) (13) 
//     n = (N2*N3*n1 + p1*N1*N3*n2 + p1*p2*N2*N3*n3) mod N    (14)
//     k = (p2*p3*N2*N3*k1 + p3*N1*N3*k2 + N1*N2*k3) mod N    (15)
//
//   -------------------
//   As RTL implementation:
//     n = (N2*N3*n1' + N3*n2' + n3) mod N
//     n1 = (n1' + q'*n2~) mod N1   q' = N1 - q    q==q1
//     n2~ = (N3*n2' + n3) mod N2*N3
//     n2 = (n2' + r'*n3) mod N2   r' = N2 - r    r==q2*N1
//
//
// ---- PART 2 ------ Output case-------- 
//     k = (N1*N2*k3' + N1*k2' + k1) mod N
//     k2 = (k2' + (N2 - q2*N3)*k1) mod N2
//     k2s = (N1*k2' + k1) mod N3
//     k3 = (k3' + (N3 - q3)*k2s) mod N3
//-------------------------------------------------------------

module PFA_addr_trans_out #(parameter
		wDataInOut = 16
	)
	(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input clr_n,

	//param
	input [wDataInOut-1:0] 	Nf1,  //N1
	input [wDataInOut-1:0] 	Nf2,  //N2
	input [wDataInOut-1:0] 	Nf3,  //N3
	input [wDataInOut-1:0] 	q_p,  // N3 - q3  
	input [wDataInOut-1:0] 	r_p,  // N2 - q2*N3   mod N2

	output reg [wDataInOut-1:0] k1,
	output reg [wDataInOut-1:0] k2,
	output reg [wDataInOut-1:0] k3
	
);

reg [wDataInOut-1:0] 	N1_sub_1, N2_sub_1, N3_sub_1;
wire k1_carry_out, k2p_carry_out;
reg [wDataInOut-1:0] 	rp_k1, qp_k2s;
reg [wDataInOut-1:0] 	k2p, k3p;
reg [wDataInOut-1:0] 	k2_temp, k3_temp;

always@(*)
	N1_sub_1 = Nf1 - 1'b1;

always@(*)
	N2_sub_1 = Nf2 - 1'b1;

always@(*)
	N3_sub_1 = Nf3 - 1'b1;

// Acc k1
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_type1_k1 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.max_acc 	(N1_sub_1),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k1),
	.out_carry 	(k1_carry_out)
);

// Acc k2'
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_type1_k2p (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(k1_carry_out),
	.max_acc 	(N2_sub_1),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k2p),
	.out_carry 	(k2p_carry_out)
);

// Acc k3'
acc_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_type1_k3p (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n),
	.ena_top 	(1'b1),
	.in_carry 	(k2p_carry_out),
	.max_acc 	(N3_sub_1),
	.inc 	({{wDataInOut-1{1'b0}},1'b1}),

	.out_acc 	(k3p),
	.out_carry 	()
);

// Acc r_p*k1
acc_mod_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_mod_type1_k2 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (~k1_carry_out)),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.mod 	(Nf2),
	.inc 	(r_p),

	.out_acc 	(rp_k1)
);

// Acc q_p*k2s
acc_mod_type1 #(
		.wDataInOut (wDataInOut)
	)
acc_mod_type1_k3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr_n 	(clr_n & (~k2p_carry_out)),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.mod 	(Nf3),
	.inc 	(q_p),

	.out_acc 	(qp_k2s)
);

always@(*)
	k2_temp = k2p + rp_k1;

always@(*)
	k2 = (k2_temp >= Nf2) ? k2_temp - Nf2 : k2_temp;

always@(*)
	k3_temp = k3p + qp_k2s;

always@(*)
	k3 = (k3_temp >= Nf3) ? k3_temp - Nf3 : k3_temp;

endmodule