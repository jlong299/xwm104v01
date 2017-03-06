//-----------------------------------------------------------------
// Module Name:        	mrd_ctrl_fsm.sv
// Project:             Mixed Radix DFT
// Description:         Top control & FSM 
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1
//  Description : Ping Pong mem, sink and source may perform concurrently
//  2017-01-10
//------------------------------------------------------------------
//  INPUT
//    stat_from_mem0 :  State signals from mrd_mem_top 0.
//        1) sink_sop
//        2) dftpts : valid when sink_sop==1
//        3) sink_ongoing :  =1 when sink process is ongoing
//        4) source_ongoing :  =1 when source process is ongoing
//        5) rd_ongoing :  =1 when rd process is ongoing
//        6) wr_ongoing :  =1 when wr process is ongoing
//  OUTPUT
//    ctrl_to_mem0 :  Ctrl signals to mrd_mem_top 0.
//        1) state :  set state of mrd_mem_top
//               00 sink; 
//               11 source; 
//               01 rd;  
//               10 wr
//        2) current_stage :  tell mrd_mem_top current stage number
//        3) parameters :   Nf, Nf_PFA, q_p, ....  (See matlab codes)
//------------------------------------------------------------------
//  FSM :
//    s0:  wait, meanwhile source process may perform
//     |
//     | sink_sop
//     |
//    s1:  sink new DFT frame, meanwhile source process may perform
//     |
//     | sink finished & source finished
//     |
//    s2:  calculate DFT stages, PFA & CTA combined algorithm
//     |
//     | all stages complemented
//     |
//    s3:  start source process, then go to s0 at once
//
//------------------------------------------------------------------
//  Version 0.2
//  Description : Ping Pong mem, sink and source may perform concurrently
//  2017-02-09
//  Changes :  One packet only be processed in one mem.  mem0 and mem1
//             perform ping-pong operation based on packet.
//------------------------------------------------------------------
//  Version 0.3
//  2017-02-14
//  Changes :  Remove mem1. Only 1 RAM to reduce FPGA storage utilization
//------------------------------------------------------------------

module mrd_ctrl_fsm (
	input clk,    
	input rst_n,  

	input sink_sop,
	input [11:0]  dftpts,

	mrd_ctrl_if  ctrl_to_mem
);

logic [2:0]  NumOfFactors;
logic [11:0]  dftpts_mem;

logic [11:0]  N_iter;
logic [0:5][2:0] Nf;
logic [0:5][11:0] dftpts_div_Nf; 
logic [0:5][11:0] twdl_demontr;
logic [2:0] j;
logic [2:0] stage_of_rdx2;

//-----------  1200 case ----------------
// assign ctrl_to_mem0.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
// assign ctrl_to_mem1.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
// assign ctrl_to_mem0.dftpts_div_Nf[0:5] = 
//             '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
// assign ctrl_to_mem1.dftpts_div_Nf[0:5] = 
//             '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
// // twddle demoninator
// assign ctrl_to_mem0.twdl_demontr[0:5] = 
//             '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};
// assign ctrl_to_mem1.twdl_demontr[0:5] = 
//             '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};


// //-----------  1200 case ----------------\
// assign ctrl_to_mem.NumOfFactors = 3'd5;
// assign ctrl_to_mem.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
// assign ctrl_to_mem.dftpts_div_Nf[0:5] = 
//             '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
// assign ctrl_to_mem.twdl_demontr[0:5] = 
//             '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};

// assign ctrl_to_mem.stage_of_rdx2 = 3'd7;


assign ctrl_to_mem.NumOfFactors = NumOfFactors;
assign ctrl_to_mem.Nf = Nf;
assign ctrl_to_mem.dftpts_div_Nf = dftpts_div_Nf;
// twddle demoninator
assign ctrl_to_mem.twdl_demontr = twdl_demontr;
assign ctrl_to_mem.stage_of_rdx2 = stage_of_rdx2;

logic [2:0]  cnt_Nf, next_factor;
// Compute parameters
always@(posedge clk)
begin
	if (!rst_n) 
	begin
		Nf <= 0;
		dftpts_div_Nf <= 0;
		twdl_demontr <= 0;
		cnt_Nf <= 0;
		N_iter <= 0;
		NumOfFactors <= 0;
		stage_of_rdx2 <= 0;
	end
	else begin
		if (sink_sop)
			cnt_Nf <= 3'd1;
		else if (cnt_Nf != 3'd0 && cnt_Nf != 3'd6)
			cnt_Nf <= cnt_Nf + 3'd1;
		else
			cnt_Nf <= 0;

		if (sink_sop) 
			N_iter <= dftpts;
		else if (cnt_Nf != 0) 
			N_iter <= N_iter/next_factor;
		else N_iter <= N_iter;

		for (j=3'd0; j<=3'd5; j++) begin
			Nf[j] <= (cnt_Nf == j+3'd1)? next_factor : Nf[j];
			dftpts_div_Nf[j] <= (cnt_Nf == j+3'd1)? 
			                 twdl_demontr[0]/next_factor : dftpts_div_Nf[j];
		end

		if (sink_sop) 
			twdl_demontr[0] <= dftpts;
		else twdl_demontr[0] <= twdl_demontr[0];
		
		for (j=3'd1; j<=3'd5; j++) begin
			twdl_demontr[j] <= (cnt_Nf == j)? twdl_demontr[j-1]/next_factor
			                                  : twdl_demontr[j];
		end

		if (sink_sop)
			NumOfFactors <= 3'd0;
		else if (cnt_Nf != 3'd0 && next_factor != 3'd1)
			NumOfFactors <= NumOfFactors + 3'd1;
		else
			NumOfFactors <= NumOfFactors;

		if (sink_sop)
			stage_of_rdx2 <= 3'd7;
		else if (next_factor==3'd2)
			stage_of_rdx2 <= NumOfFactors;
		else
			stage_of_rdx2 <= stage_of_rdx2;
	end
end

always@(*)
	if ( (N_iter % 3'd4)==0 )
		next_factor = 3'd4;
	else if ( (N_iter % 3'd2)==0 )
		next_factor = 3'd2;
	else if ( (N_iter % 3'd5)==0 )
		next_factor = 3'd5;
	else if ( (N_iter % 3'd3)==0 )
		next_factor = 3'd3;
	else
		next_factor = 3'd1;

endmodule