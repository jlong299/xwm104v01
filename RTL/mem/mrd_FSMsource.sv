module mrd_FSMsource #(parameter
	dly_addr_source = 10
	)
	(
	input clk,
	input rst_n,

	// FSM signals
	input [2:0] fsm,
	input [2:0] fsm_r,
	input fsm_lastRd_source,

	// Parameters
	input [0:5][2:0] Nf,
	input [11:0] dftpts,
	input [0:5][11:0]  twdl_demontr,

	// Interfaces
	mrd_rdx2345_if in_rdx2345_data,
	mrd_mem_rd rdRAM_FSMsource,
	mrd_st_if  out_data,

	// Output
	output logic [0:4][11:0] addrs_butterfly_src,
	output logic [2:0] bank_index_source,
	output logic source_end
	
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
localparam Source = 3'd5;

logic source_ongoing;
logic [11:0]  bank_addr_source_pre, bank_addr_source_r0, bank_addr_source_r1;
logic [2:0] bank_index_source_pre, bank_index_source_r0, bank_index_source_r1;
logic [11:0] addr_source_CTA;
genvar i;

//--------Part 1 : RAMs read address which feeds to mrd_FSMrd_rd.sv ------ 
//--------Note :  Addresses are inverse bit order ----
CTA_addr_source #(
		12
	)
CTA_addr_source_inst (
	clk,    
	rst_n,  
	fsm_lastRd_source,

	Nf,  //N1,N2,...,N6
	twdl_demontr,

	addr_source_CTA 
);

always@(posedge clk)
begin
	addrs_butterfly_src[0] <= addr_source_CTA;
	addrs_butterfly_src[1] <= addr_source_CTA + 12'd1;
	addrs_butterfly_src[2] <= addr_source_CTA + 12'd2;
	addrs_butterfly_src[3] <= 0;
	addrs_butterfly_src[4] <= 0;
end

//------Part 2 : Gen output sop,eop,valid according to in_rdx2345_data.valid--
//------Note : in_rdx2345_data.valid represents first 1/3 output data ----
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

//------Part 3 : Delay the source RAM read address to make the  ----
//------last 2/3 output data right behind the first 1/3 ----
logic [dly_addr_source-1:0][11:0]  addr_source_CTA_r;
always@(posedge clk) 
	addr_source_CTA_r <= {addr_source_CTA_r[dly_addr_source-2:0], addr_source_CTA};

divider_7 divider_7_inst2 (
	// .dividend 	(addr_source_CTA_r[27]),  
	.dividend 	(addr_source_CTA_r[dly_addr_source-1]),  

	.quotient 	(bank_addr_source_pre),
	.remainder 	(bank_index_source_pre)
);

always@(posedge clk) begin
	if (!rst_n)	begin
		bank_addr_source_r0 <= 0;
		bank_addr_source_r1 <= 0;
		bank_index_source_r0 <= 0;
		bank_index_source_r1 <= 0;
		bank_index_source <= 0;
	end
	else begin
		bank_addr_source_r0 <= bank_addr_source_pre;
		bank_addr_source_r1 <= bank_addr_source_r0;
		bank_index_source_r0 <= bank_index_source_pre;
		bank_index_source_r1 <= bank_index_source_r0;
		bank_index_source <= bank_index_source_r1;
	end
end
generate 
for (i=0; i<=6; i++)
assign rdRAM_FSMsource.rdaddr[i] = bank_addr_source_r1[mrd_mem_pkt::wADDR-1:0];
endgenerate

always@(posedge clk)
begin
	case (bank_index_source_r0)
	3'd0:  rdRAM_FSMsource.rden <= 7'b1000000;
	3'd1:  rdRAM_FSMsource.rden <= 7'b0100000;
	3'd2:  rdRAM_FSMsource.rden <= 7'b0010000;
	3'd3:  rdRAM_FSMsource.rden <= 7'b0001000;
	3'd4:  rdRAM_FSMsource.rden <= 7'b0000100;
	3'd5:  rdRAM_FSMsource.rden <= 7'b0000010;
	3'd6:  rdRAM_FSMsource.rden <= 7'b0000001;
	default: rdRAM_FSMsource.rden <= 7'd0;
	endcase
end

endmodule