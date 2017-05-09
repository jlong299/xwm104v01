module twdl_CTA #(parameter
	wDataInOut = 18,
	delay_twdl = 15,
	delay_twdl_42 = 15+3
	)
 (
	input clk,    
	input rst_n,  

	input [2:0]  factor,
	input twdl_sop,
	input [11:0]  twdl_numrtr,
	input [11:0]  twdl_demontr,
	input [20-1:0] twdl_quotient,
	input [12-1:0] twdl_remainder,
	input inverse,

	input  in_val,
	input  signed [wDataInOut-1:0]  din_real [0:4],
	input  signed [wDataInOut-1:0]  din_imag [0:4],

	output logic out_val,
	output logic signed [wDataInOut-1:0]  dout_real [0:4],
	output logic signed [wDataInOut-1:0]  dout_imag [0:4],
	output logic out_val_pre,

	output sclr_ff_addr,
	output logic rdreq_ff_addr
);

localparam  wDataTemp = 34;  //18 + 16  (1.17*2.14) 
logic [delay_twdl_42-1:0]  valid_r;
logic [0:4][7:0] rdaddr;
logic signed [15:0] tw_real [0:4]; 
logic signed [15:0] tw_imag [0:4]; 
logic signed [wDataTemp-1:0] dout_real_t [0:4];
logic signed [wDataTemp-1:0] dout_imag_t [0:4];
logic signed [wDataInOut-1:0]  d_real_r [0:4];
logic signed [wDataInOut-1:0]  d_imag_r [0:4];
logic signed [15:0] tw_real_An;
logic signed [wDataTemp-1:0] dout_real_t_p0 [1:4];
logic signed [wDataTemp-1:0] dout_real_t_p1 [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p0 [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p1 [1:4];

logic signed [15:0] tw_real_t [1:4]; 
logic signed [15:0] tw_imag_t [1:4]; 

genvar i;
integer j;

logic sclr;
assign sclr = valid_r[delay_twdl_42-1] & (!valid_r[delay_twdl_42-2]);
// wire [23:0]  wir_whatever;

// logic rdreq ;
// assign rdreq = (factor==3'd3 || factor==3'd5)? valid_r[delay_twdl-8+3] : valid_r[delay_twdl_42-8+3];
// generate
// for (i=0; i<5; i++) begin : gen0

// 	ff_rdx_data ff_inst (
// 		.data  ({din_real[i], din_imag[i]}),  //  fifo_input.datain
// 		.wrreq (in_val), //            .wrreq
// 		.rdreq (rdreq), //            .rdreq
// 		.clock (clk), //            .clk
// 		.sclr  (sclr),  //            .sclr
// 		.q     ({d_real_r[i], d_imag_r[i]})      // fifo_output.dataout
// 	);
// end
// endgenerate

logic signed [wDataInOut-1:0] din_real_d1 [0:4];
logic signed [wDataInOut-1:0] din_real_d2 [0:4];
logic signed [wDataInOut-1:0] din_real_d3 [0:4];
logic signed [wDataInOut-1:0] din_imag_d1 [0:4];
logic signed [wDataInOut-1:0] din_imag_d2 [0:4];
logic signed [wDataInOut-1:0] din_imag_d3 [0:4];
generate
for (i=0; i<5; i++) begin : gen0
	always@(posedge clk) din_real_d1[i] <= din_real[i];
	always@(posedge clk) din_real_d2[i] <= din_real_d1[i];
	always@(posedge clk) din_real_d3[i] <= din_real_d2[i];
	always@(posedge clk) din_imag_d1[i] <= din_imag[i];
	always@(posedge clk) din_imag_d2[i] <= din_imag_d1[i];
	always@(posedge clk) din_imag_d3[i] <= din_imag_d2[i];
end
endgenerate

always@(posedge clk) begin
for (j=0; j<5; j++) begin
	d_real_r[j] <= (factor==3'd3 || factor==3'd5)? din_real[j] : din_real_d3[j];
	d_imag_r[j] <= (factor==3'd3 || factor==3'd5)? din_imag[j] : din_imag_d3[j];
end
end

always@(posedge clk) begin
		out_val <= (factor==3'd3 || factor==3'd5)? valid_r[delay_twdl-2] : valid_r[delay_twdl_42-2] ;
		out_val_pre <= (factor==3'd3 || factor==3'd5)? valid_r[delay_twdl-3] : valid_r[delay_twdl_42-3] ;
end
always@(posedge clk)
begin
	if (!rst_n)  valid_r <= 0;
	else	valid_r <= {valid_r[delay_twdl_42-2:0], in_val};
end

logic signed [15:0] tw_real_1, tw_imag_1, tw_real_3, tw_imag_3;

localparam An = 16384;
localparam An_adj = 16384/1.647;

coeff_twdl_CTA #(
	.wDataIn (12),
	.wDataOut (16),
	.An (An_adj)
	)
coeff_twdl_CTA_inst	(
	.clk (clk),
	.rst_n (rst_n),

	.twdl_sop (twdl_sop),
	.numerator (twdl_numrtr),
	.demoninator (twdl_demontr),
	.twdl_quotient (twdl_quotient),
	.twdl_remainder (twdl_remainder),

	.dout_real_1 (tw_real_1),
	.dout_imag_1 (tw_imag_1),
	.dout_real_3 (tw_real_3),
	.dout_imag_3 (tw_imag_3)
);

//-----------------------------------------------------
// tw_real_2 = tw_real_1*tw_real_3 + tw_imag_1*tw_imag_3;
// tw_imag_2 = -tw_imag_1*tw_real_3 + tw_real_1*tw_imag_3;
// tw_real_4 = tw_real_1*tw_real_3 - tw_imag_1*tw_imag_3;
// tw_imag_4 = tw_imag_1*tw_real_3 + tw_real_1*tw_imag_3;
//-----------------------------------------------------
logic signed [31:0] t_r_2 , t_i_2, t_r_4, t_i_4;
logic signed [31:0] r1_r3, i1_i3, i1_r3, r1_i3;
logic signed [15:0] tw_real_1_r, tw_imag_1_r, tw_real_3_r, tw_imag_3_r;
logic signed [15:0] tw_real_1_r2, tw_imag_1_r2, tw_real_3_r2, tw_imag_3_r2;

// Pipeline : 2    20170417
lpm_mult_16_mrd u0 (
	.dataa  (tw_real_1),  //  mult_input.dataa
	.datab  (tw_real_3),  //            .datab
	.clock  (clk),  //            .clock
	.result (r1_r3)  // mult_output.result
);

lpm_mult_16_mrd u1 (
	.dataa  (tw_imag_1),  //  mult_input.dataa
	.datab  (tw_imag_3),  //            .datab
	.clock  (clk),  //            .clock
	.result (i1_i3)  // mult_output.result
);

lpm_mult_16_mrd u2 (
	.dataa  (tw_imag_1),  //  mult_input.dataa
	.datab  (tw_real_3),  //            .datab
	.clock  (clk),  //            .clock
	.result (i1_r3)  // mult_output.result
);

lpm_mult_16_mrd u3 (
	.dataa  (tw_real_1),  //  mult_input.dataa
	.datab  (tw_imag_3),  //            .datab
	.clock  (clk),  //            .clock
	.result (r1_i3)  // mult_output.result
);

always@(posedge clk) begin
	// r1_r3 <= tw_real_1*tw_real_3;
	// i1_i3 <= tw_imag_1*tw_imag_3;
	// i1_r3 <= tw_imag_1*tw_real_3;
	// r1_i3 <= tw_real_1*tw_imag_3;

	t_r_2 <= r1_r3 + i1_i3;
	t_i_2 <= -i1_r3 + r1_i3;
	t_r_4 <= r1_r3 - i1_i3;
	t_i_4 <= i1_r3 + r1_i3;

	tw_real_1_r <= tw_real_1;
	tw_imag_1_r <= tw_imag_1;
	tw_real_3_r <= tw_real_3;
	tw_imag_3_r <= tw_imag_3;
	tw_real_1_r2 <= tw_real_1_r;
	tw_imag_1_r2 <= tw_imag_1_r;
	tw_real_3_r2 <= tw_real_3_r;
	tw_imag_3_r2 <= tw_imag_3_r;
	tw_real[1] <= tw_real_1_r2;
	tw_imag[1] <= tw_imag_1_r2;
	tw_real[3] <= tw_real_3_r2;
	tw_imag[3] <= tw_imag_3_r2;
end

assign tw_real[2] = t_r_2[29:14];
assign tw_imag[2] = t_i_2[29:14];
assign tw_real[4] = t_r_4[29:14];
assign tw_imag[4] = t_i_4[29:14];


always@(posedge clk) begin
	if (!rst_n) begin
		for (j=1; j<=4; j++) begin
			tw_real_t[j] <= 0;
			tw_imag_t[j] <= 0;
		end
	end
	else begin
		tw_real_t[1] <= tw_real[1];
		tw_real_t[2] <= (factor==3'd2)? 16'sd16384 : tw_real[2];
		tw_real_t[3] <= (factor==3'd2)? tw_real[1] : tw_real[3];
		tw_real_t[4] <= tw_real[4];

		if (inverse == 1'b0) begin // FFT
			tw_imag_t[1] <= tw_imag[1];
			tw_imag_t[2] <= (factor==3'd2)? 16'sd0 : tw_imag[2];
			tw_imag_t[3] <= (factor==3'd2)? tw_imag[1] : tw_imag[3];
			tw_imag_t[4] <= tw_imag[4];
		end
		else begin // IFFT
			tw_imag_t[1] <= -tw_imag[1];
			tw_imag_t[2] <= (factor==3'd2)? 16'sd0 : -tw_imag[2];
			tw_imag_t[3] <= (factor==3'd2)? -tw_imag[1] : -tw_imag[3];
			tw_imag_t[4] <= -tw_imag[4];
		end
	end
end

//------------ Temp -----------------------------
logic signed [15:0] tw_real_t_r [1:4]; 
logic signed [15:0] tw_imag_t_r [1:4]; 
logic signed [wDataInOut-1:0]  d_real_rr [0:4];
logic signed [wDataInOut-1:0]  d_imag_rr [0:4];
always@(posedge clk) begin
	tw_real_t_r[1] <= tw_real_t[1];
	tw_real_t_r[2] <= tw_real_t[2];
	tw_real_t_r[3] <= tw_real_t[3];
	tw_real_t_r[4] <= tw_real_t[4];
	tw_imag_t_r[1] <= tw_imag_t[1];
	tw_imag_t_r[2] <= tw_imag_t[2];
	tw_imag_t_r[3] <= tw_imag_t[3];
	tw_imag_t_r[4] <= tw_imag_t[4];
	d_real_rr[1] <= d_real_r[1];
	d_real_rr[2] <= d_real_r[2];
	d_real_rr[3] <= d_real_r[3];
	d_real_rr[4] <= d_real_r[4];
	d_imag_rr[1] <= d_imag_r[1];
	d_imag_rr[2] <= d_imag_r[2];
	d_imag_rr[3] <= d_imag_r[3];
	d_imag_rr[4] <= d_imag_r[4];
end

//---------------------------------------------------

// always@(posedge clk) begin
// 	for (j=1; j<=4; j++) begin
// 		dout_real_t_p0[j] <= d_real_r[j]*tw_real_t[j];  
// 		dout_real_t_p1[j] <= d_imag_r[j]*tw_imag_t[j];
// 		dout_imag_t_p0[j] <= d_real_r[j]*tw_imag_t[j];
// 		dout_imag_t_p1[j] <= d_imag_r[j]*tw_real_t[j]; // 1.17*2.14
// 	end
// end

// generate
// for (i=1; i<5; i++) begin : gent
// 	// pipeline : 3
// 	lpm_mult_1816_mrd utest (
// 		.dataa  (d_real_r[i]),  //  mult_input.dataa
// 		.datab  (tw_real_t[i]),  //            .datab
// 		.clock  (clk),  //            .clock
// 		.result (dout_real_t_p0[i])  // mult_output.result
// 	);
// 	lpm_mult_1816_mrd utest2 (
// 		.dataa  (d_imag_r[i]),  //  mult_input.dataa
// 		.datab  (tw_imag_t[i]),  //            .datab
// 		.clock  (clk),  //            .clock
// 		.result (dout_real_t_p1[i])  // mult_output.result
// 	);
// 	lpm_mult_1816_mrd utest3 (
// 		.dataa  (d_real_r[i]),  //  mult_input.dataa
// 		.datab  (tw_imag_t[i]),  //            .datab
// 		.clock  (clk),  //            .clock
// 		.result (dout_imag_t_p0[i])  // mult_output.result
// 	);
// 	lpm_mult_1816_mrd utest4 (
// 		.dataa  (d_imag_r[i]),  //  mult_input.dataa
// 		.datab  (tw_real_t[i]),  //            .datab
// 		.clock  (clk),  //            .clock
// 		.result (dout_imag_t_p1[i])  // mult_output.result
// 	);
// end
// endgenerate

//----------- Temp -------------------------
	// pipeline : 3
	lpm_mult_1816_mrd utest1_1 (
		.dataa  (d_real_rr[1]),  //  mult_input.dataa
		.datab  (tw_real_t_r[1]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p0[1])  // mult_output.result
	);
	lpm_mult_1816_mrd utest2_1 (
		.dataa  (d_imag_rr[1]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[1]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p1[1])  // mult_output.result
	);
	lpm_mult_1816_mrd utest3_1 (
		.dataa  (d_real_rr[1]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[1]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p0[1])  // mult_output.result
	);
	lpm_mult_1816_mrd utest4_1 (
		.dataa  (d_imag_rr[1]),  //  mult_input.dataa
		.datab  (tw_real_t_r[1]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p1[1])  // mult_output.result
	);

	// pipeline : 3
	lpm_mult_1816_mrd utest1_2 (
		.dataa  (d_real_rr[2]),  //  mult_input.dataa
		.datab  (tw_real_t_r[2]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p0[2])  // mult_output.result
	);
	lpm_mult_1816_mrd utest2_2 (
		.dataa  (d_imag_rr[2]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[2]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p1[2])  // mult_output.result
	);
	lpm_mult_1816_mrd utest3_2 (
		.dataa  (d_real_rr[2]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[2]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p0[2])  // mult_output.result
	);
	lpm_mult_1816_mrd utest4_2 (
		.dataa  (d_imag_rr[2]),  //  mult_input.dataa
		.datab  (tw_real_t_r[2]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p1[2])  // mult_output.result
	);

	// pipeline : 3
	lpm_mult_1816_mrd utest1_3 (
		.dataa  (d_real_rr[3]),  //  mult_input.dataa
		.datab  (tw_real_t_r[3]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p0[3])  // mult_output.result
	);
	lpm_mult_1816_mrd utest2_3 (
		.dataa  (d_imag_rr[3]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[3]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p1[3])  // mult_output.result
	);
	lpm_mult_1816_mrd utest3_3 (
		.dataa  (d_real_rr[3]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[3]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p0[3])  // mult_output.result
	);
	lpm_mult_1816_mrd utest4_3 (
		.dataa  (d_imag_rr[3]),  //  mult_input.dataa
		.datab  (tw_real_t_r[3]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p1[3])  // mult_output.result
	);

	// pipeline : 3
	lpm_mult_1816_mrd utest1_4 (
		.dataa  (d_real_rr[4]),  //  mult_input.dataa
		.datab  (tw_real_t_r[4]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p0[4])  // mult_output.result
	);
	lpm_mult_1816_mrd utest2_4 (
		.dataa  (d_imag_rr[4]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[4]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_real_t_p1[4])  // mult_output.result
	);
	lpm_mult_1816_mrd utest3_4 (
		.dataa  (d_real_rr[4]),  //  mult_input.dataa
		.datab  (tw_imag_t_r[4]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p0[4])  // mult_output.result
	);
	lpm_mult_1816_mrd utest4_4 (
		.dataa  (d_imag_rr[4]),  //  mult_input.dataa
		.datab  (tw_real_t_r[4]),  //            .datab
		.clock  (clk),  //            .clock
		.result (dout_imag_t_p1[4])  // mult_output.result
	);
//--------------------------------------------

logic signed [wDataTemp-1:0] dout_real_t_p0_r [1:4];
logic signed [wDataTemp-1:0] dout_real_t_p1_r [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p0_r [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p1_r [1:4];
// generate
// for (i=1; i<5; i++) begin : gen1
// always@(posedge clk)
// begin
// 	// if (!rst_n)  
// 	// begin
// 	// 	dout_real_t[i] <= 0;
// 	// 	dout_imag_t[i] <= 0;
// 	// end
// 	// else
// 	// begin
// 		dout_real_t[i] <= dout_real_t_p0_r[i] - dout_real_t_p1_r[i];
// 		dout_imag_t[i] <= dout_imag_t_p0_r[i] + dout_imag_t_p1_r[i];
// 	// end

// 	dout_real_t_p0_r[i] <= dout_real_t_p0[i];
// 	dout_real_t_p1_r[i] <= dout_real_t_p1[i];
// 	dout_imag_t_p0_r[i] <= dout_imag_t_p0[i];
// 	dout_imag_t_p1_r[i] <= dout_imag_t_p1[i];
// end

//------------- Temp -------------------
always@(posedge clk)
begin
	dout_real_t[1] <= dout_real_t_p0_r[1] - dout_real_t_p1_r[1];
	dout_imag_t[1] <= dout_imag_t_p0_r[1] + dout_imag_t_p1_r[1];

	dout_real_t_p0_r[1] <= dout_real_t_p0[1];
	dout_real_t_p1_r[1] <= dout_real_t_p1[1];
	dout_imag_t_p0_r[1] <= dout_imag_t_p0[1];
	dout_imag_t_p1_r[1] <= dout_imag_t_p1[1];
end
always@(posedge clk)
begin
	dout_real_t[2] <= dout_real_t_p0_r[2] - dout_real_t_p1_r[2];
	dout_imag_t[2] <= dout_imag_t_p0_r[2] + dout_imag_t_p1_r[2];

	dout_real_t_p0_r[2] <= dout_real_t_p0[2];
	dout_real_t_p1_r[2] <= dout_real_t_p1[2];
	dout_imag_t_p0_r[2] <= dout_imag_t_p0[2];
	dout_imag_t_p1_r[2] <= dout_imag_t_p1[2];
end
always@(posedge clk)
begin
	dout_real_t[3] <= dout_real_t_p0_r[3] - dout_real_t_p1_r[3];
	dout_imag_t[3] <= dout_imag_t_p0_r[3] + dout_imag_t_p1_r[3];

	dout_real_t_p0_r[3] <= dout_real_t_p0[3];
	dout_real_t_p1_r[3] <= dout_real_t_p1[3];
	dout_imag_t_p0_r[3] <= dout_imag_t_p0[3];
	dout_imag_t_p1_r[3] <= dout_imag_t_p1[3];
end
always@(posedge clk)
begin
	dout_real_t[4] <= dout_real_t_p0_r[4] - dout_real_t_p1_r[4];
	dout_imag_t[4] <= dout_imag_t_p0_r[4] + dout_imag_t_p1_r[4];

	dout_real_t_p0_r[4] <= dout_real_t_p0[4];
	dout_real_t_p1_r[4] <= dout_real_t_p1[4];
	dout_imag_t_p0_r[4] <= dout_imag_t_p0[4];
	dout_imag_t_p1_r[4] <= dout_imag_t_p1[4];
end
//-------------------------------------------------------------

generate
for (i=1; i<5; i++) begin : gen1

// 1.17*2.14   An = 16384 = 2^14
assign dout_real[i] = (dout_real_t[i][13])? 
                      dout_real_t[i][wDataInOut+14-1:14] + 2'sd1
                      : dout_real_t[i][wDataInOut+14-1:14] ;
assign dout_imag[i] = (dout_imag_t[i][13])? 
                      dout_imag_t[i][wDataInOut+14-1:14] + 2'sd1
                      : dout_imag_t[i][wDataInOut+14-1:14] ;

end
endgenerate

logic signed [wDataInOut-1:0]  d_real_r2, d_imag_r2;
logic signed [wDataInOut-1:0]  d_real_r3, d_imag_r3;
logic signed [wDataInOut-1:0]  d_real_r4, d_imag_r4;
logic signed [wDataInOut-1:0]  d_real_r5, d_imag_r5;
always@(posedge clk)
begin
	if (!rst_n)  
	begin
		dout_real[0] <= 0;
		dout_imag[0] <= 0;
		d_real_r2 <= 0;
		d_imag_r2 <= 0;
		d_real_r3 <= 0;
		d_imag_r3 <= 0;		
		d_real_r4 <= 0;
		d_imag_r4 <= 0;
		d_real_r5 <= 0;
		d_imag_r5 <= 0;
	end
	else
	begin
		if  (  ((factor==3'd3 || factor==3'd5) && valid_r[delay_twdl-2] ) 
			|| ((factor==3'd4 || factor==3'd2) && valid_r[delay_twdl_42-2])  )
		begin
			dout_real[0] <= d_real_r5; 
			dout_imag[0] <= d_imag_r5;
		end
		else begin
			dout_real[0] <= 0;
			dout_imag[0] <= 0;
		end
		d_real_r2 <= d_real_r[0];
		d_imag_r2 <= d_imag_r[0];
		d_real_r3 <= d_real_r2;
		d_imag_r3 <= d_imag_r2;
		d_real_r4 <= d_real_r3;
		d_imag_r4 <= d_imag_r3;
		d_real_r5 <= d_real_r4;
		d_imag_r5 <= d_imag_r4;
	end
end

always@(*) begin
	if (factor==3'd3 || factor==3'd5)
		rdreq_ff_addr =  valid_r[delay_twdl-2];
	else
		rdreq_ff_addr =  valid_r[delay_twdl_42-2];
end

assign sclr_ff_addr = sclr;

endmodule