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
//  Version 0.3   2017-02-16
//  Description :  
//  Changes :  Only 1 RAM to reduce FPGA storage utilization
//------------------------------------------------------------------
//  Main Structure :  
//
//       Sink
//  |-----------------|
//     3/4*Sink   Read     Read                 Read
//               |----|   |----|      ...     |------| 
//                 Write    Write                Write
//                |----|   |----|     ...       |------| 
//                                                   Source    
//                                             |-----------------|
//                                              1/3*
//                                              Source
//  ---------> time line
//  
//  Sink : Input data written into RAMs
//  Read : Read 2/3/4/5 data from RAMs, to Radix-2/3/4/5 core
//  Write : Write RAMs with data from Radix-2/3/4/5 core output
//  Source : Read from RAMs and output
//------------------------------------------------------------------

module mrd_mem_top_v2 (
	input clk,  
	input rst_n,

	mrd_st_if  in_data,
	mrd_rdx2345_if  in_rdx2345_data,

	mrd_ctrl_if  ctrl,

	mrd_st_if  out_data,
	mrd_rdx2345_if  out_rdx2345_data
);

logic [11:0]  dftpts;
logic [0:5][2:0] Nf;
logic [0:5][11:0] dftpts_div_Nf; 
logic [2:0]  stage_of_rdx2;
logic [mrd_mem_pkt::wADDR-1:0]  bank_addr_sink;
logic [0:4][11:0]  addrs_butterfly_src;
logic [11:0]  bank_addr_source;
logic [2:0] bank_index_source_r;
logic [0:4][11:0]  twdl_numrtr;
logic [0:5][11:0]  twdl_demontr;
logic [2:0]  cnt_stage;
logic sink_3_4;
logic wr_end, rd_end;
logic fsm_lastRd_source,  source_end;

mrd_mem_wr wrRAM();
mrd_mem_rd rdRAM();
mrd_mem_wr wrRAM_FSMrd();
mrd_mem_rd rdRAM_FSMrd();
mrd_mem_wr wrRAM_FSMsink();
mrd_mem_rd rdRAM_FSMsource();

logic [2:0] fsm, fsm_r;
parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
  			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;

//------------ Obtain parameters from ctrl -------------
always@(posedge clk)
begin
	if (!rst_n)
	begin
		dftpts <= 0;
		Nf <= 0;
		dftpts_div_Nf <= 0;   //  dftpts/Nf
		twdl_demontr <= 0;
		stage_of_rdx2 <= 0;
	end
	else
	begin
		if ( fsm == Rd && fsm_r != Rd)
		begin
			Nf <= ctrl.Nf;
			dftpts_div_Nf <= ctrl.dftpts_div_Nf;
			twdl_demontr <= ctrl.twdl_demontr;
			stage_of_rdx2 <= ctrl.stage_of_rdx2;
		end
		else begin
			Nf <= Nf;
			dftpts_div_Nf <= dftpts_div_Nf;
			twdl_demontr <= twdl_demontr;
			stage_of_rdx2 <= stage_of_rdx2;
		end
		dftpts <= (in_data.sop)? in_data.dftpts : dftpts;
	end
end

//----------------  Input (Sink) registers -------------
localparam  in_dly = 7;
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

		Rd : fsm <= (rd_end)? Wait_wr_end : Rd;
		Wait_wr_end : begin
			if (wr_end)
				if (cnt_stage == ctrl.NumOfFactors-3'd1)
					fsm <= Source;
				else
					fsm <= Rd;
			else fsm <= Wait_wr_end;
		end

		Source : fsm <= (source_end)? Idle : Source;
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
	mrd_RAM_IP RAM_IP(
		.clock (clk),
		.wren (wrRAM.wren[i]),
		.wraddress (wrRAM.wraddr[i]),
		.data ({wrRAM.din_real[i], wrRAM.din_imag[i]}),
		// .din_imag (wrRAM.din_imag[i]),

		.rden (rdRAM.rden[i]),
		.rdaddress (rdRAM.rdaddr[i]),
		.q ({rdRAM.dout_real[i], rdRAM.dout_imag[i]})
		// .dout_imag (rdRAM.dout_imag[i])
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
assign wrRAM.wraddr[i]= (fsm==Sink)? wrRAM_FSMsink.wraddr
                      : wrRAM_FSMrd.wraddr[i];
assign wrRAM.wren[i] = (fsm==Sink)? (wrRAM_FSMsink.wren[i] & valid_r[0])
                  : wrRAM_FSMrd.wren[i] ; 


assign rdRAM.rdaddr[i]= (fsm==Rd)? rdRAM_FSMrd.rdaddr[i] : bank_addr_source;
assign rdRAM.rden[i] = (fsm==Rd)? rdRAM_FSMrd.rden[i] : 
                 (rdRAM_FSMsource.rden[i] & fsm_lastRd_source);
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
assign out_data.exp = in_rdx2345_data.exp;


//------------------------------------------------
//------------------ 1st stage: Sink -------------
//------------------------------------------------
mrd_FSMsink #(
	mrd_mem_pkt::wADDR
	)
mrd_FSMsink_inst (
	clk,
	rst_n,

	fsm,
	fsm_r,

	ctrl,
	in_data,
	wrRAM_FSMsink,

	sink_3_4
);

//------------------------------------------------
//------------------ 2nd stage: Read -------------
//------------------------------------------------

mrd_FSMrd_rd #(
	in_dly
	)
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
	twdl_demontr,
	stage_of_rdx2,

	ctrl,
	rdRAM_FSMrd,
	out_rdx2345_data,

	rd_end,
	cnt_stage
);


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

	wr_end
);

//------------------------------------------------
//------------------ 4th stage: Source -----------
//------------------------------------------------
mrd_FSMsource 
mrd_FSMsource_inst (
	clk,
	rst_n,

	fsm,
	fsm_r,

	Nf,
	cnt_stage,
	dftpts,
	twdl_demontr,

	ctrl,
	rdRAM_FSMsource,
	out_data,
	in_rdx2345_data,

	addrs_butterfly_src,
	bank_addr_source,
	bank_index_source_r,
	fsm_lastRd_source,
	source_end
);


endmodule