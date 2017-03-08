module mrd_rdx2345_twdl (
	input clk,    
	input rst_n,  

	input sop,
	mrd_rdx2345_if from_mem,
	mrd_rdx2345_if to_mem
);

localparam  wDFTout = 18;
localparam  wDFTin = 18;

localparam  delay_twdl = 25;

// logic [0:4][2:0]  bank_index_r [0 : delay_twdl-1];
// logic [0:4][7:0]  bank_addr_r [0 : delay_twdl-1];
logic dft_val;
logic signed [18-1:0] dft_real [0:4];
logic signed [18-1:0] dft_imag [0:4];
logic val_rdx4;
logic signed [18-1:0] real_rdx4 [0:4];
logic signed [18-1:0] imag_rdx4 [0:4];

logic val_rdx5;
logic signed [18-1:0] real_rdx5 [0:4];
logic signed [18-1:0] imag_rdx5 [0:4];

logic val_rdx3;
logic signed [18-1:0] real_rdx3 [0:4];
logic signed [18-1:0] imag_rdx3 [0:4];

logic val_rdx2;
logic signed [18-1:0] real_rdx2 [0:4];
logic signed [18-1:0] imag_rdx2 [0:4];
	
	// integer wr_file;
	// initial begin
	// 	wr_file = $fopen("rdx2345_result.dat","w");
	// 	if (wr_file == 0) begin
	// 		$display("rdx2345_result handle was NULL");
	// 		$finish;
	// 	end
	// end

wire [59:0] ff_data, q;
wire sclr_ff_addr, rdreq_ff_addr;
assign ff_data[10:0] = {from_mem.bank_index[0],from_mem.bank_addr[0]};
assign ff_data[21:11] = {from_mem.bank_index[1],from_mem.bank_addr[1]};
assign ff_data[32:22] = {from_mem.bank_index[2],from_mem.bank_addr[2]};
assign ff_data[43:33] = {from_mem.bank_index[3],from_mem.bank_addr[3]};
assign ff_data[54:44] = {from_mem.bank_index[4],from_mem.bank_addr[4]};
assign ff_data[59:55] = 0;
ff_rdx_data ff_addr (
		.data  (ff_data),  //  fifo_input.datain
		.wrreq (from_mem.valid), //            .wrreq
		.rdreq (rdreq_ff_addr), //            .rdreq
		.clock (clk), //            .clk
		.sclr  (sclr_ff_addr),  //            .sclr
		.q     (q)      // fifo_output.dataout
	);
assign {to_mem.bank_index[0],to_mem.bank_addr[0]} = q[10:0];
assign {to_mem.bank_index[1],to_mem.bank_addr[1]} = q[21:11];
assign {to_mem.bank_index[2],to_mem.bank_addr[2]} = q[32:22];
assign {to_mem.bank_index[3],to_mem.bank_addr[3]} = q[43:33];
assign {to_mem.bank_index[4],to_mem.bank_addr[4]} = q[54:44];


// mrd_dft_rdx4 #(
// 	.wDataInOut (30)
// 	)
// dft_rdx4 (
// 	.clk  (clk),
// 	.rst_n  (rst_n),

// 	.in_val  (from_mem.valid),
// 	.din_real  (from_mem.d_real),
// 	.din_imag  (from_mem.d_imag),

// 	.out_val  (val_rdx4),
// 	.dout_real  (real_rdx4),
// 	.dout_imag  (imag_rdx4)
// 	);

// mrd_dft_rdx5 #(
// 	.wDataInOut (30)
// 	)
// dft_rdx5 (
// 	.clk  (clk),
// 	.rst_n  (rst_n),

// 	.in_val  (from_mem.valid),
// 	.din_real  (from_mem.d_real),
// 	.din_imag  (from_mem.d_imag),

// 	.out_val  (val_rdx5),
// 	.dout_real  (real_rdx5),
// 	.dout_imag  (imag_rdx5)
// 	);

// mrd_dft_rdx3 #(
// 	.wDataInOut (30)
// 	)
// dft_rdx3 (
// 	.clk  (clk),
// 	.rst_n  (rst_n),

// 	.in_val  (from_mem.valid),
// 	.din_real  (from_mem.d_real),
// 	.din_imag  (from_mem.d_imag),

// 	.out_val  (val_rdx3),
// 	.dout_real  (real_rdx3),
// 	.dout_imag  (imag_rdx3)
// 	);

// mrd_dft_rdx2 #(
// 	.wDataInOut (30)
// 	)
// dft_rdx2 (
// 	.clk  (clk),
// 	.rst_n  (rst_n),

// 	.in_val  (from_mem.valid),
// 	.din_real  (from_mem.d_real),
// 	.din_imag  (from_mem.d_imag),

// 	.out_val  (val_rdx2),
// 	.dout_real  (real_rdx2),
// 	.dout_imag  (imag_rdx2)
// 	);



logic [3:0] exp_out, exp_in;
logic [3:0] exp_out_rdx4;
logic [3:0] exp_out_rdx3;
logic [3:0] exp_out_rdx5;

mrd_rdx4_2_v2
rdx4_2_v2 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),
	.factor (from_mem.factor),

	.margin_in (2'b00),
	.exp_in (exp_in),

	.out_val  (val_rdx4),
	.dout_real  (real_rdx4),
	.dout_imag  (imag_rdx4),
	.exp_out (exp_out_rdx4)
	);

mrd_rdx5_v2 
rdx5_v2 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),

	.margin_in (2'b00),
	.exp_in (exp_in),

	.out_val  (val_rdx5),
	.dout_real  (real_rdx5),
	.dout_imag  (imag_rdx5),
	.exp_out (exp_out_rdx5)
	);

mrd_rdx3_v2 
rdx3_v2 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem.valid),
	.din_real  (from_mem.d_real),
	.din_imag  (from_mem.d_imag),

	.margin_in (2'b00),
	.exp_in (exp_in),

	.out_val  (val_rdx3),
	.dout_real  (real_rdx3),
	.dout_imag  (imag_rdx3),
	.exp_out (exp_out_rdx3)
	);

// always@(posedge clk)
// begin
// 	case (from_mem.factor)
// 	3'd4 : begin
// 		dft_real <= real_rdx4;
// 		dft_imag <= imag_rdx4;
//  		dft_val <= val_rdx4;
// 	end
// 	3'd5 : begin
// 		dft_real <= real_rdx5;
// 		dft_imag <= imag_rdx5;
//  		dft_val <= val_rdx5;
// 	end
// 	3'd3 : begin
// 		dft_real <= real_rdx3;
// 		dft_imag <= imag_rdx3;
//  		dft_val <= val_rdx3;
// 	end
// 	default : begin
// 		dft_real <= real_rdx2;
// 		dft_imag <= imag_rdx2;
//  		dft_val <= val_rdx2;
// 	end
// 	endcase
// end

integer j;
always@(*)
begin
	case (from_mem.factor)
	3'd4 : begin
		dft_real = real_rdx4;
		dft_imag = imag_rdx4;
 		dft_val = val_rdx4;
 		exp_out = exp_out_rdx4;
	end
	3'd5 : begin
		dft_real = real_rdx5;
		dft_imag = imag_rdx5;
 		dft_val = val_rdx5;
 		exp_out = exp_out_rdx5;
	end
	3'd3 : begin
		dft_real = real_rdx3;
		dft_imag = imag_rdx3;
 		dft_val = val_rdx3;
 		exp_out = exp_out_rdx3;
	end
	default : begin
		dft_real = real_rdx4;
		dft_imag = imag_rdx4;
 		dft_val = val_rdx4;
 		exp_out = exp_out_rdx4;
	end
	endcase
end

logic dft_val_r;
always@(posedge clk) begin
if (!rst_n) exp_in <= 0;
else
	if (sop)  exp_in <= 0; 
	else exp_in <= ( dft_val & ~dft_val_r)? exp_out : exp_in;
end
always@(posedge clk) to_mem.exp <= exp_in;
always@(posedge clk) dft_val_r <= dft_val;

twdl_CTA #(
	.wDataInOut (18),
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
	.dout_imag  (to_mem.d_imag),
	
	.sclr_ff_addr (sclr_ff_addr),
	.rdreq_ff_addr (rdreq_ff_addr)
	);

// logic [15:0]  cnt_val_debug;
// always@(posedge clk)
// 	begin
// 		if (!rst_n)
// 			cnt_val_debug <= 0;
// 		else
// 		begin
// 				if (to_mem.valid && cnt_val_debug != 16'd841)
// 				begin
// 					cnt_val_debug <= cnt_val_debug + 'd1;
// 					if (cnt_val_debug >= 600) begin
// 					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[0]), $signed(to_mem.d_imag[0]));
// 					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[1]), $signed(to_mem.d_imag[1]));
// 					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[2]), $signed(to_mem.d_imag[2]));
// 					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[3]), $signed(to_mem.d_imag[3]));
// 					$fwrite(wr_file, "%d %d\n", $signed(to_mem.d_real[4]), $signed(to_mem.d_imag[4]));
// 					end
// 				end

// 				if (cnt_val_debug==16'd840)  
// 				begin
// 					$fclose(wr_file);
// 					cnt_val_debug <= 16'd841;
// 				end
// 		end

// 	end

endmodule