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

module mrd_ctrl_fsm (
	input clk,    
	input rst_n,  

	mrd_stat_if stat_from_mem0,
	mrd_stat_if stat_from_mem1,

	//output reg [2:0] fsm,
	mrd_ctrl_if  ctrl_to_mem0,
	mrd_ctrl_if  ctrl_to_mem1,

	output reg sw_in,
	output reg sw_out,
	output reg sw_1to0
	
);

logic [1:0]  fsm;
logic [2:0]  cnt_stage;
logic wr_ongoing_mem0_r, wr_ongoing_mem1_r;

logic [2:0]  NumOfFactors;

//-----------  1200 case ----------------
assign  NumOfFactors = 3'd5;

assign ctrl_to_mem0.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
assign ctrl_to_mem1.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
assign ctrl_to_mem0.Nf_PFA[0:2] = '{10'd16, 10'd25, 10'd3};
assign ctrl_to_mem1.Nf_PFA[0:2] = '{10'd16, 10'd25, 10'd3};
assign ctrl_to_mem0.q_p = 10'd3;
assign ctrl_to_mem1.q_p = 10'd3;
assign ctrl_to_mem0.r_p = 10'd17;
assign ctrl_to_mem1.r_p = 10'd17;

always@(posedge clk)
begin
	if (!rst_n)
	begin
		fsm <= 0;
	end
	else
	begin
		case (fsm)
		// s0, wait
		2'd0: 
		begin
			fsm <= (stat_from_mem0.sink_sop | stat_from_mem1.sink_sop) ?
			        2'd1 : 2'd0;
		end
		// s1, sink data
		2'd1:
		begin
			if ( (!stat_from_mem0.sink_ongoing) 
				 & (!stat_from_mem1.sink_ongoing)
			     & (!stat_from_mem0.source_ongoing) 
			     & (!stat_from_mem1.source_ongoing) )				
				fsm <= 2'd2;
			else 
				fsm <= 2'd1;
		end
		// s2, DFT computation
		2'd2:
		begin
			fsm <= (cnt_stage==NumOfFactors) ? 2'd3 : 2'd2;
		end
		// s3, source data
		2'd3:
		begin
			fsm <= 2'd0;
		end
		endcase
	end
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		sw_in <= 0;
		sw_out <= 0;
		sw_1to0 <= 0;
	end
	else
	begin
		case (fsm)
		2'd2:
		begin
			sw_in <= sw_in;
			sw_out <= (NumOfFactors[0])? ~sw_in : sw_in;
			sw_1to0 <= sw_in ^ cnt_stage[0];
		end
		2'd3:
		begin
			sw_in <= ~sw_out;
			sw_out <= sw_out;
			sw_1to0 <= 0;
		end
		default:
		begin
			sw_in <= sw_in;
			sw_out <= sw_out;
			sw_1to0 <= 0;
		end
		endcase
	end
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		cnt_stage <= 0;
		wr_ongoing_mem0_r <= 0;
		wr_ongoing_mem1_r <= 0;
	end
	else
	begin
		wr_ongoing_mem0_r <= stat_from_mem0.wr_ongoing;
		wr_ongoing_mem1_r <= stat_from_mem1.wr_ongoing;
		if (fsm==2'd2)
		begin
			if ((sw_1to0 & ~(stat_from_mem0.wr_ongoing) & wr_ongoing_mem0_r)
			  | (~sw_1to0 & ~(stat_from_mem1.wr_ongoing) & wr_ongoing_mem1_r))
			    cnt_stage <= cnt_stage+3'd1 ;
			else
				cnt_stage <= cnt_stage;
		end
		else
			cnt_stage <= 0;
	end
end


always@(posedge clk)
begin
	if (!rst_n)
	begin
		ctrl_to_mem0.state <= 0;
		ctrl_to_mem1.state <= 0;
		ctrl_to_mem0.current_stage <= 0;
		ctrl_to_mem1.current_stage <= 0;
	end
	else
	begin
		case (fsm)
		2'd0, 2'd1:
		begin
			ctrl_to_mem0.state <= (sw_in) ? ctrl_to_mem0.state : 2'b00;
			ctrl_to_mem1.state <= (!sw_in) ? ctrl_to_mem1.state : 2'b00;
			ctrl_to_mem0.current_stage <= 0;
			ctrl_to_mem1.current_stage <= 0;
		end
		2'd2:
		begin
			ctrl_to_mem0.state <= (sw_in ^ cnt_stage[0]) ? 2'b10 : 2'b01;
			ctrl_to_mem1.state <= (sw_in ^ cnt_stage[0]) ? 2'b01 : 2'b10;
			ctrl_to_mem0.current_stage <= cnt_stage;
			ctrl_to_mem1.current_stage <= cnt_stage;
		end
		2'd3:
		begin
			ctrl_to_mem0.state <= (sw_out) ? 2'b00 : 2'b11;
			ctrl_to_mem1.state <= (sw_out) ? 2'b11 : 2'b00;
			ctrl_to_mem0.current_stage <= 0;
			ctrl_to_mem1.current_stage <= 0;
		end
		endcase
	end
end

endmodule