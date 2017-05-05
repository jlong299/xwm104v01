module mrd_FSMrd_rd_p4 #(parameter
	wait_before_start = 6
	)
	(
	input clk,
	input rst_n,

	input [2:0] fsm,
	input [2:0] fsm_r,
	input [2:0] cnt_stage,

	input [in_dly:0][17:0] din_real_r,
	input [in_dly:0][17:0] din_imag_r,
	input [0:5][2:0] Nf,
	input [0:5][11:0] dftpts_div_Nf,
	// input [0:4][11:0] addrs_butterfly_src,
	input [0:5][11:0]  twdl_demontr,
	input [2:0]  stage_of_rdx2,

	mrd_ctrl_if ctrl,
	mrd_mem_rd rdRAM_FSMrd,
	mrd_rdx2345_if out_rdx2345_data,

	output rd_end
	// output logic twdl_sop_rd
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
localparam Idle = 3'd0, Rd = 3'd3, Wait_wr_end = 3'd4, Source = 3'd5;

logic [0:4][mrd_mem_pkt::wADDR-1:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr, bank_index_rd_rrr,
                  div7_rmdr_rd;
logic [0:4][11:0]  addrs_butterfly, addrs_butterfly_mux;
logic [11:0]  cnt_rd_stop;
logic [11:0]  twdl_numrtr_1;

logic [11:0] cnt_FSMrd, cnt_FSMrd_2;
logic [in_dly-1:1] rden_r; //////
logic rden_r0;

//-------------------------------------------
always@(posedge clk) begin
	if (cnt_stage == stage_of_rdx2)
		cnt_rd_stop <= (dftpts_div_Nf[cnt_stage]) >> 1;
	else
		cnt_rd_stop <= dftpts_div_Nf[cnt_stage];
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		rden_r <= 0;
		cnt_FSMrd <= 0;
		// twdl_sop_rd <= 0;
		// cnt_FSMrd_2 <= 0;
	end
	else
	begin
		if (fsm == Rd && fsm_r != Rd)
			cnt_FSMrd <= 12'd1;
		else if (cnt_FSMrd != 12'd0)
			cnt_FSMrd <= (cnt_FSMrd==cnt_rd_stop) ? 
		                       12'd0 : cnt_FSMrd + 12'd1;
		else
			cnt_FSMrd <= 0;
		//////
		rden_r[in_dly-1:1] <= {rden_r[in_dly-2:1], rden_r0};

		// if (fsm == Rd && fsm_r != Rd)
		// 	cnt_FSMrd_2 <= 12'd1;
		// else if (cnt_FSMrd_2 != 12'd0)
		// 	cnt_FSMrd_2 <= (cnt_FSMrd_2==cnt_rd_stop+12'd21) ? 
		//                        12'd0 : cnt_FSMrd_2 + 12'd1;
		// else
		// 	cnt_FSMrd_2 <= 0;
			
		// twdl_sop_rd <= (cnt_FSMrd_2==cnt_rd_stop+12'd21);
	end
end

assign rden_r0 = (cnt_FSMrd != 12'd0);

//-------------------------------------------
CTA_addr_trans #(
		.wDataInOut (12)
	)
CTA_addr_trans_inst	(
	.clk  (clk),    
	.rst_n  (rst_n),  
	.clr_n  (rden_r0), //////
	.Nf  (Nf),
	.current_stage  (cnt_stage),
	.twdl_demontr  (twdl_demontr),
	.stage_of_rdx2  (stage_of_rdx2),

	.addrs_butterfly  (addrs_butterfly),
	.twdl_numrtr_1  (twdl_numrtr_1)
	);

genvar  k;
generate
for (k=3'd0; k < 3'd5; k=k+3'd1) begin : gen0
// assign addrs_butterfly_mux[k]=(fsm==Rd && cnt_stage != ctrl.NumOfFactors-3'd1)?
//                               addrs_butterfly[k] : addrs_butterfly_src[k] ;
always@(posedge clk)
 addrs_butterfly_mux[k]<=(fsm==Rd && cnt_stage != ctrl.NumOfFactors-3'd1)?
                              addrs_butterfly[k] : addrs_butterfly_src[k] ;
end
endgenerate

//-----------------------------------------------------
wire [0:4][11:0] tt_quotient;
generate
	for (k=3'd0; k < 3'd5; k=k+3'd1) begin : addr_banks
	divider_7 divider_7_inst1 (
		.dividend 	(addrs_butterfly_mux[k]),  

		.quotient 	(tt_quotient[k]),
		.remainder 	(div7_rmdr_rd[k])
	);

	always@(posedge clk)
	begin
		if (!rst_n) begin
			bank_addr_rd[k] <= 0;
			// bank_index_rd[k] <= 0;
		end
		else begin
			bank_addr_rd[k] <= tt_quotient[k][mrd_mem_pkt::wADDR-1:0];
			// index 3'd7 means the index is not valid
			// if (cnt_stage == stage_of_rdx2)
				// bank_index_rd[k] <= (k >= 3'd4) ?
	                          // 3'd7 : div7_rmdr_rd[k];
	        // else
				// bank_index_rd[k] <= (k >= Nf[cnt_stage]) ?
	                          // 3'd7 : div7_rmdr_rd[k];
	    end
	end
	end
endgenerate
always@(posedge clk)
begin
	if (!rst_n) begin
		bank_index_rd[0] <= 0;
		bank_index_rd[1] <= 0;
		bank_index_rd[2] <= 0;
		bank_index_rd[3] <= 0;
		bank_index_rd[4] <= 0;
	end
	else begin
		// index 3'd7 means the index is not valid
		if (cnt_stage == stage_of_rdx2)
			bank_index_rd[0] <= div7_rmdr_rd[0];
        else
			bank_index_rd[0] <= (Nf[cnt_stage] == 3'd0)? 3'd7 : div7_rmdr_rd[0];

		if (cnt_stage == stage_of_rdx2)
			bank_index_rd[1] <= div7_rmdr_rd[1];
        else
			bank_index_rd[1] <= (Nf[cnt_stage] <= 3'd1)? 3'd7 : div7_rmdr_rd[1];

		if (cnt_stage == stage_of_rdx2)
			bank_index_rd[2] <= div7_rmdr_rd[2];
        else
			bank_index_rd[2] <= (Nf[cnt_stage] <= 3'd2)? 3'd7 : div7_rmdr_rd[2];

		if (cnt_stage == stage_of_rdx2)
			bank_index_rd[3] <= div7_rmdr_rd[3];
        else
			bank_index_rd[3] <= (Nf[cnt_stage] <= 3'd3)? 3'd7 : div7_rmdr_rd[3];

		if (cnt_stage == stage_of_rdx2)
			bank_index_rd[4] <= 3'd7 ;
        else
			bank_index_rd[4] <= (Nf[cnt_stage] <= 3'd4)? 3'd7 : div7_rmdr_rd[4];
    end
end

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
				rdRAM_FSMrd.rden[k] <= rden_r[in_dly-3];
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

always@(posedge clk)
begin
	if (!rst_n) 
	begin
		bank_index_rd_r <= 0;
		bank_index_rd_rr <= 0;
		bank_index_rd_rrr <= 0;
		bank_addr_rd_r <= 0;
		bank_addr_rd_rr <= 0;
	end
	else 
	begin
		bank_index_rd_r <= bank_index_rd;
		bank_index_rd_rr <= bank_index_rd_r;
		bank_index_rd_rrr <= bank_index_rd_rr;
		bank_addr_rd_r <= bank_addr_rd;
		bank_addr_rd_rr <= bank_addr_rd_r;
	end
end

//------------------------------------------------
generate
	for (k=0; k<3; k++) begin : rd_out
	always@(*)
	begin
		out_rdx2345_data.d_real[k] = rdRAM_FSMrd.dout_real[(bank_index_rd_rrr[k])]; 
		out_rdx2345_data.d_imag[k] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rrr[k])]; 
	end
	end
endgenerate

logic [17:0] din_real_r_final, din_imag_r_final;
// logic [2:0] cnt_stage_r;
always@(posedge clk) begin
	din_real_r_final <= din_real_r[in_dly];
	din_imag_r_final <= din_imag_r[in_dly];
	// cnt_stage_r <= cnt_stage;
end
 
always@(*)
begin
	////// change in_dly in mrd_mem_top_v2.sv
	out_rdx2345_data.d_real[3] = (cnt_stage==3'd0)? din_real_r_final :
	        rdRAM_FSMrd.dout_real[(bank_index_rd_rrr[3])]; 
	out_rdx2345_data.d_imag[3] = (cnt_stage==3'd0)? din_imag_r_final :
	        rdRAM_FSMrd.dout_imag[(bank_index_rd_rrr[3])]; 

	out_rdx2345_data.d_real[4] = rdRAM_FSMrd.dout_real[(bank_index_rd_rrr[4])]; 
	out_rdx2345_data.d_imag[4] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rrr[4])]; 
end
//////
always@(posedge clk) out_rdx2345_data.valid <= rden_r[in_dly-1];
always@(posedge clk) out_rdx2345_data.bank_index <= bank_index_rd_rr;
always@(posedge clk) out_rdx2345_data.bank_addr <= bank_addr_rd_rr;

always@(posedge clk) out_rdx2345_data.factor <= (fsm==Rd || fsm==Wait_wr_end)?
                                      Nf[cnt_stage] : 3'd1 ;
//////
assign  rd_end =  (rden_r[in_dly-1:in_dly-2]==2'b10);  

endmodule