module mrd_rdx2345_twdl (
	input clk,    
	input rst_n,  

	input sop,
	mrd_rdx2345_if from_mem,
	mrd_rdx2345_if to_mem
);

localparam  wDFTout = 18;
localparam  wDFTin = 18;

// localparam  delay_twdl = 25;
localparam  delay_twdl = 25+8+2-2-3;

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

logic [1:0] margin_in, margin_out;

logic [3:0] exp_out, exp_in;
logic [3:0] exp_out_rdx4;
logic [3:0] exp_out_rdx3;
logic [3:0] exp_out_rdx5;
	
	// integer wr_file;
	// initial begin
	// 	wr_file = $fopen("rdx2345_result.dat","w");
	// 	if (wr_file == 0) begin
	// 		$display("rdx2345_result handle was NULL");
	// 		$finish;
	// 	end
	// end

wire [54:0] ff_data, q;
wire sclr_ff_addr, rdreq_ff_addr;
assign ff_data[10:0] = {from_mem.bank_index[0],from_mem.bank_addr[0]};
assign ff_data[21:11] = {from_mem.bank_index[1],from_mem.bank_addr[1]};
assign ff_data[32:22] = {from_mem.bank_index[2],from_mem.bank_addr[2]};
assign ff_data[43:33] = {from_mem.bank_index[3],from_mem.bank_addr[3]};
assign ff_data[54:44] = {from_mem.bank_index[4],from_mem.bank_addr[4]};
ff_rdx_index ff_index (
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

logic from_mem_valid;
logic signed [18-1:0] from_mem_d_real [0:4];
logic signed [18-1:0] from_mem_d_imag [0:4];
logic [2:0] from_mem_factor;
always@(posedge clk) begin
	from_mem_valid <= from_mem.valid;
	from_mem_d_real <= from_mem.d_real;
	from_mem_d_imag <= from_mem.d_imag;
	from_mem_factor <= from_mem.factor;
end

mrd_rdx4_2_v2
rdx4_2_v2 (
	.clk  (clk),
	.rst_n  (rst_n),

	.in_val  (from_mem_valid),
	.din_real  (from_mem_d_real),
	.din_imag  (from_mem_d_imag),
	.factor (from_mem_factor),

	.margin_in (margin_in),
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

	.in_val  (from_mem_valid),
	.din_real  (from_mem_d_real),
	.din_imag  (from_mem_d_imag),

	.margin_in (margin_in),
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

	.in_val  (from_mem_valid),
	.din_real  (from_mem_d_real),
	.din_imag  (from_mem_d_imag),

	.margin_in (margin_in),
	.exp_in (exp_in),

	.out_val  (val_rdx3),
	.dout_real  (real_rdx3),
	.dout_imag  (imag_rdx3),
	.exp_out (exp_out_rdx3)
	);


genvar i;
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
assign to_mem.exp = exp_in;
always@(posedge clk) dft_val_r <= dft_val;

twdl_CTA #(
	.wDataInOut (18),
	.delay_twdl (delay_twdl)
	) 
twdl (
	.clk  (clk),
	.rst_n  (rst_n),

	.factor  (from_mem.factor),
	.twdl_numrtr_1  (from_mem.twdl_numrtr_1),
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

//------------- margin_out,  margin_in --------------
logic [1:0] valid_r;
logic signed [18-1:0] abs_real [0:4];
logic signed [18-1:0] abs_imag [0:4];
generate
for (i=0; i<=4; i++) begin : temp0
	assign abs_real[i] = (to_mem.d_real[i][17])? (-to_mem.d_real[i]) : to_mem.d_real[i];
	assign abs_imag[i] = (to_mem.d_imag[i][17])? (-to_mem.d_imag[i]) : to_mem.d_imag[i];
end
logic unsigned [1:0] margin_real [0:4];
logic unsigned [1:0] margin_imag [0:4];
logic unsigned [1:0] min_margin;
endgenerate
always@(posedge clk) begin
	if (!rst_n) begin
		margin_in <= 0;
		margin_out <= 0;
		valid_r <= 0;
		for (j=0; j<=4; j++) begin
			margin_real[j] <= 0;
			margin_imag[j] <= 0;
		end
	end
	else begin
		for (j=0; j<=4; j++) begin
			if (abs_real[j][17:16]==2'b01) margin_real[j] <= 2'd0;
			else if (abs_real[j][17:15]==3'b001) margin_real[j] <= 2'd1;
			else if (abs_real[j][17:14]==4'b0001) margin_real[j] <= 2'd2;
			else margin_real[j] <= 2'd3;

			if (abs_imag[j][17:16]==2'b01) margin_imag[j] <= 2'd0;
			else if (abs_imag[j][17:15]==3'b001) margin_imag[j] <= 2'd1;
			else if (abs_imag[j][17:14]==4'b0001) margin_imag[j] <= 2'd2;
			else margin_imag[j] <= 2'd3;
		end

		valid_r <= {valid_r[0], to_mem.valid};
		if (valid_r[0]==1'b0 && to_mem.valid)
			margin_out <= 2'b11;
		else if (valid_r[0])
			margin_out <= (min_margin < margin_out)? min_margin : margin_out;
		else
			margin_out <= 0;

		margin_in <= (valid_r==2'b10)? margin_out : margin_in;
	end
end


logic unsigned [1:0] max_t0 [0:4];
logic unsigned [1:0] max_t10, max_t11, max_t20;
always@(*) begin
	for (j=0; j<=4; j++) 
		max_t0[j] = (margin_real[j] < margin_imag[j])? margin_real[j] : margin_imag[j];

	max_t10 = (max_t0[0] < max_t0[1])? max_t0[0] : max_t0[1];
	max_t11 = (max_t0[2] < max_t0[3])? max_t0[2] : max_t0[3];
	max_t20 = (max_t10 < max_t11)? max_t10 : max_t11;
	min_margin = (max_t20 < max_t0[4])? max_t20 : max_t0[4];
end


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