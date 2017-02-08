module mrd_rdx2345_twdl (
	input clk,    
	input rst_n,  

	mrd_rdx2345_if from_mem,
	mrd_rdx2345_if to_mem
);

localparam  wDFTout = 30;
localparam  wDFTin = 30;

localparam  delay_twdl = 23;

logic [0:4][2:0]  bank_index_r [0 : delay_twdl+2];
logic [0:4][7:0]  bank_addr_r [0 : delay_twdl+2];
logic dft_val;
logic signed [wDFTout-1:0] dft_real [0:4];
logic signed [wDFTout-1:0] dft_imag [0:4];
logic val_rdx4;
logic signed [wDFTout-1:0] real_rdx4 [0:4];
logic signed [wDFTout-1:0] imag_rdx4 [0:4];

logic val_rdx5;
logic signed [wDFTout-1:0] real_rdx5 [0:4];
logic signed [wDFTout-1:0] imag_rdx5 [0:4];

logic val_rdx3;
logic signed [wDFTout-1:0] real_rdx3 [0:4];
logic signed [wDFTout-1:0] imag_rdx3 [0:4];
	
	integer wr_file;
	initial begin
		wr_file = $fopen("rdx2345_result.dat","w");
		if (wr_file == 0) begin
			$display("rdx2345_result handle was NULL");
			$finish;
		end
	end



always@(posedge clk)
begin
	bank_index_r[0] <= from_mem.bank_index;
	bank_addr_r[0] <= from_mem.bank_addr;
	bank_index_r[1:delay_twdl+2] <= bank_index_r[0:delay_twdl+1];
	bank_addr_r[1:delay_twdl+2] <= bank_addr_r[0:delay_twdl+1];
end
always@(posedge clk)
begin
	if (from_mem.factor == 3'd4) begin
		to_mem.bank_index <= bank_index_r[delay_twdl];
		to_mem.bank_addr <= bank_addr_r[delay_twdl];
	end
	else if (from_mem.factor == 3'd5) begin
		to_mem.bank_index <= bank_index_r[delay_twdl+0];
		to_mem.bank_addr <= bank_addr_r[delay_twdl+0];
	end
	else begin
		to_mem.bank_index <= bank_index_r[delay_twdl+0];
		to_mem.bank_addr <= bank_addr_r[delay_twdl+0];
	end
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

mrd_dft_rdx5 #(
	.wDataInOut (30)
	)
dft_rdx5 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),

	.out_val  (val_rdx5),
	.dout_real  (real_rdx5),
	.dout_imag  (imag_rdx5)
	);

mrd_dft_rdx3 #(
	.wDataInOut (30)
	)
dft_rdx3 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),

	.out_val  (val_rdx3),
	.dout_real  (real_rdx3),
	.dout_imag  (imag_rdx3)
	);

always@(*)
begin
	if (from_mem.factor == 3'd4)
 		dft_val = val_rdx4;
 	else if (from_mem.factor == 3'd5)
 		dft_val = val_rdx5;
 	else
 		dft_val = val_rdx3;
end
always@(posedge clk)
begin
	if (from_mem.factor == 3'd4) begin
		dft_real <= real_rdx4;
		dft_imag <= imag_rdx4;
	end
	else if (from_mem.factor == 3'd5) begin
		dft_real <= real_rdx5;
		dft_imag <= imag_rdx5;
	end
	else begin
		dft_real <= real_rdx3;
		dft_imag <= imag_rdx3;
	end
end

twdl_CTA #(
	.wDataInOut (30),
	.delay_twdl (delay_twdl)
	) 
twdl (
	.clk  (clk),
	.rst_n  (rst_n),

	.factor  (from_mem.factor),
	.twdl_numrtr  (from_mem.twdl_numrtr),
	.twdl_demontr  (from_mem.twdl_demontr),

	.in_val  (dft_val),
	.din_real  (dft_real),
	.din_imag  (dft_imag),

	.out_val  (to_mem.valid),
	.dout_real  (to_mem.d_real),
	.dout_imag  (to_mem.d_imag)
	);

logic [15:0]  cnt_val_debug;
always@(posedge clk)
	begin
		if (!rst_n)
			cnt_val_debug <= 0;
		else
		begin
				if (to_mem.valid && cnt_val_debug != 16'd841)
				begin
					cnt_val_debug <= cnt_val_debug + 'd1;
					if (cnt_val_debug >= 600) begin
					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[0]), $signed(to_mem.d_imag[0]));
					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[1]), $signed(to_mem.d_imag[1]));
					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[2]), $signed(to_mem.d_imag[2]));
					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[3]), $signed(to_mem.d_imag[3]));
					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[4]), $signed(to_mem.d_imag[4]));
					end
				end

				if (cnt_val_debug==16'd840)  
				begin
					$fclose(wr_file);
					cnt_val_debug <= 16'd841;
				end
		end

	end

endmodule