//-----------------------------------------------------------------
// Module Name:        	mrd_mem_top.sv
// Project:             Mixed Radix DFT
// Description:         Memory top module 
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1   2017-01-11
//  Description :   
//------------------------------------------------------------------
//  Version 0.2   2017-02-09
//  Description :  
//  Changes :  One packet only be processed in one mem.  mem0 and mem1
//             perform ping-pong operation based on packet.
//------------------------------------------------------------------
module mrd_mem_top_v2 (
	input clk,  
	input rst_n,

	mrd_st_if  in_data,
	mrd_rdx2345_if  in_rdx2345_data,

	mrd_ctrl_if  ctrl,

	mrd_st_if  out_data,
	mrd_rdx2345_if  out_rdx2345_data,
	mrd_stat_if  stat_to_ctrl
);

logic [11:0]  dftpts;
logic [0:5][2:0] Nf;
logic [0:5][11:0] dftpts_div_Nf; 
logic  clr_n_PFA_addr, clr_n_PFA_addr_o; 

assign stat_to_ctrl.sink_sop = in_data.sop;
assign stat_to_ctrl.dftpts = in_data.dftpts;

logic [11:0]  bank_addr_sink, bank_addr_sink_pre;
logic [2:0] bank_index_sink, bank_index_sink_pre;
logic [0:6]  wren_sink;

logic [0:6] rden, wren;
logic [0:6] rden_rd;
logic [0:6][mrd_mem_pkt::wADDR-1:0]  rdaddr_rd;
logic [0:4][11:0]  addrs_butterfly, addrs_butterfly_mux, addrs_butterfly_src;
logic [0:4][mrd_mem_pkt::wADDR-1:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr, 
                  div7_rmdr_rd;
logic [0:6][mrd_mem_pkt::wDATA-1:0] d_real_rd, d_imag_rd;
logic [0:6][mrd_mem_pkt::wDATA-1:0] din_real_RAM, din_imag_RAM;

logic [0:6][mrd_mem_pkt::wDATA-1:0] wrdin_real, wrdin_imag;
logic [0:6][mrd_mem_pkt::wADDR-1:0]  wraddr_RAM, wraddr_wr;
logic [0:6]  wren_wr;

logic [11:0] cnt_rd_ongoing, cnt_rd_stop, cnt_source_ongoing;

logic [0:6]  rden_source;
logic [11:0]  bank_addr_source;
logic [2:0] bank_index_source, bank_index_source_r;
logic [0:6][mrd_mem_pkt::wDATA-1:0] dout_real_RAM, dout_imag_RAM;
logic [0:6][mrd_mem_pkt::wADDR-1:0]  rdaddr_RAM;

logic [11:0]  addr_sink_CTA;
logic [0:4][11:0]  twdl_numrtr;
logic [0:5][11:0]  twdl_demontr;
logic [2:0]  cnt_stage;

logic [2:0] fsm, fsm_r;
parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
  			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;

logic sink_3_4;
logic [11:0]  cnt_sink;
logic source_ongoing, rd_ongoing, wr_ongoing, wr_ongoing_r;
logic [2:0] rd_ongoing_r;
logic fsm_lastRd_source;

mrd_mem_wr wrRAM();
mrd_mem_rd rdRAM();
mrd_mem_wr wrRAM_FSMrd();
mrd_mem_rd rdRAM_FSMrd();
mrd_mem_wr wrRAM_FSMsink();

//----------------  Input (Sink) registers -------------
localparam  in_dly = 5;
logic [in_dly:0]  valid_r;
logic [in_dly:0][17:0]  din_real_r, din_imag_r;
always@(posedge clk)
begin   // If in_dly >= 1
	valid_r[in_dly:0] <= {valid_r[in_dly-1:0],in_data.valid} ;
	din_real_r[in_dly:0] <= {din_real_r[in_dly-1:0],in_data.din_real};
	din_imag_r[in_dly:0] <= {din_imag_r[in_dly-1:0],in_data.din_imag};
end

//------------------------------------------------
//------------------ FSM -------------------------
//------------------------------------------------
always@(posedge clk)
begin
	if(!rst_n) begin
		fsm <= 3'd0;
		fsm_r <= 3'd0;
	end
	else begin
		case (fsm)
		Idle : fsm <= (in_data.sop)? Sink : Idle;

		Sink : fsm <= (sink_3_4)? Rd : Sink;

		Rd : fsm <= (rd_ongoing_r[2:1]==2'b10)? Wait_wr_end : Rd;
		Wait_wr_end : begin
			if (!wr_ongoing && wr_ongoing_r)
				if (cnt_stage == ctrl.NumOfFactors-3'd1)
					fsm <= Source;
				else
					fsm <= Rd;
			else fsm <= Wait_wr_end;
		end

		Source : fsm <= (stat_to_ctrl.source_end)? Idle : Source;
		default : fsm <= Idle;
		endcase

		fsm_r <= fsm;
	end
end


//-------------------------------------------
//--------------  7 RAMs --------------------
//-------------------------------------------
genvar i;
generate
	for (i=0; i<7; i++) begin : RAM_banks
	mrd_RAM_fake RAM_fake(
		.clk (clk),
		.wren (wrRAM.wren[i]),
		.wraddr (wrRAM.wraddr[i]),
		.din_real (wrRAM.din_real[i]),
		.din_imag (wrRAM.din_imag[i]),

		.rden (rdRAM.rden[i]),
		.rdaddr (rdRAM.rdaddr[i]),
		.dout_real (rdRAM.dout_real[i]),
		.dout_imag (rdRAM.dout_imag[i])
		);
	end
endgenerate


//-------------------------------------------
//--------------  Switches --------------------
//-------------------------------------------
generate
for (i=0; i<=6; i++)  begin : din_switch
always@(*)
begin
if (fsm==Sink) 
begin
	wrRAM.din_real[i] = { {12{din_real_r[0][17]}},din_real_r[0] };
	wrRAM.din_imag[i] = { {12{din_imag_r[0][17]}},din_imag_r[0] };
end
else 
begin
	wrRAM.din_real[i] = wrRAM_FSMrd.din_real[i];
	wrRAM.din_imag[i] = wrRAM_FSMrd.din_imag[i];
end		
end	
assign wrRAM.wraddr[i]= (fsm==Sink)? bank_addr_sink[7:0] 
                      : wrRAM_FSMrd.wraddr[i];
assign wrRAM.wren[i] = (fsm==Sink)? (wrRAM_FSMsink.wren[i] & valid_r[0])
                  : wrRAM_FSMrd.wren[i] ; 


assign rdRAM.rdaddr[i]= (fsm==Rd)? rdRAM_FSMrd.rdaddr[i] : bank_addr_source;
assign rdRAM.rden[i] = (fsm==Rd)? rdRAM_FSMrd.rden[i] : 
                 (rden_source[i] & fsm_lastRd_source);
assign rdRAM_FSMrd.dout_real[i] = (fsm==Rd)? rdRAM.dout_real[i] : 30'd0;
assign rdRAM_FSMrd.dout_imag[i] = (fsm==Rd)? rdRAM.dout_imag[i] : 30'd0;
end
endgenerate 

always@(posedge clk) begin
	 out_data.dout_real <= (fsm_lastRd_source && in_rdx2345_data.valid)? 
            in_rdx2345_data.d_real[0] : rdRAM.dout_real[bank_index_source_r] ;
	 out_data.dout_imag <= (fsm_lastRd_source && in_rdx2345_data.valid)? 
            in_rdx2345_data.d_imag[0] : rdRAM.dout_imag[bank_index_source_r] ;
end


//------------------------------------------------
//------------------ 1st stage: Sink -------------
//------------------------------------------------
mrd_FSMsink 
mrd_FSMsink_inst (
	clk,
	rst_n,

	fsm,
	fsm_r,

	ctrl,
	in_data,
	wrRAM_FSMsink,

	bank_addr_sink,  //!!!???  7:0
	sink_3_4,

	dftpts,
	Nf,
	dftpts_div_Nf,
	twdl_demontr
);

//------------------------------------------------
//------------------ 2nd stage: Read -------------
//------------------------------------------------












mrd_FSMrd_rd 
mrd_FSMrd_rd_inst (
	clk,
	rst_n,

	fsm,
	fsm_r,

	din_real_r,
	din_imag_r,
	Nf,
	dftpts_div_Nf,
	addrs_butterfly_src,

	ctrl,
	rdRAM_FSMrd,
	out_rdx2345_data,

	rd_ongoing_r,
	cnt_stage
);











// always@(posedge clk)
// begin
// 	if (!rst_n) 
// 	begin
// 		bank_index_rd_r <= 0;
// 		bank_index_rd_rr <= 0;
// 		bank_addr_rd_r <= 0;
// 		bank_addr_rd_rr <= 0;
// 	end
// 	else 
// 	begin
// 		bank_index_rd_r <= bank_index_rd;
// 		bank_index_rd_rr <= bank_index_rd_r;
// 		bank_addr_rd_r <= bank_addr_rd;
// 		bank_addr_rd_rr <= bank_addr_rd_r;
// 	end
// end

// genvar  k;
// generate
// for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : rden_addr_index
// always@(posedge clk)
// begin
// 	if (!rst_n) 
// 	begin
// 		rdRAM_FSMrd.rden[k] <= 0;
// 		rdRAM_FSMrd.rdaddr[k] <= 0;
// 	end
// 	else 
// 	begin
// 		if (bank_index_rd[0]== k || bank_index_rd[1]== k ||
// 			bank_index_rd[2]== k || bank_index_rd[3]== k ||
// 			bank_index_rd[4]== k )
// 				rdRAM_FSMrd.rden[k] <= 1'b1 & rd_ongoing_r[0];
// 		else rdRAM_FSMrd.rden[k] <= 1'b0;

// 		if (bank_index_rd[0]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[0]; 
// 		else if (bank_index_rd[1]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[1]; 
// 		else if (bank_index_rd[2]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[2]; 
// 		else if (bank_index_rd[3]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[3]; 
// 		else if (bank_index_rd[4]==k) rdRAM_FSMrd.rdaddr[k] <= bank_addr_rd[4];
// 		else  rdRAM_FSMrd.rdaddr[k] <= 0;
// 	end
// end
// end
// endgenerate

// generate
// 	for (k=3'd0; k < 3'd5; k=k+3'd1) begin : addr_banks
// 	divider_7 divider_7_inst1 (
// 		.dividend 	(addrs_butterfly_mux[k]),  

// 		.quotient 	(bank_addr_rd[k]),
// 		.remainder 	(div7_rmdr_rd[k])
// 	);
// 	// index 3'd7 means the index is not valid
// 	assign bank_index_rd[k] = (k >= Nf[cnt_stage]) ?
// 	                          3'd7 : div7_rmdr_rd[k];
// 	end
// endgenerate

// generate
// 	for (i=0; i<3; i++) begin : rd_out
// 	always@(*)
// 	begin
// 		out_rdx2345_data.d_real[i] = rdRAM_FSMrd.dout_real[(bank_index_rd_rr[i])]; 
// 		out_rdx2345_data.d_imag[i] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[i])]; 
// 	end
// 	end
// endgenerate

// always@(*)
// begin
// 	out_rdx2345_data.d_real[3] = (fsm==Rd && cnt_stage==3'd0)?
// 	        {{(30-18){din_real_r[5][17]}}, din_real_r[5]} : 
// 	        rdRAM_FSMrd.dout_real[(bank_index_rd_rr[3])]; 
// 	out_rdx2345_data.d_imag[3] = (fsm==Rd && cnt_stage==3'd0)?
// 	        {{(30-18){din_imag_r[5][17]}}, din_imag_r[5]} : 
// 	        rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[3])]; 
// 	out_rdx2345_data.d_real[4] = rdRAM_FSMrd.dout_real[(bank_index_rd_rr[4])]; 
// 	out_rdx2345_data.d_imag[4] = rdRAM_FSMrd.dout_imag[(bank_index_rd_rr[4])]; 
// end

// assign out_rdx2345_data.valid = rd_ongoing_r[2];
// assign out_rdx2345_data.bank_index = bank_index_rd_rr;
// assign out_rdx2345_data.bank_addr = bank_addr_rd_rr;
// always@(posedge clk) out_rdx2345_data.twdl_numrtr <= twdl_numrtr;
// always@(posedge clk) out_rdx2345_data.twdl_demontr <= 
//                          twdl_demontr[cnt_stage];

// always@(*)
// begin
// 	if (fsm==Rd || fsm==Wait_wr_end)
// 		out_rdx2345_data.factor = Nf[cnt_stage];
// 	else
// 		out_rdx2345_data.factor <= 3'd1;
// end

// always@(*)
// begin
// 	cnt_rd_stop = dftpts_div_Nf[cnt_stage];
// end

// always@(posedge clk)
// begin
// 	if (!rst_n)
// 	begin
// 		rd_ongoing <= 0;
// 		cnt_rd_ongoing <= 0;
// 		rd_ongoing_r <= 0;
// 		cnt_stage <= 0;
// 	end
// 	else
// 	begin

// 		if (fsm == Rd && fsm_r != Rd)
// 			cnt_rd_ongoing <= 12'd1;
// 		else if (cnt_rd_ongoing != 12'd0)
// 			cnt_rd_ongoing <= (cnt_rd_ongoing==cnt_rd_stop) ? 
// 		                       12'd0 : cnt_rd_ongoing + 12'd1;
// 		else
// 			cnt_rd_ongoing <= 0;

// 		rd_ongoing <= (cnt_rd_ongoing != 12'd0);
// 		rd_ongoing_r[0] <= rd_ongoing;
// 		rd_ongoing_r[2:1] <= rd_ongoing_r[1:0];

// 		if (fsm==Source) cnt_stage <= 0;
// 		else cnt_stage <= (fsm==Rd && fsm_r==Wait_wr_end)? 
// 			               cnt_stage+3'd1 : cnt_stage;
// 	end
// end

// CTA_addr_trans #(
// 		.wDataInOut (12)
// 	)
// CTA_addr_trans_inst	(
// 	.clk  (clk),    
// 	.rst_n  (rst_n),  
// 	.clr_n  (rd_ongoing),
// 	.Nf  (Nf),
// 	.current_stage  (cnt_stage),

// 	.addrs_butterfly  (addrs_butterfly)
// 	);

// generate
// 	for (k=3'd0; k < 3'd5; k=k+3'd1) begin 
// assign addrs_butterfly_mux[k] = (fsm==Rd && cnt_stage < ctrl.NumOfFactors-3'd1)?
//                               addrs_butterfly[k] : addrs_butterfly_src[k] ;
//     end
// endgenerate

// CTA_twdl_numrtr #(
// 		.wDataInOut (12)
// 	)
// CTA_twdl_numrtr_inst	(
// 	.clk  (clk),    
// 	.rst_n  (rst_n),  
// 	.clr_n  (rd_ongoing),
// 	.Nf  (Nf),
// 	.current_stage  (cnt_stage),
// 	.twdl_demontr  (twdl_demontr),

// 	.twdl_numrtr  (twdl_numrtr)
// 	);




//------------------------------------------------
//------------------ 3rd stage: Write ------------
//------------------------------------------------
mrd_FSMrd_wr 
mrd_FSMrd_wr_inst (
	clk,
	rst_n,
	fsm,

	wrRAM_FSMrd,
	in_rdx2345_data,

	wr_ongoing,
	wr_ongoing_r
);

//------------------------------------------------
//------------------ 4th stage: Source -----------
//------------------------------------------------
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

logic [2:0]  k1,k2,k3,k4,k5,k6; 

//-------------------------------------------- 
logic [11:0]  addr_source_CTA;
logic [27:0][11:0]  addr_source_CTA_r;

assign fsm_lastRd_source = (fsm==Source || cnt_stage==ctrl.NumOfFactors-3'd1);

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
		// N_PFA_out <= (stat_to_ctrl.source_ongoing)? N_PFA_out+12'd1 
		//                  : 12'd0 ;
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
	3'd0:  rden_source = 7'b1000000;
	3'd1:  rden_source = 7'b0100000;
	3'd2:  rden_source = 7'b0010000;
	3'd3:  rden_source = 7'b0001000;
	3'd4:  rden_source = 7'b0000100;
	3'd5:  rden_source = 7'b0000010;
	3'd6:  rden_source = 7'b0000001;
	default: rden_source = 7'd0;
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
		stat_to_ctrl.source_start <= 0;
		stat_to_ctrl.source_end <= 0;
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
		stat_to_ctrl.source_start <= (fsm == Source && fsm_r != Source);
		stat_to_ctrl.source_end <=  (fsm == Source && cnt_source==dftpts);
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