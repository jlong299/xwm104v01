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
//             perform ping-pong operation based on different packet.
//------------------------------------------------------------------

module mrd_ctrl_fsm (
	input clk,    
	input rst_n,  

	mrd_stat_if stat_from_mem0,
	mrd_stat_if stat_from_mem1,

	mrd_ctrl_if  ctrl_to_mem0,
	mrd_ctrl_if  ctrl_to_mem1,

	output reg sw_in,
	output reg sw_out,
	output reg sw_1to1
	
);

// logic [1:0]  fsm;
// logic [2:0]  cnt_stage, cnt_stage_r;
// logic wr_ongoing_mem0_r, wr_ongoing_mem1_r;

logic [2:0]  NumOfFactors;
logic [11:0]  dftpts_mem0, dftpts_mem1;

//-----------  1200 case ----------------
assign  NumOfFactors = 3'd5;

assign ctrl_to_mem0.NumOfFactors = NumOfFactors;
assign ctrl_to_mem1.NumOfFactors = NumOfFactors;
assign ctrl_to_mem0.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
assign ctrl_to_mem1.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
assign ctrl_to_mem0.dftpts_div_Nf[0:5] = 
            '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
assign ctrl_to_mem1.dftpts_div_Nf[0:5] = 
            '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
// twddle demoninator
assign ctrl_to_mem0.twdl_demontr[0:5] = 
            '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};
assign ctrl_to_mem1.twdl_demontr[0:5] = 
            '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};

always@(posedge clk)
begin
	if (!rst_n) begin
		dftpts_mem0 <= 0;
		dftpts_mem1 <= 0;
	end
	else begin
		dftpts_mem0 <= (sw_in==1'b0 && stat_from_mem0.sink_sop)? 
		               stat_from_mem0.dftpts : dftpts_mem0; 
		dftpts_mem1 <= (sw_in==1'b1 && stat_from_mem1.sink_sop)? 
		               stat_from_mem1.dftpts : dftpts_mem1; 
	end
end

always@(posedge clk)
begin
	if(!rst_n) begin
		sw_in <= 0;
		sw_out <= 0;
		sw_1to1 <= 0;
	end
	else begin
		if (stat_from_mem0.source_start)
			sw_in <= 1'b1;
		else if (stat_from_mem1.source_start)
			sw_in <= 1'b0;
		else
			sw_in <= sw_in;

		if (stat_from_mem0.source_end)
			sw_out <= 1'b1;
		else if (stat_from_mem1.source_end)
			sw_out <= 1'b0;
		else
			sw_out <= sw_out;

		if (stat_from_mem0.source_start)
			sw_1to1 <= 1'b1;
		else if (stat_from_mem1.source_start)
			sw_1to1 <= 1'b0;
		else
			sw_1to1 <= sw_1to1;
	end
end

endmodule