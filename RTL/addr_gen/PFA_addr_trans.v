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
//-------------------------------------------------------------

module PFA_addr_trans #(parameter
		wDataInOut = 16
	)
	(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input clr,

	//param
	input [wDataInOut-1:0] 	Nf1,  //N1
	input [wDataInOut-1:0] 	Nf2,  //N2
	input [wDataInOut-1:0] 	Nf3,  //N3
	input [wDataInOut-1:0] 	q_p,  //q'
	input [wDataInOut-1:0] 	r_p,  //r'

	output reg [wDataInOut-1:0] n1,
	output reg [wDataInOut-1:0] n2,
	output reg [wDataInOut-1:0] n3
	
);

reg [wDataInOut-1:0] 	N1_sub_1, N2_sub_1, N3_sub_1;
wire n3_carry_out, n2p_carry_out;
reg [wDataInOut-1:0] 	rp_n3, qp_n2t;
reg [wDataInOut-1:0] 	n2p, n1p;
reg [wDataInOut-1:0] 	n2_temp, n1_temp;

always@(*)
	N1_sub_1 = Nf1 - 1'b1;

always@(*)
	N2_sub_1 = Nf2 - 1'b1;

always@(*)
	N3_sub_1 = Nf3 - 1'b1;

// Acc n3
acc_type1 #(
		.wDataInOut (16)
	)
acc_type1_n3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(clr),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.max_acc 	(N3_sub_1),
	.inc 	(1'b1),

	.out_acc 	(n3),
	.out_carry 	(n3_carry_out)
);

// Acc n2'
acc_type1 #(
		.wDataInOut (16)
	)
acc_type1_n2p (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(clr),
	.ena_top 	(1'b1),
	.in_carry 	(n3_carry_out),
	.max_acc 	(N2_sub_1),
	.inc 	(1'b1),

	.out_acc 	(n2p),
	.out_carry 	(n2p_carry_out)
);

// Acc n1'
acc_type1 #(
		.wDataInOut (16)
	)
acc_type1_n1p (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(clr),
	.ena_top 	(1'b1),
	.in_carry 	(n2p_carry_out),
	.max_acc 	(N1_sub_1),
	.inc 	(1'b1),

	.out_acc 	(n1p),
	.out_carry 	()
);

// Acc r'*n3
acc_mod_type1 #(
		.wDataInOut (16)
	)
acc_mod_type1_n3 (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(n3_carry_out),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.mod 	(Nf2),
	.inc 	(r_p),

	.out_acc 	(rp_n3)
);

// Acc q'*n2~
acc_mod_type1 #(
		.wDataInOut (16)
	)
acc_mod_type1_n2p (
	.clk 	(clk),    // Clock
	.rst_n 	(rst_n),  // Asynchronous reset active low

	.clr 	(n2p_carry_out),
	.ena_top 	(1'b1),
	.in_carry 	(1'b1),
	.mod 	(Nf1),
	.inc 	(q_p),

	.out_acc 	(qp_n2t)
);

always@(*)
	n2_temp = n2p + rp_n3;

always@(*)
	n2 = (n2_temp >= Nf2) ? n2_temp - Nf2 : n2_temp;

always@(*)
	n1_temp = n1p + qp_n2t;

always@(*)
	n1 = (n1_temp >= Nf1) ? n1_temp - Nf1 : n1_temp;

endmodule