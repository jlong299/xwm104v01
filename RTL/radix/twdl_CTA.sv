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
	output signed [wDataInOut-1:0]  dout_real [0:4],
	output signed [wDataInOut-1:0]  dout_imag [0:4]
);

parameter  wDataTemp = 49;
logic [delay_twdl-4:0]  valid_r;
logic [0:4][7:0] rdaddr;
logic signed [15:0] tw_real [0:4]; 
logic signed [15:0] tw_imag [0:4]; 
logic signed [wDataTemp-1:0] dout_real_t [0:4];
logic signed [wDataTemp-1:0] dout_imag_t [0:4];
logic signed [wDataInOut-1:0]  d_real_r [0:4][delay_twdl-4:0];
logic signed [wDataInOut-1:0]  d_imag_r [0:4][delay_twdl-4:0];
logic signed [15:0] tw_real_An;

genvar i;
integer j;
generate
for (i=0; i<5; i++) begin
always@(posedge clk)
begin
	if (!rst_n)  begin
		for (j=0; j<=delay_twdl-4; j++) begin
			d_real_r[i][j] <= 0;
			d_imag_r[i][j] <= 0;
		end
	end
	else begin
		for (j=1; j<=delay_twdl-4; j++) begin
			d_real_r[i][j] <= d_real_r[i][j-1];
			d_imag_r[i][j] <= d_imag_r[i][j-1];
		end
			d_real_r[i][0] <= din_real[i];
			d_imag_r[i][0] <= din_imag[i];
	end
end
end
endgenerate

// always@(posedge clk) out_val <= (factor==3'd4 || factor==3'd2)? 
//                      valid_r[delay_twdl-1] : valid_r[delay_twdl-2-1] ;
always@(posedge clk) begin
	if (twdl_demontr==12'd3)
		out_val <= valid_r[0];
	else
		out_val <= valid_r[delay_twdl-4] ;
end
always@(posedge clk)
begin
	if (!rst_n)  valid_r <= 0;
	else	valid_r <= {valid_r[delay_twdl-5:0], in_val};
end

localparam An = 16384;
localparam An_adj = 16384/1.647;
generate
for (i=0; i<5; i++) begin : ctc
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
for (i=0; i<5; i++) begin
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
			if (valid_r[0]) begin
				dout_real_t[i] <= din_real[i]*tw_real_An; 
				dout_imag_t[i] <= din_imag[i]*tw_real_An;
			end
			else begin
				dout_real_t[i] <= 0;
				dout_imag_t[i] <= 0;
			end
		end
		else begin
			if (valid_r[delay_twdl-4]) begin
				dout_real_t[i] <= d_real_r[i][delay_twdl-5]*tw_real[i] 
				                  - d_imag_r[i][delay_twdl-5]*tw_imag[i];
				dout_imag_t[i] <= d_real_r[i][delay_twdl-5]*tw_imag[i] 
				                  + d_imag_r[i][delay_twdl-5]*tw_real[i];
			end
			else begin
				dout_real_t[i] <= 0;
				dout_imag_t[i] <= 0;
			end
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

endmodule