module twdl_PFA #(parameter
	wDataInOut = 30
	)
 (
	input clk,    
	input rst_n,  

	input [2:0]  factor;
	input [7:0]  tw_ROM_addr_step;
	input [7:0]  tw_ROM_exp_ceil;
	input [7:0]  tw_ROM_exp_time;

	input  in_val;
	input  [0:4][wDataInOut-1:0]  din_real;
	input  [0:4][wDataInOut-1:0]  din_imag;

	output  out_val;
	output [0:4][wDataInOut-1:0]  dout_real;
	output [0:4][wDataInOut-1:0]  dout_imag
);

logic [7:0]  n_tw, cnt_n_tw;

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
			if ((n_tw==tw_ROM_exp_ceil-'d1) &&(cnt_n_tw==tw_ROM_exp_time-'d1))
			begin
				n_tw <= 0;
				cnt_n_tw <= 0;
			end
			else if (cnt_n_tw==tw_ROM_exp_time-'d1)
			begin
				n_tw <= n_tw + 'd1;
				cnt_n_tw <= 0;
			end
			else
			begin
				n_tw <= n_tw;
				cnt_n_tw <= cnt_n_tw + 'd1;
			end
		end
	end
end

genvar i;

assign wraddr[0] = 0;
generate
for (i=3'd0; i<3'd5; i=i+3'd1)
	assign wraddr[i] = tw_ROM_addr_step*n_tw*(i-3'd1);
endgenerate

generate
for (i=0; i<5; i++) begin : twdl_ROM
mrd_ROM_fake 
mrd_ROM_fake_0(
	.clk  (clk),

	.factor  (factor),
	.wraddr  (wraddr[i]),

	.dout_real  (tw_real[i]),
	.dout_imag  (tw_imag[i])
);
end
endgenerate

endmodule