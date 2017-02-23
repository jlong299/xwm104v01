module mrd_FSMsource (
	input clk,
	input rst_n,

	input [2:0] fsm,
	input [2:0] fsm_r,

	input [0:5][2:0] Nf,
	input [2:0]  cnt_stage,
	input [11:0] dftpts,

	mrd_ctrl_if ctrl,
	mrd_mem_rd rdRAM_FSMsource,
	mrd_st_if  out_data,

	output logic [0:4][11:0] addrs_butterfly_src,
	output logic [11:0]  bank_addr_source,
	output logic [2:0] bank_index_source_r,
	output logic fsm_lastRd_source,
	output logic source_end
	
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
parameter Source = 3'd5;

logic clr_n_PFA_addr_o, source_ongoing;
logic [11:0] cnt_source_ongoing;
logic [2:0] bank_index_source;
logic [11:0]  addr_source_CTA;
logic [27:0][11:0]  addr_source_CTA_r;

always@(posedge clk)
begin
	if (!rst_n)
	begin
		clr_n_PFA_addr_o <= 0;
	end
	else
	begin
		if (cnt_source_ongoing == 12'd1)
			clr_n_PFA_addr_o <= 1'b1;
		else if (cnt_source_ongoing == dftpts+'d1)
			clr_n_PFA_addr_o <= 1'b0;
		else
			clr_n_PFA_addr_o <= clr_n_PFA_addr_o;
	end
end

// cnt_stage changes at the same time of rden_r0   (rden_r0 in mrd_FSMrd_rd.v)
assign fsm_lastRd_source = (fsm==Source || cnt_stage==ctrl.NumOfFactors-3'd1);

// Make sure the latency of CTA_addr_source and CTA_addr_trans 
// are the same !!
CTA_addr_source #(
		12
	)
CTA_addr_source_inst (
	clk,    
	rst_n,  
	fsm_lastRd_source,

	Nf,  //N1,N2,...,N6

	addr_source_CTA 
);

always@(posedge clk) 
	addr_source_CTA_r <= {addr_source_CTA_r[26:0], addr_source_CTA};

always@(posedge clk)
begin
	addrs_butterfly_src[0] <= addr_source_CTA;
	addrs_butterfly_src[1] <= addr_source_CTA + 12'd1;
	addrs_butterfly_src[2] <= addr_source_CTA + 12'd2;
	addrs_butterfly_src[3] <= 0;
	addrs_butterfly_src[4] <= 0;
end

always@(posedge clk)
begin 
	if (!rst_n)
	begin
		bank_index_source_r <= 0;
	end
	else
	begin
		bank_index_source_r <= bank_index_source;
	end
end

divider_7 divider_7_inst2 (
	.dividend 	(addr_source_CTA_r[26]),  

	.quotient 	(bank_addr_source),
	.remainder 	(bank_index_source)
);

always@(*)
begin
	case (bank_index_source)
	3'd0:  rdRAM_FSMsource.rden = 7'b1000000;
	3'd1:  rdRAM_FSMsource.rden = 7'b0100000;
	3'd2:  rdRAM_FSMsource.rden = 7'b0010000;
	3'd3:  rdRAM_FSMsource.rden = 7'b0001000;
	3'd4:  rdRAM_FSMsource.rden = 7'b0000100;
	3'd5:  rdRAM_FSMsource.rden = 7'b0000010;
	3'd6:  rdRAM_FSMsource.rden = 7'b0000001;
	default: rdRAM_FSMsource.rden = 7'd0;
	endcase
end

logic in_rdx2345_valid_r;
logic [11:0]  cnt_source;
always@(posedge clk)
begin
	if (!rst_n)
	begin
		out_data.sop <= 0;
		out_data.eop <= 0;
		out_data.valid <= 0;
		source_end <= 0;
		cnt_source <= 0;
		in_rdx2345_valid_r <= 0;
	end
	else
	begin

		in_rdx2345_valid_r <= in_rdx2345_data.valid;
		if (fsm_lastRd_source) begin
			if (in_rdx2345_data.valid && (!in_rdx2345_valid_r)) begin
				out_data.sop <= 1'b1;
				cnt_source <= 12'd1;
			end
			else begin
				out_data.sop <= 1'b0;
				cnt_source <= (cnt_source==12'd0)? 12'd0 : cnt_source+12'd1;
			end
			out_data.eop <= (cnt_source==dftpts-12'd1)? 1'b1 : 1'b0;
			if (in_rdx2345_data.valid && (!in_rdx2345_valid_r))
				out_data.valid <= 1'b1;
			else if (out_data.eop)
				out_data.valid <= 1'b0;
			else
				out_data.valid <= out_data.valid;
		end
		else begin
			out_data.sop <= 0;
			cnt_source <= 0;
			out_data.eop <= 0;
			out_data.valid <= 0;
		end
		source_end <=  (fsm == Source && cnt_source==dftpts);
	end
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		source_ongoing <= 0;
		cnt_source_ongoing <= 0;
	end
	else
	begin
		if (fsm == Source && fsm_r != Source)                          
			cnt_source_ongoing <= 12'd1;
		else if (cnt_source_ongoing != 12'd0)
			cnt_source_ongoing <= (cnt_source_ongoing==dftpts+'d2) ?
		                           12'd0 : cnt_source_ongoing + 12'd1;
		else
			cnt_source_ongoing <= 0;

		source_ongoing <= (cnt_source_ongoing != 12'd0);
	end
end


endmodule