module twdl_PFA #(parameter
	wDataInOut = 30
	)
 (
	input clk,    
	input rst_n,  

	input [2:0]  factor,
	input [7:0]  tw_ROM_addr_step,
	input [7:0]  tw_ROM_exp_ceil,
	input [7:0]  tw_ROM_exp_time,

	input  in_val,
	input  signed [wDataInOut-1:0]  din_real [0:4],
	input  signed [wDataInOut-1:0]  din_imag [0:4],

	output out_val,
	output signed [wDataInOut-1:0]  dout_real [0:4],
	output signed [wDataInOut-1:0]  dout_imag [0:4]
);

parameter  wDataTemp = 49;
logic [7:0]  n_tw, cnt_n_tw;
logic [1:0]  valid_r;
logic [0:4][7:0] rdaddr;
logic signed [17:0] tw_real [0:4]; 
logic signed [17:0] tw_imag [0:4]; 
logic signed [wDataTemp-1:0] dout_real_t [0:4];
logic signed [wDataTemp-1:0] dout_imag_t [0:4];

always@(posedge clk)
begin
	if (!rst_n)
	begin
		n_tw <= 0;
		cnt_n_tw <= 0;
	end
	else
	begin
		if (!in_val)
		begin
			n_tw <= 0;
			cnt_n_tw <= 0;
		end
		else
		begin
			if((n_tw==tw_ROM_exp_ceil-8'd1)&&(cnt_n_tw==tw_ROM_exp_time-8'd1))
			begin
				n_tw <= 0;
				cnt_n_tw <= 0;
			end
			else if (cnt_n_tw==tw_ROM_exp_time-8'd1)
			begin
				n_tw <= n_tw + 8'd1;
				cnt_n_tw <= 0;
			end
			else
			begin
				n_tw <= n_tw;
				cnt_n_tw <= cnt_n_tw + 8'd1;
			end
		end
	end
end

genvar i;

assign rdaddr[0] = 0;
generate
for (i=3'd1; i<3'd5; i=i+3'd1)
	assign rdaddr[i] = tw_ROM_addr_step * n_tw * i;
endgenerate

generate
for (i=0; i<5; i++) begin : twdl_ROM
mrd_ROM_fake 
mrd_ROM_fake_0(
	.clk  (clk),

	.factor  (factor),
	.rdaddr  (rdaddr[i]),

	.dout_real  (tw_real[i]),
	.dout_imag  (tw_imag[i])
);
end
endgenerate

assign out_val = valid_r[1];
always@(posedge clk)
begin
	if (!rst_n)  valid_r <= 0;
	else	valid_r <= {valid_r[0], in_val};
end

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
		if (valid_r[0]) begin
			dout_real_t[i] <= din_real[i]*tw_real[i] - din_imag[i]*tw_imag[i];
			dout_imag_t[i] <= din_real[i]*tw_imag[i] + din_imag[i]*tw_real[i];
		end
		else begin
			dout_real_t[i] <= 0;
			dout_imag_t[i] <= 0;
		end
	end
end

assign dout_real[i] = dout_real_t[i][wDataInOut+16-1:16];
assign dout_imag[i] = dout_imag_t[i][wDataInOut+16-1:16];
end
endgenerate

endmodule