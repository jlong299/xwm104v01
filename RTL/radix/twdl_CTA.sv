module twdl_CTA #(parameter
	wDataInOut = 30,
	delay_twdl = 23
	)
 (
	input clk,    
	input rst_n,  

	input [2:0]  factor,
	input [0:4][11:0]  twdl_numrtr,
	input [11:0]  twdl_demontr,

	input  in_val,
	input  signed [wDataInOut-1:0]  din_real [0:4],
	input  signed [wDataInOut-1:0]  din_imag [0:4],

	output logic out_val,
	output logic signed [wDataInOut-1:0]  dout_real [0:4],
	output logic signed [wDataInOut-1:0]  dout_imag [0:4]
);

parameter  wDataTemp = 49;
logic [delay_twdl-2:0]  valid_r;
logic [0:4][7:0] rdaddr;
logic signed [15:0] tw_real [0:4]; 
logic signed [15:0] tw_imag [0:4]; 
logic signed [wDataTemp-1:0] dout_real_t [0:4];
logic signed [wDataTemp-1:0] dout_imag_t [0:4];
logic signed [wDataInOut-1:0]  d_real_r [0:4];
logic signed [wDataInOut-1:0]  d_imag_r [0:4];
logic signed [wDataInOut-1:0]  d_real_r2, d_imag_r2;
logic signed [15:0] tw_real_An;
logic signed [wDataTemp-1:0] dout_real_t_p0 [1:4];
logic signed [wDataTemp-1:0] dout_real_t_p1 [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p0 [1:4];
logic signed [wDataTemp-1:0] dout_imag_t_p1 [1:4];

genvar i;
integer j;
// generate
// for (i=0; i<5; i++) begin : gen0
// always@(posedge clk)
// begin
// 	if (!rst_n)  begin
// 		for (j=0; j<=delay_twdl-4; j++) begin
// 			d_real_r[i][j] <= 0;
// 			d_imag_r[i][j] <= 0;
// 		end
// 	end
// 	else begin
// 		for (j=1; j<=delay_twdl-4; j++) begin
// 			d_real_r[i][j] <= d_real_r[i][j-1];
// 			d_imag_r[i][j] <= d_imag_r[i][j-1];
// 		end
// 			d_real_r[i][0] <= din_real[i];
// 			d_imag_r[i][0] <= din_imag[i];
// 	end
// end
// end
// endgenerate

logic sclr;
assign sclr = valid_r[delay_twdl-2] & (!valid_r[delay_twdl-3]);
generate
for (i=0; i<5; i++) begin : gen0

	ff_rdx_data ff_inst (
		.data  ({din_real[i], din_imag[i]}),  //  fifo_input.datain
		.wrreq (in_val), //            .wrreq
		.rdreq (valid_r[delay_twdl-7]), //            .rdreq
		.clock (clk), //            .clk
		.sclr  (sclr),  //            .sclr
		.q     ({d_real_r[i], d_imag_r[i]})      // fifo_output.dataout
	);

end
endgenerate

always@(posedge clk) begin
	if (twdl_demontr==12'd3)
		out_val <= in_val;
	else
		out_val <= valid_r[delay_twdl-5] ;
end
always@(posedge clk)
begin
	if (!rst_n)  valid_r <= 0;
	else	valid_r <= {valid_r[delay_twdl-3:0], in_val};
end

localparam An = 16384;
localparam An_adj = 16384/1.647;
generate
for (i=1; i<5; i++) begin : ctc
coeff_twdl_CTA #(
	.wDataIn (12),
	.wDataOut (16),
	.An (An_adj)
	)
coeff_twdl_CTA_inst	(
	.clk (clk),
	.rst_n (rst_n),

	.numerator (twdl_numrtr[i]),
	.demoninator (twdl_demontr),

	.dout_real (tw_real[i]),
	.dout_imag (tw_imag[i])
);
end
endgenerate

assign tw_real_An = An;
generate
for (i=1; i<5; i++) begin : gen1
always@(posedge clk)
begin
	if (!rst_n)  
	begin
		dout_real_t_p0[i] <= 0;
		dout_real_t_p1[i] <= 0;
		dout_imag_t_p0[i] <= 0;
		dout_imag_t_p1[i] <= 0;
	end
	else
	begin
		if (twdl_demontr==12'd3) begin
			if (in_val) begin
				// dout_real_t[i] <= din_real[i]*tw_real_An; 
				dout_real_t[i] <= din_real[i] <<< 14; 
				dout_imag_t[i] <= din_imag[i] <<< 14;
			end
			else begin
				dout_real_t[i] <= 0;
				dout_imag_t[i] <= 0;
			end
			dout_real_t_p0[i] <= 0;
			dout_real_t_p1[i] <= 0;
			dout_imag_t_p0[i] <= 0;
			dout_imag_t_p1[i] <= 0;
		end
		else begin
			if (valid_r[delay_twdl-6]) begin
				// dout_real_t[i] <= d_real_r[i][delay_twdl-5]*tw_real[i] 
				//                   - d_imag_r[i][delay_twdl-5]*tw_imag[i];
				// dout_imag_t[i] <= d_real_r[i][delay_twdl-5]*tw_imag[i] 
				//                   + d_imag_r[i][delay_twdl-5]*tw_real[i];
				dout_real_t_p0[i] <= d_real_r[i]*tw_real[i];
				dout_real_t_p1[i] <= d_imag_r[i]*tw_imag[i];
				dout_imag_t_p0[i] <= d_real_r[i]*tw_imag[i];
				dout_imag_t_p1[i] <= d_imag_r[i]*tw_real[i];
			end
			else begin
				dout_real_t_p0[i] <= 0;
				dout_real_t_p1[i] <= 0;
				dout_imag_t_p0[i] <= 0;
				dout_imag_t_p1[i] <= 0;
			end
			dout_real_t[i] <= dout_real_t_p0[i] - dout_real_t_p1[i];
			dout_imag_t[i] <= dout_imag_t_p0[i] + dout_imag_t_p1[i];
		end
	end
end

assign dout_real[i] = (dout_real_t[i][13])? 
                      dout_real_t[i][wDataInOut+14-1:14] + 2'sd1
                      : dout_real_t[i][wDataInOut+14-1:14] ;
assign dout_imag[i] = (dout_imag_t[i][13])? 
                      dout_imag_t[i][wDataInOut+14-1:14] + 2'sd1
                      : dout_imag_t[i][wDataInOut+14-1:14] ;
end
endgenerate

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
			if (valid_r[delay_twdl-5]) begin
				dout_real[0] <= d_real_r2; 
				dout_imag[0] <= d_imag_r2;
			end
			else begin
				dout_real[0] <= 0;
				dout_imag[0] <= 0;
			end
		end
		d_real_r2 <= d_real_r[0];
		d_imag_r2 <= d_imag_r[0];
	end
end


endmodule