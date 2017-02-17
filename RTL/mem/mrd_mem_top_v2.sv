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
//                |----|   |----|     ...      |------| 
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
	mrd_rdx2345_if  out_rdx2345_data,
	mrd_stat_if  stat_to_ctrl
);

logic [11:0]  dftpts;
logic [0:5][2:0] Nf;
logic [0:5][11:0] dftpts_div_Nf; 
logic [11:0]  bank_addr_sink;
logic [0:4][11:0]  addrs_butterfly_src;
logic [11:0]  bank_addr_source;
logic [2:0] bank_index_source_r;
logic [0:4][11:0]  twdl_numrtr;
logic [0:5][11:0]  twdl_demontr;
logic [2:0]  cnt_stage;
logic sink_3_4;
logic wr_ongoing, wr_ongoing_r;
logic [2:0] rd_ongoing_r;
logic fsm_lastRd_source;

mrd_mem_wr wrRAM();
mrd_mem_rd rdRAM();
mrd_mem_wr wrRAM_FSMrd();
mrd_mem_rd rdRAM_FSMrd();
mrd_mem_wr wrRAM_FSMsink();
mrd_mem_rd rdRAM_FSMsource();

logic [2:0] fsm, fsm_r;
parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
  			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;

assign stat_to_ctrl.sink_sop = in_data.sop;
assign stat_to_ctrl.dftpts = in_data.dftpts;

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
	twdl_demontr,

	ctrl,
	rdRAM_FSMrd,
	out_rdx2345_data,

	rd_ongoing_r,
	cnt_stage,
	twdl_numrtr
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

	wr_ongoing,
	wr_ongoing_r
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

	ctrl,
	rdRAM_FSMsource,
	out_data,
	stat_to_ctrl,

	addrs_butterfly_src,
	bank_addr_source,
	bank_index_source_r,
	fsm_lastRd_source
);


endmodule