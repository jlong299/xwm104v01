module mrd_rdx2345_twdl (
	input clk,    
	input rst_n,  

	mrd_rdx2345_if from_mem,
	mrd_rdx2345_if to_mem
);

localparam  wDFTout = 30;
localparam  wDFTin = 30;

logic dft_val;
logic signed [0:4][wDFTout-1:0] dft_real, dft_imag;
logic val_rdx4;
logic signed [0:4][wDFTout-1:0] real_rdx4, imag_rdx4;

always@(posedge clk)
begin
	to_mem.bank_index <= from_mem.bank_index;
	to_mem.bank_addr <= from_mem.bank_addr;
end


mrd_dft_rdx4 #(
	.wDataInOut (30)
	)
dft_rdx4 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),

	.out_val  (val_rdx4),
	.dout_real  (real_rdx4),
	.dout_imag  (imag_rdx4)
	);

always@(posedge clk)
begin
	dft_val <= val_rdx4;
	dft_real <= real_rdx4;
	dft_imag <= imag_rdx4;
end

twdl_PFA #(
	.wDataInOut (30)
	) 
twdl (
	.clk  (clk),
	.rst_n  (rst_n),

	.factor  (from_mem.factor),
	.tw_ROM_addr_step  (from_mem.tw_ROM_addr_step),
	.tw_ROM_exp_ceil  (from_mem.tw_ROM_exp_ceil),
	.tw_ROM_exp_time  (from_mem.tw_ROM_exp_time),

	.in_val  (dft_val),
	.din_real  (dft_real),
	.din_imag  (dft_imag),

	.out_val  (to_mem.valid),
	.dout_real  (to_mem.d_real),
	.dout_imag  (to_mem.d_imag)
	);



endmodule