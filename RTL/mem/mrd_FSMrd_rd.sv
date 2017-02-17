module mrd_FSMrd_rd (
	input clk,
	input rst_n,

	input [2:0] fsm,
	input [2:0] fsm_r,

	input [5:0][17:0] din_real_r,
	input [5:0][17:0] din_imag_r,
	input [0:5][2:0] Nf,
	input [0:5][11:0] dftpts_div_Nf,
	input [0:4][11:0] addrs_butterfly_src,
	input [0:5][11:0]  twdl_demontr,

	mrd_ctrl_if ctrl,
	mrd_mem_rd rdRAM_FSMrd,
	mrd_rdx2345_if out_rdx2345_data,

	output logic [2:0] rd_ongoing_r,
	output logic [2:0]  cnt_stage,
	output [0:4][11:0]  twdl_numrtr
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
parameter Rd = 3'd3, Wait_wr_end = 3'd4, Source = 3'd5;

logic [0:4][mrd_mem_pkt::wADDR-1:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr,
                  div7_rmdr_rd;
logic [0:4][11:0]  addrs_butterfly, addrs_butterfly_mux;
logic [11:0] cnt_rd_ongoing, cnt_rd_stop;
logic rd_ongoing;



always@(posedge clk)
begin
	if (!rst_n) 
	begin
		bank_index_rd_r <= 0;
		bank_index_rd_rr <= 0;
		bank_addr_rd_r <= 0;
		bank_addr_rd_rr <= 0;
	end
	else 
	begin
		bank_index_rd_r <= bank_index_rd;
		bank_index_rd_rr <= bank_index_rd_r;
		bank_addr_rd_r <= bank_addr_rd;
		bank_addr_rd_rr <= bank_addr_rd_r;
	end
end

genvar  k;
generate
for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : rden_addr_index
always@(posedge clk)
begin
	if (!rst_n) 
	begin
		rdRAM_FSMrd.rden[k] <= 0;
		rdRAM_FSMrd.rdaddr[k] <= 0;
	end
	else 
	begin
		if (bank_index_rd[0]== k || bank_index_rd[1]== k ||
			bank_index_rd[2]== k || bank_index_rd[3]== k ||
			bank_index_rd[4]== k )
				rdRAM_FSMrd.rden[k] <= 1'b1 & rd_ongoing_r[0];
		else rdRAM_FSMrd.rden[k] <= 1'b0;

		if (bank_index_rd[0]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[4];
		else  rdRAM_FSMrd.rdaddr[k] <= 0;
	end
end
end
endgenerate

generate
	for (k=3'd0; k < 3'd5; k=k+3'd1) begin : addr_banks
	divider_7 divider_7_inst1 (
		.dividend 	(addrs_butterfly_mux[k]),  

		.quotient 	(bank_addr_rd[k]),
		.remainder 	(div7_rmdr_rd[k])
	);
	// index 3'd7 means the index is not valid
	assign bank_index_rd[k] = (k >= Nf[cnt_stage]) ?
	                          3'd7 : div7_rmdr_rd[k];
	end
endgenerate

generate
	for (k=0; k<3; k++) begin : rd_out
	always@(*)
	begin
		out_rdx2345_data.d_real[k] = rdRAM_FSMrd.dout_real[(bank_index_rd_rr[k])]; 
		out_rdx2345_data.d_imag[k] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[k])]; 
	end
	end
endgenerate

always@(*)
begin
	out_rdx2345_data.d_real[3] = (fsm==Rd && cnt_stage==3'd0)?
	        {{(30-18){din_real_r[5][17]}}, din_real_r[5]} : 
	        rdRAM_FSMrd.dout_real[(bank_index_rd_rr[3])]; 
	out_rdx2345_data.d_imag[3] = (fsm==Rd && cnt_stage==3'd0)?
	        {{(30-18){din_imag_r[5][17]}}, din_imag_r[5]} : 
	        rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[3])]; 
	out_rdx2345_data.d_real[4] = rdRAM_FSMrd.dout_real[(bank_index_rd_rr[4])]; 
	out_rdx2345_data.d_imag[4] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[4])]; 
end

assign out_rdx2345_data.valid = rd_ongoing_r[2];
assign out_rdx2345_data.bank_index = bank_index_rd_rr;
assign out_rdx2345_data.bank_addr = bank_addr_rd_rr;
always@(posedge clk) out_rdx2345_data.twdl_numrtr <= twdl_numrtr;
always@(posedge clk) out_rdx2345_data.twdl_demontr <= 
                         twdl_demontr[cnt_stage];

always@(*)
begin
	if (fsm==Rd || fsm==Wait_wr_end)
		out_rdx2345_data.factor = Nf[cnt_stage];
	else
		out_rdx2345_data.factor <= 3'd1;
end

always@(*)
begin
	cnt_rd_stop = dftpts_div_Nf[cnt_stage];
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		rd_ongoing <= 0;
		cnt_rd_ongoing <= 0;
		rd_ongoing_r <= 0;
		cnt_stage <= 0;
	end
	else
	begin

		if (fsm == Rd && fsm_r != Rd)
			cnt_rd_ongoing <= 12'd1;
		else if (cnt_rd_ongoing != 12'd0)
			cnt_rd_ongoing <= (cnt_rd_ongoing==cnt_rd_stop) ? 
		                       12'd0 : cnt_rd_ongoing + 12'd1;
		else
			cnt_rd_ongoing <= 0;

		rd_ongoing <= (cnt_rd_ongoing != 12'd0);
		rd_ongoing_r[0] <= rd_ongoing;
		rd_ongoing_r[2:1] <= rd_ongoing_r[1:0];

		if (fsm==Source) cnt_stage <= 0;
		else cnt_stage <= (fsm==Rd && fsm_r==Wait_wr_end)? 
			               cnt_stage+3'd1 : cnt_stage;
	end
end

CTA_addr_trans #(
		.wDataInOut (12)
	)
CTA_addr_trans_inst	(
	.clk  (clk),    
	.rst_n  (rst_n),  
	.clr_n  (rd_ongoing),
	.Nf  (Nf),
	.current_stage  (cnt_stage),

	.addrs_butterfly  (addrs_butterfly)
	);

generate
	for (k=3'd0; k < 3'd5; k=k+3'd1) begin 
assign addrs_butterfly_mux[k] = (fsm==Rd && cnt_stage < ctrl.NumOfFactors-3'd1)?
                              addrs_butterfly[k] : addrs_butterfly_src[k] ;
    end
endgenerate

CTA_twdl_numrtr #(
		.wDataInOut (12)
	)
CTA_twdl_numrtr_inst	(
	.clk  (clk),    
	.rst_n  (rst_n),  
	.clr_n  (rd_ongoing),
	.Nf  (Nf),
	.current_stage  (cnt_stage),
	.twdl_demontr  (twdl_demontr),

	.twdl_numrtr  (twdl_numrtr)
	);


endmodule