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

localparam  in_dly = 5;
logic [in_dly:0]  input_valid_r;
logic [in_dly:0][17:0]  input_real_r;
logic [in_dly:0][17:0]  input_imag_r;

assign stat_to_ctrl.sink_sop = in_data.sop;
assign stat_to_ctrl.dftpts = in_data.dftpts;

logic [11:0]  bank_addr_sink, bank_addr_sink_pre;
logic [2:0] bank_index_sink, bank_index_sink_pre;
logic [0:6]  wren_sink;

logic [0:6] rden, wren;
logic [0:6] rden_rd;
logic [0:6][7:0]  rdaddr_rd;
logic [0:4][11:0]  addrs_butterfly, addrs_butterfly_mux, addrs_butterfly_src;
logic [0:4][7:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr, 
                  div7_rmdr_rd;
logic [0:6][29:0] d_real_rd, d_imag_rd;
logic [0:6][29:0] din_real_RAM, din_imag_RAM;

logic [0:6][29:0] wrdin_real, wrdin_imag;
logic [0:6][7:0]  wraddr_RAM, wraddr_wr;
logic [0:6]  wren_wr;

logic [11:0] cnt_rd_ongoing, cnt_rd_stop, cnt_source_ongoing;

logic [0:6]  rden_source;
logic [11:0]  bank_addr_source;
logic [2:0] bank_index_source, bank_index_source_r;
logic [0:6][29:0] dout_real_RAM, dout_imag_RAM;
logic [0:6][7:0]  rdaddr_RAM;

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
logic [3:0] rd_ongoing_r;
logic fsm_lastRd_source;

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
		// Sink : fsm <= (sink_3_4)? Wait_to_rd : Sink;
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
//-----------------------------------------------------

//-------------------------------------------
//--------------  7 RAMs --------------------
//-------------------------------------------
genvar i;
generate
	for (i=0; i<7; i++) begin : RAM_banks
	mrd_RAM_fake RAM_fake(
		.clk (clk),
		.wren (wren[i]),
		.wraddr (wraddr_RAM[i]),
		.din_real (din_real_RAM[i]),
		.din_imag (din_imag_RAM[i]),

		.rden (rden[i]),
		.rdaddr (rdaddr_RAM[i]),
		.dout_real (dout_real_RAM[i]),
		.dout_imag (dout_imag_RAM[i])
		);
	end
endgenerate

generate
for (i=0; i<=6; i++)  begin : din_switch
always@(*)
begin
if (fsm==Sink) 
begin
	din_real_RAM[i] = { {12{input_real_r[0][17]}},input_real_r[0] };
	din_imag_RAM[i] = { {12{input_imag_r[0][17]}},input_imag_r[0] };
end
else 
begin
	din_real_RAM[i] = wrdin_real[i];
	din_imag_RAM[i] = wrdin_imag[i];
end		
end	

assign wraddr_RAM[i]= (fsm==Sink)? bank_addr_sink[7:0] 
                      : wraddr_wr[i];
assign wren[i] = (fsm==Sink)? (wren_sink[i] & input_valid_r[0])
                  : wren_wr[i] ; 

assign rdaddr_RAM[i]= (fsm==Rd)? rdaddr_rd[i] : bank_addr_source;
assign rden[i] = (fsm==Rd)? rden_rd[i] : 
                 (rden_source[i] & fsm_lastRd_source);
assign d_real_rd[i] = (fsm==Rd)? dout_real_RAM[i] : 30'd0;
assign d_imag_rd[i] = (fsm==Rd)? dout_imag_RAM[i] : 30'd0;
end
endgenerate 

always@(posedge clk) begin
	 out_data.dout_real <= (fsm_lastRd_source && in_rdx2345_data.valid)? 
            in_rdx2345_data.d_real[0] : dout_real_RAM[bank_index_source_r] ;
	 out_data.dout_imag <= (fsm_lastRd_source && in_rdx2345_data.valid)? 
            in_rdx2345_data.d_imag[0] : dout_imag_RAM[bank_index_source_r] ;
end
//--------------------------------------------


//------------------------------------------------
//------------------ 1st stage: Sink -------------
//------------------------------------------------
always@(posedge clk)
begin
	if (!rst_n)
	begin
		dftpts <= 0;
		Nf <= 0;
		dftpts_div_Nf <= 0;   //  dftpts/Nf
		twdl_demontr <= 0;
	end
	else
	begin
		if ( fsm == Rd && fsm_r != Rd)
		begin
			Nf <= ctrl.Nf;
			dftpts_div_Nf <= ctrl.dftpts_div_Nf;
			twdl_demontr <= ctrl.twdl_demontr;
		end
		else begin
			Nf <= Nf;
			dftpts_div_Nf <= dftpts_div_Nf;
			twdl_demontr <= twdl_demontr;
		end
		dftpts <= (in_data.sop)? in_data.dftpts : dftpts;
	end
end

always@(posedge clk)
begin
	// If in_dly >= 1
	input_valid_r[in_dly:0] <= {input_valid_r[in_dly-1:0],
	                              in_data.valid} ;
	input_real_r[in_dly:0] <= {input_real_r[in_dly-1:0],in_data.din_real};
	input_imag_r[in_dly:0] <= {input_imag_r[in_dly-1:0],in_data.din_imag};

	// If in_dly == 0
	// input_valid_r[0] <= in_data.valid;
	// input_real_r[0] <= in_data.din_real;
	// input_imag_r[0] <= in_data.din_imag;
end

always@(posedge clk)
begin
	if (!rst_n)
		addr_sink_CTA <= 0;
	else begin
		if (in_data.valid)
			addr_sink_CTA <= addr_sink_CTA + 12'd1;
		else
			addr_sink_CTA <= 0;
	end
end

divider_7 divider_7_inst0 (
	.dividend 	(addr_sink_CTA),  

	.quotient 	(bank_addr_sink_pre),
	.remainder 	(bank_index_sink_pre)
);

always@(posedge clk) begin
	bank_addr_sink <= bank_addr_sink_pre;
	bank_index_sink <= bank_index_sink_pre;
end

always@(*)
begin
	case (bank_index_sink)
	3'd0:  wren_sink = 7'b1000000;
	3'd1:  wren_sink = 7'b0100000;
	3'd2:  wren_sink = 7'b0010000;
	3'd3:  wren_sink = 7'b0001000;
	3'd4:  wren_sink = 7'b0000100;
	3'd5:  wren_sink = 7'b0000010;
	3'd6:  wren_sink = 7'b0000001;
	default: wren_sink = 7'd0;
	endcase
end

always@(posedge clk)
begin 
	if(!rst_n)  begin
		sink_3_4 <= 0;
		cnt_sink <= 0;
	end
	else begin
		cnt_sink <= (in_data.valid)? cnt_sink+12'd1 : 0;
		if (cnt_sink != 12'd0 && cnt_sink==
			(ctrl.twdl_demontr[0] - ctrl.twdl_demontr[1] - 12'd1))
			sink_3_4 <= 1'b1;
		else sink_3_4 <= 1'b0;
	end
end


//------------------------------------------------
//------------------ 2nd stage: Read -------------
//------------------------------------------------

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
		rden_rd[k] <= 0;
		rdaddr_rd[k] <= 0;
	end
	else 
	begin
		if (bank_index_rd[0]== k || bank_index_rd[1]== k ||
			bank_index_rd[2]== k || bank_index_rd[3]== k ||
			bank_index_rd[4]== k )
				rden_rd[k] <= 1'b1 & rd_ongoing_r[0];
		else rden_rd[k] <= 1'b0;

		if (bank_index_rd[0]==k) rdaddr_rd[k] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==k) rdaddr_rd[k] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==k) rdaddr_rd[k] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==k) rdaddr_rd[k] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==k) rdaddr_rd[k] <= bank_addr_rd[4];
		else  rdaddr_rd[k] <= 0;
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
	for (i=0; i<3; i++) begin : rd_out
	always@(*)
	begin
		out_rdx2345_data.d_real[i] = d_real_rd[(bank_index_rd_rr[i])]; 
		out_rdx2345_data.d_imag[i] = d_imag_rd[(bank_index_rd_rr[i])]; 
	end
	end
endgenerate
	always@(*)
	begin
		out_rdx2345_data.d_real[3] = (fsm==Rd && cnt_stage==3'd0)?
		        {{(30-18){input_real_r[5][17]}}, input_real_r[5]} : 
		        d_real_rd[(bank_index_rd_rr[3])]; 
		out_rdx2345_data.d_imag[3] = (fsm==Rd && cnt_stage==3'd0)?
		        {{(30-18){input_imag_r[5][17]}}, input_imag_r[5]} : 
		        d_imag_rd[(bank_index_rd_rr[3])]; 
		out_rdx2345_data.d_real[4] = d_real_rd[(bank_index_rd_rr[4])]; 
		out_rdx2345_data.d_imag[4] = d_imag_rd[(bank_index_rd_rr[4])]; 
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
		rd_ongoing_r[3:1] <= rd_ongoing_r[2:0];

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

//------------------------------------------------
//------------------ 3rd stage: Write ------------
//------------------------------------------------


generate
for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : wren_wr_gen
always@(posedge clk)
begin
	if (!rst_n)
	begin
		wren_wr[k] <= 0;
		wraddr_wr[k] <= 0;
		wrdin_real[k] <= 0;
		wrdin_imag[k] <= 0;
	end
	else
	begin
		if (in_rdx2345_data.bank_index[0]== k || 
			in_rdx2345_data.bank_index[1]== k ||
			in_rdx2345_data.bank_index[2]== k || 
			in_rdx2345_data.bank_index[3]== k ||
			in_rdx2345_data.bank_index[4]== k )
				wren_wr[k] <= 1'b1 & in_rdx2345_data.valid;
		else wren_wr[k] <= 1'b0;

		if (in_rdx2345_data.bank_index[0]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[0];
			wrdin_real[k] <= in_rdx2345_data.d_real[0]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[0]; 
		end
		else if (in_rdx2345_data.bank_index[1]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[1];
			wrdin_real[k] <= in_rdx2345_data.d_real[1]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[1]; 
		end 
		else if (in_rdx2345_data.bank_index[2]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[2]; 
			wrdin_real[k] <= in_rdx2345_data.d_real[2]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[2]; 
		end
		else if (in_rdx2345_data.bank_index[3]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[3];
			wrdin_real[k] <= in_rdx2345_data.d_real[3]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[3]; 
		end 
		else if (in_rdx2345_data.bank_index[4]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[4];
			wrdin_real[k] <= in_rdx2345_data.d_real[4]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[4]; 
		end
		else
		begin
			wraddr_wr[k] <= 0;
			wrdin_real[k] <= 0; 
			wrdin_imag[k] <= 0;
		end 
	end
end
end
endgenerate

always@(posedge clk)
begin
	if (!rst_n)
	begin
		wr_ongoing <= 0;
		wr_ongoing_r <= 0;
	end
	else
	begin
		wr_ongoing <= (fsm==Rd || fsm==Wait_wr_end) ? 
		                           in_rdx2345_data.valid : 1'b0;
		wr_ongoing_r <= wr_ongoing;
	end
end

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
		// out_data.sop <= (cnt_source_ongoing==12'd3)? 1'b1 : 1'b0;
		// out_data.eop <= (cnt_source_ongoing==dftpts+12'd2)? 1'b1 : 1'b0;
		// if (cnt_source_ongoing==12'd3)
		// 	out_data.valid <= 1'b1;
		// else if (out_data.eop)
		// 	out_data.valid <= 1'b0;
		// else
		// 	out_data.valid <= out_data.valid;
		// stat_to_ctrl.source_start <= (fsm == Source && fsm_r != Source);
		// stat_to_ctrl.source_end <= (fsm != Source && fsm_r == Source);

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