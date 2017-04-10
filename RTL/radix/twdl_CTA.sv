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
	input [11:0]  twdl_numrtr_1,
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

genvar i;
integer j;

logic sclr;
// assign sclr = valid_r[delay_twdl-1] & (!valid_r[delay_twdl-2]);
assign sclr = valid_r[delay_twdl_42-1] & (!valid_r[delay_twdl_42-2]);
wire [23:0]  wir_whatever;

logic rdreq ;
assign rdreq = (factor==3'd3 || factor==3'd5)? valid_r[delay_twdl-8+3] : valid_r[delay_twdl_42-8+3];
generate
for (i=0; i<5; i++) begin : gen0

	ff_rdx_data ff_inst (
		.data  ({din_real[i], din_imag[i]}),  //  fifo_input.datain
		.wrreq (in_val), //            .wrreq
		.rdreq (rdreq), //            .rdreq
		.clock (clk), //            .clk
		.sclr  (sclr),  //            .sclr
		.q     ({d_real_r[i], d_imag_r[i]})      // fifo_output.dataout
	);
end
endgenerate

always@(posedge clk) begin
	if (twdl_demontr==12'd3 || twdl_demontr==12'd1)
		out_val <= in_val;
	else
		out_val <= (factor==3'd3 || factor==3'd5)? valid_r[delay_twdl-5+3] : valid_r[delay_twdl_42-5+3] ;
end
always@(posedge clk)
begin
	if (!rst_n)  valid_r <= 0;
	// else	valid_r <= {valid_r[delay_twdl-2:0], in_val};
	else	valid_r <= {valid_r[delay_twdl_42-2:0], in_val};
end

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
	.numerator (twdl_numrtr_1),
	.demoninator (twdl_demontr),
	.twdl_quotient (twdl_quotient),
	.twdl_remainder (twdl_remainder),

	.dout_real (tw_real[1]),
	.dout_imag (tw_imag[1])
);
logic signed [29:0] t_r[2:4]; 
logic signed [29:0] t_i[2:4]; 
logic signed [29:0] t_r_2_p0, t_r_2_p1, t_i_2, t_r_3_p0, t_r_3_p1, t_i_3_p0,
                    t_i_3_p1, t_r_4_p0, t_r_4_p1, t_i_4;
// assign t_r[2] = tw_real[1]*tw_real[1]-tw_imag[1]*tw_imag[1];
// assign t_i[2] = tw_real[1]*tw_imag[1];
// assign t_r[3] = tw_real[1]*tw_real[2]-tw_imag[1]*tw_imag[2];
// assign t_i[3] = tw_real[1]*tw_imag[2]+tw_imag[1]*tw_real[2];
// assign t_r[4] = tw_real[2]*tw_real[2]-tw_imag[2]*tw_imag[2];
// assign t_i[4] = tw_real[2]*tw_imag[2];

logic signed [15:0] tw_real_1_r0, tw_real_1_r1, tw_real_1_r2; 
logic signed [15:0] tw_imag_1_r0, tw_imag_1_r1, tw_imag_1_r2; 
logic signed [15:0] tw_real_2_r0, tw_real_2_r1; 
logic signed [15:0] tw_imag_2_r0, tw_imag_2_r1;

logic signed [15:0] tw_real_1r, tw_imag_1r;
//--------  1st pipeline  ------------
always@(posedge clk) begin
	tw_real_1r <= tw_real[1];

	if (inverse == 1'b0) // FFT// FFT
		tw_imag_1r <= tw_imag[1];
	else// Inverse FFT
		tw_imag_1r <= -tw_imag[1];
end
//--------  1st+1 pipeline  ------------
always@(posedge clk) begin
	t_r_2_p0 <= tw_real_1r * tw_real_1r;
	t_r_2_p1 <= tw_imag_1r * tw_imag_1r;
	t_i_2    <= tw_real_1r * tw_imag_1r;

	tw_real_1_r0 <= tw_real_1r;
	tw_imag_1_r0 <= tw_imag_1r;
end
assign t_r[2] = t_r_2_p0 - t_r_2_p1;
assign t_i[2] = t_i_2;
assign tw_real[2] = (factor==3'd2)? 16'sd16384 : t_r[2][29:14];
assign tw_imag[2] = (factor==3'd2)? 16'sd0     : t_i[2][28:13];

//-------- 3rd pipe ---
logic signed [15:0]  tw_real_2r,  tw_imag_2r;
logic signed [15:0]  tw_real_1_r0_r, tw_imag_1_r0_r;
always@(posedge clk) begin
	tw_real_2r <= tw_real[2];
	tw_imag_2r <= tw_imag[2];
	tw_real_1_r0_r <= tw_real_1_r0;
	tw_imag_1_r0_r <= tw_imag_1_r0;
end
//--------  2nd+2 pipeline  ------------
always@(posedge clk) begin
	t_r_3_p0 <= tw_real_1_r0_r * tw_real_2r;
	t_r_3_p1 <= tw_imag_1_r0_r * tw_imag_2r;
	t_i_3_p0 <= tw_real_1_r0_r * tw_imag_2r;
	t_i_3_p1 <= tw_imag_1_r0_r * tw_real_2r;
	t_r_4_p0 <= tw_real_2r * tw_real_2r;
	t_r_4_p1 <= tw_imag_2r * tw_imag_2r;
	t_i_4    <= tw_real_2r * tw_imag_2r;

	tw_real_1_r1 <= tw_real_1_r0_r;
	tw_imag_1_r1 <= tw_imag_1_r0_r;
	tw_real_2_r0 <= tw_real_2r;
	tw_imag_2_r0 <= tw_imag_2r;	
end
assign t_r[3] = t_r_3_p0 - t_r_3_p1;
assign t_i[3] = t_i_3_p0 + t_i_3_p1;
assign t_r[4] = t_r_4_p0 - t_r_4_p1;
assign t_i[4] = t_i_4;

//--------  3rd+2 pipeline  ------------
always@(posedge clk) begin
	tw_real[3] <= (factor==3'd2)? tw_real_1_r1: t_r[3][29:14];
	tw_imag[3] <= (factor==3'd2)? tw_imag_1_r1: t_i[3][29:14];
	tw_real[4] <= t_r[4][29:14];
	tw_imag[4] <= t_i[4][28:13];

	tw_real_1_r2 <= tw_real_1_r1;
	tw_imag_1_r2 <= tw_imag_1_r1;
	tw_real_2_r1 <= tw_real_2_r0;
	tw_imag_2_r1 <= tw_imag_2_r0;
end

// wire signed [15:0] tw_real_dly [1:4];
// wire signed [15:0] tw_imag_dly [1:4];
// assign tw_real_dly[1] = tw_real_1_r2;
// assign tw_imag_dly[1] = tw_imag_1_r2;
// assign tw_real_dly[2] = tw_real_2_r1;
// assign tw_imag_dly[2] = tw_imag_2_r1;
// assign tw_real_dly[3] = tw_real[3];
// assign tw_imag_dly[3] = tw_imag[3];
// assign tw_real_dly[4] = tw_real[4];
// assign tw_imag_dly[4] = tw_imag[4];

logic signed [15:0] tw_real_dly [1:4];
logic signed [15:0] tw_imag_dly [1:4];
always@(posedge clk) begin
	tw_real_dly[1] <= tw_real_1_r2;
	tw_imag_dly[1] <= tw_imag_1_r2;
	tw_real_dly[2] <= tw_real_2_r1;
	tw_imag_dly[2] <= tw_imag_2_r1;
	tw_real_dly[3] <= tw_real[3];
	tw_imag_dly[3] <= tw_imag[3];
	tw_real_dly[4] <= tw_real[4];
	tw_imag_dly[4] <= tw_imag[4];
end

logic signed [wDataInOut-1:0]  d_real_r_r [0:4];
logic signed [wDataInOut-1:0]  d_imag_r_r [0:4];
always@(posedge clk) begin
	for (j=0; j<=4; j++) begin
		d_real_r_r[j] <= d_real_r[j];
		d_imag_r_r[j] <= d_imag_r[j];
	end
	for (j=1; j<=4; j++) begin
		dout_real_t_p0[j] <= d_real_r_r[j]*tw_real_dly[j];  
		dout_real_t_p1[j] <= d_imag_r_r[j]*tw_imag_dly[j];
		dout_imag_t_p0[j] <= d_real_r_r[j]*tw_imag_dly[j];
		dout_imag_t_p1[j] <= d_imag_r_r[j]*tw_real_dly[j]; // 1.17*2.14
	end
end


// assign tw_real_An = An;
generate
for (i=1; i<5; i++) begin : gen1
always@(posedge clk)
begin
	if (!rst_n)  
	begin
		dout_real_t[i] <= 0;
		dout_imag_t[i] <= 0;
	end
	else
	begin
		if (twdl_demontr==12'd3) begin
			if (in_val) begin
				// dout_real_t[i] <= din_real[i]*tw_real_An; 
				dout_real_t[i] <= { {2{din_real[i][17]}}, din_real[i], 14'b0}; 
				dout_imag_t[i] <= { {2{din_imag[i][17]}}, din_imag[i], 14'b0};
			end
			else begin
				dout_real_t[i] <= 0;
				dout_imag_t[i] <= 0;
			end
			// dout_real_t_p0[i] <= 0;
			// dout_real_t_p1[i] <= 0;
			// dout_imag_t_p0[i] <= 0;
			// dout_imag_t_p1[i] <= 0;
		end
		else begin
			// if (valid_r[delay_twdl-6+3]) begin
			// 	// dout_real_t[i] <= d_real_r[i][delay_twdl-5]*tw_real[i] 
			// 	//                   - d_imag_r[i][delay_twdl-5]*tw_imag[i];
			// 	// dout_imag_t[i] <= d_real_r[i][delay_twdl-5]*tw_imag[i] 
			// 	//                   + d_imag_r[i][delay_twdl-5]*tw_real[i];
			// 	dout_real_t_p0[i] <= d_real_r_r[i]*tw_real_dly[i];  
			// 	dout_real_t_p1[i] <= d_imag_r_r[i]*tw_imag_dly[i];
			// 	dout_imag_t_p0[i] <= d_real_r_r[i]*tw_imag_dly[i];
			// 	dout_imag_t_p1[i] <= d_imag_r_r[i]*tw_real_dly[i]; // 1.17*2.14
			// end
			// else begin
			// 	dout_real_t_p0[i] <= 0;
			// 	dout_real_t_p1[i] <= 0;
			// 	dout_imag_t_p0[i] <= 0;
			// 	dout_imag_t_p1[i] <= 0;
			// end
			dout_real_t[i] <= dout_real_t_p0[i] - dout_real_t_p1[i];
			dout_imag_t[i] <= dout_imag_t_p0[i] + dout_imag_t_p1[i];
		end
	end
end

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
always@(posedge clk)
begin
	if (!rst_n)  
	begin
		dout_real[0] <= 0;
		dout_imag[0] <= 0;
		d_real_r2 <= 0;
		d_imag_r2 <= 0;
	end
	else
	begin
		if (twdl_demontr==12'd3) begin
			if (in_val) begin
				// dout_real_t[i] <= din_real[i]*tw_real_An; 
				dout_real[0] <= din_real[0]; 
				dout_imag[0] <= din_imag[0];
			end
			else begin
				dout_real[0] <= 0;
				dout_imag[0] <= 0;
			end
		end
		else begin
			if  (  ((factor==3'd3 || factor==3'd5) && valid_r[delay_twdl-5+3] ) 
				|| ((factor==3'd4 || factor==3'd2) && valid_r[delay_twdl_42-5+3])  )
			begin
				dout_real[0] <= d_real_r2; 
				dout_imag[0] <= d_imag_r2;
			end
			else begin
				dout_real[0] <= 0;
				dout_imag[0] <= 0;
			end
		end
		d_real_r2 <= d_real_r_r[0];
		d_imag_r2 <= d_imag_r_r[0];
	end
end

always@(*) begin
	if (factor==3'd3 || factor==3'd5)
		rdreq_ff_addr = (twdl_demontr==12'd3)? in_val : valid_r[delay_twdl-5+3];
	else
		rdreq_ff_addr = (twdl_demontr==12'd3)? in_val : valid_r[delay_twdl_42-5+3];
end

assign sclr_ff_addr = sclr;

endmodule