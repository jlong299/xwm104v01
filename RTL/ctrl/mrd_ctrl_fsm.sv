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

	input [2:0] fsm,
	input sink_sop,
	// input [11:0]  dftpts,
	input [5:0] size,

	mrd_ctrl_if  ctrl_to_mem
);

// logic [2:0]  NumOfFactors;
// logic [11:0]  N_iter;
// logic [0:5][2:0] Nf;
// logic [0:5][11:0] dftpts_div_Nf; 
// logic [0:5][11:0] twdl_demontr;
// logic [2:0] j;
// logic [2:0] stage_of_rdx2;

logic [2:0] j;
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


logic sink_sop_r1, sink_sop_r2, sink_sop_r3, start_calc_param;
logic [2:0] start_calc_param_r ;
always@(posedge clk)  sink_sop_r1 <= sink_sop;
always@(posedge clk)  sink_sop_r2 <= sink_sop_r1;
always@(posedge clk)  sink_sop_r3 <= sink_sop_r2;
always@(posedge clk)  start_calc_param <= ~sink_sop_r2 & sink_sop_r3;

logic [11:0] dftpts_div_base;
logic factor_5;
logic [6:0] rdaddr_ROM;
logic [63:0] q_ROM;

always@(posedge clk) begin
if (!rst_n) rdaddr_ROM <= 0;
else 
	if (sink_sop) rdaddr_ROM <= {size,1'b0};
	else if (sink_sop_r1) rdaddr_ROM <= {size,1'b1};
end

always@(posedge clk) begin
if (!rst_n) begin
	factor_5 <= 0;
	ctrl_to_mem.stage_of_rdx2 <= 0;
	ctrl_to_mem.remainder[0] <= 0;
	ctrl_to_mem.quotient[0] <= 0;
	ctrl_to_mem.twdl_demontr[0] <= 0;
	dftpts_div_base <= 0;
	ctrl_to_mem.Nf <= 0;
	ctrl_to_mem.NumOfFactors <= 0;
end
else begin
	ctrl_to_mem.Nf[0] <= 3'd4;
	if (~sink_sop_r1 & sink_sop_r2) begin
		ctrl_to_mem.twdl_demontr[0] <= q_ROM[11:0];
		dftpts_div_base <= q_ROM[23:12];
		ctrl_to_mem.Nf[5] <= q_ROM[26:24];
		ctrl_to_mem.Nf[4] <= q_ROM[29:27];
		ctrl_to_mem.Nf[3] <= q_ROM[32:30];
		ctrl_to_mem.Nf[2] <= q_ROM[35:33];
		ctrl_to_mem.Nf[1] <= q_ROM[38:36];
		ctrl_to_mem.NumOfFactors <= q_ROM[41:39];
	end
	else begin
		ctrl_to_mem.twdl_demontr[0] <= ctrl_to_mem.twdl_demontr[0];
		dftpts_div_base <= dftpts_div_base;
		ctrl_to_mem.Nf[5] <= ctrl_to_mem.Nf[5];
		ctrl_to_mem.Nf[4] <= ctrl_to_mem.Nf[4];
		ctrl_to_mem.Nf[3] <= ctrl_to_mem.Nf[3];
		ctrl_to_mem.Nf[2] <= ctrl_to_mem.Nf[2];
		ctrl_to_mem.Nf[1] <= ctrl_to_mem.Nf[1];
		ctrl_to_mem.NumOfFactors <= ctrl_to_mem.NumOfFactors;
	end

	if (~sink_sop_r2 & sink_sop_r3) begin
		factor_5 <= q_ROM[0];
		ctrl_to_mem.stage_of_rdx2 <= q_ROM[3:1];
		ctrl_to_mem.remainder[0] <= q_ROM[15:4];
		ctrl_to_mem.quotient[0] <= q_ROM[35:16];
	end
	else begin
		factor_5 <= factor_5;
		ctrl_to_mem.stage_of_rdx2 <= ctrl_to_mem.stage_of_rdx2;
		ctrl_to_mem.remainder[0] <= ctrl_to_mem.remainder[0];
		ctrl_to_mem.quotient[0] <= ctrl_to_mem.quotient[0];
	end
end
end

mrd_ROM_Init_fake 
mrd_ROM_Init_fake_inst (
	clk,
	rdaddr_ROM,
	q_ROM
);

wire [11:0] dft_size;
assign dft_size = ctrl_to_mem.twdl_demontr[0];


// //-----------------------------------------------------
// //-----------  1200 case ----------------\
// assign ctrl_to_mem.NumOfFactors = 3'd5;
// assign ctrl_to_mem.Nf[0:5] = '{3'd4,3'd4,3'd5,3'd5,3'd3,3'd1};
// // assign ctrl_to_mem.dftpts_div_Nf[0:5] = 
// //             '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
// assign dftpts_div_base = 12'd80;  // N/3  or N/3/5  (depends on factor_5)
// // assign ctrl_to_mem.twdl_demontr[0:5] = 
// //             '{12'd1200,12'd300,12'd75,12'd15,12'd3,12'd1};
// assign ctrl_to_mem.twdl_demontr[0] = 12'd1200;

// assign ctrl_to_mem.stage_of_rdx2 = 3'd7;

// assign factor_5 = 1'b1;  // Is 5 a factor of current size ?

// wire [11:0] dft_size;
// assign dft_size = ctrl_to_mem.twdl_demontr[0];

// // assign ctrl_to_mem.quotient = '{20'd873,20'd3495,20'd13981,20'd69905,20'd349525,20'd0};
// // assign ctrl_to_mem.remainder = '{12'd976,12'd76,12'd1,12'd1,12'd1,12'd0};

//  //----- exmaple 1200 --------
//  // 2^20 = 1200 * 873 + 976
//  // 2^20 = 300 * 3495 + 76
//  // 2^20 = 75 * 13981 + 1
//  // 2^20 = 15 * 69905 + 1
//  // 2^20 = 3 * 349525 + 1

//  //   quot                  remd
//  //   873                   976
//  //   873*2  cnt_quot=1     976-300           cnt_remd = 1
//  //   873*3  cnt_quot=2     976-300*2         cnt_remd = 2
//  //   873*4  cnt_quot=3     976-300*3 < 300   cnt_remd = 3
//  //   quotient[k]= quot + 3

// always@(posedge clk) ctrl_to_mem.quotient[0] <= 20'd873;
// always@(posedge clk) ctrl_to_mem.remainder[0] <= 12'd976;


//------------------ctrl_to_mem.dftpts_div_Nf[0:5]-----------------------
// assign ctrl_to_mem.dftpts_div_Nf[0:5] = '{12'd300,12'd300,12'd240,12'd240,12'd400,12'd1200};
always@(posedge clk) begin
	if (!rst_n) ctrl_to_mem.dftpts_div_Nf[0:5] <= {6{12'd0}};
	else begin
		if (start_calc_param) begin
			ctrl_to_mem.dftpts_div_Nf[0] <= dft_size[11:2];

			for (j=1; j<=5; j++) begin 
				if (ctrl_to_mem.Nf[j]==3'd4)
					ctrl_to_mem.dftpts_div_Nf[j] <= dft_size[11:2];
				else if (ctrl_to_mem.Nf[j]==3'd2)
					ctrl_to_mem.dftpts_div_Nf[j] <= dft_size[11:1];
				else if (ctrl_to_mem.Nf[j]==3'd3)
					ctrl_to_mem.dftpts_div_Nf[j] <= (factor_5==1'b0)?
					    dftpts_div_base : dftpts_div_base+ {dftpts_div_base,2'b00};
				else if (ctrl_to_mem.Nf[j]==3'd5)
					ctrl_to_mem.dftpts_div_Nf[j] <= dftpts_div_base+ {dftpts_div_base,1'b0};
				else
					ctrl_to_mem.dftpts_div_Nf[j] <= 12'd0;
			end
		end
		else
			ctrl_to_mem.dftpts_div_Nf[0:5] <= ctrl_to_mem.dftpts_div_Nf[0:5];
	end
end
//-----------------------------------------------------------------

//--------------------ctrl_to_mem.twdl_demontr[1:4]-------------------------------------
always@(posedge clk) begin
	if (!rst_n)  start_calc_param_r <= 0;
	else start_calc_param_r[2:0] <= {start_calc_param_r[1:0], start_calc_param};
end
always@(posedge clk) begin
	if (!rst_n) ctrl_to_mem.twdl_demontr[1:5] <= {5{12'd0}};
	else begin
		if (start_calc_param) ctrl_to_mem.twdl_demontr[5] <= ctrl_to_mem.Nf[5];
		else ctrl_to_mem.twdl_demontr[5] <= ctrl_to_mem.twdl_demontr[5];

		if (start_calc_param) begin
			if (ctrl_to_mem.Nf[4]==3'd3) 
				ctrl_to_mem.twdl_demontr[4] <= ctrl_to_mem.Nf[5] + {ctrl_to_mem.Nf[5],1'b0};
			else if (ctrl_to_mem.Nf[4]==3'd5)
				ctrl_to_mem.twdl_demontr[4] <= ctrl_to_mem.Nf[5] + {ctrl_to_mem.Nf[5],2'b00};
			else if (ctrl_to_mem.Nf[4]==3'd4)
				ctrl_to_mem.twdl_demontr[4] <= {ctrl_to_mem.Nf[5],2'b00};
			else if (ctrl_to_mem.Nf[4]==3'd2)
				ctrl_to_mem.twdl_demontr[4] <= {ctrl_to_mem.Nf[5],1'b0};
			else
				ctrl_to_mem.twdl_demontr[4] <= ctrl_to_mem.Nf[5];
		end
		else ctrl_to_mem.twdl_demontr[4] <= ctrl_to_mem.twdl_demontr[4];

		if (start_calc_param_r[0]) begin
			if (ctrl_to_mem.Nf[3]==3'd3) 
				ctrl_to_mem.twdl_demontr[3] <= ctrl_to_mem.twdl_demontr[4] + {ctrl_to_mem.twdl_demontr[4],1'b0};
			else if (ctrl_to_mem.Nf[3]==3'd5)
				ctrl_to_mem.twdl_demontr[3] <= ctrl_to_mem.twdl_demontr[4] + {ctrl_to_mem.twdl_demontr[4],2'b00};
			else if (ctrl_to_mem.Nf[3]==3'd4)
				ctrl_to_mem.twdl_demontr[3] <= {ctrl_to_mem.twdl_demontr[4],2'b00};
			else if (ctrl_to_mem.Nf[3]==3'd2)
				ctrl_to_mem.twdl_demontr[3] <= {ctrl_to_mem.twdl_demontr[4],1'b0};
			else
				ctrl_to_mem.twdl_demontr[3] <= ctrl_to_mem.twdl_demontr[4];
		end
		else ctrl_to_mem.twdl_demontr[3] <= ctrl_to_mem.twdl_demontr[3];

		if (start_calc_param_r[1]) begin
			if (ctrl_to_mem.Nf[2]==3'd3) 
				ctrl_to_mem.twdl_demontr[2] <= ctrl_to_mem.twdl_demontr[3] + {ctrl_to_mem.twdl_demontr[3],1'b0};
			else if (ctrl_to_mem.Nf[2]==3'd5)
				ctrl_to_mem.twdl_demontr[2] <= ctrl_to_mem.twdl_demontr[3] + {ctrl_to_mem.twdl_demontr[3],2'b00};
			else if (ctrl_to_mem.Nf[2]==3'd4)
				ctrl_to_mem.twdl_demontr[2] <= {ctrl_to_mem.twdl_demontr[3],2'b00};
			else if (ctrl_to_mem.Nf[2]==3'd2)
				ctrl_to_mem.twdl_demontr[2] <= {ctrl_to_mem.twdl_demontr[3],1'b0};
			else
				ctrl_to_mem.twdl_demontr[2] <= ctrl_to_mem.twdl_demontr[3];
		end
		else ctrl_to_mem.twdl_demontr[2] <= ctrl_to_mem.twdl_demontr[2];

		if (start_calc_param_r[2]) begin
			if (ctrl_to_mem.Nf[1]==3'd3) 
				ctrl_to_mem.twdl_demontr[1] <= ctrl_to_mem.twdl_demontr[2] + {ctrl_to_mem.twdl_demontr[2],1'b0};
			else if (ctrl_to_mem.Nf[1]==3'd5)
				ctrl_to_mem.twdl_demontr[1] <= ctrl_to_mem.twdl_demontr[2] + {ctrl_to_mem.twdl_demontr[2],2'b00};
			else if (ctrl_to_mem.Nf[1]==3'd4)
				ctrl_to_mem.twdl_demontr[1] <= {ctrl_to_mem.twdl_demontr[2],2'b00};
			else if (ctrl_to_mem.Nf[1]==3'd2)
				ctrl_to_mem.twdl_demontr[1] <= {ctrl_to_mem.twdl_demontr[2],1'b0};
			else
				ctrl_to_mem.twdl_demontr[1] <= ctrl_to_mem.twdl_demontr[2];
		end
		else ctrl_to_mem.twdl_demontr[1] <= ctrl_to_mem.twdl_demontr[1];
	end
end
//---------------------------------------------------------------------


// //-----------------------------------------------------
// //-----------  1152 case ----------------\
// assign ctrl_to_mem.NumOfFactors = 3'd6;
// assign ctrl_to_mem.Nf[0:5] = '{3'd4,3'd4,3'd4,3'd2,3'd3,3'd3};
// assign ctrl_to_mem.dftpts_div_Nf[0:5] = 
//             '{12'd288,12'd288,12'd288,12'd576,12'd384,12'd384};
// assign ctrl_to_mem.twdl_demontr[0:5] = 
//             '{12'd1152,12'd288,12'd72,12'd18,12'd9,12'd3};

// assign ctrl_to_mem.stage_of_rdx2 = 3'd3;


// //--------
// logic sink_sop_r, start_calc_param ;
// always@(posedge clk)  sink_sop_r <= sink_sop;
// assign start_calc_param = ~sink_sop & sink_sop_r;

//  //----- exmaple 1152 --------
//  // 2^20 = 1152 * 910 + 256

// assign ctrl_to_mem.quotient[0] = 20'd910;
// assign ctrl_to_mem.remainder[0] = 12'd256;
// //--------------------------------------------------------------------------


logic [2:0]  cnt_quot, index, cnt_remd;
logic [20-1:0] quot ;
logic [12-1:0] remd ;
logic flag_index_change;
assign flag_index_change = (fsm != 3'd0) && (cnt_quot==ctrl_to_mem.Nf[index]-3'd1) ;
always@(posedge clk) begin
	if (!rst_n) begin
		index <= 0;
		cnt_quot <= 0;
		ctrl_to_mem.quotient[1] <= 0;
		ctrl_to_mem.quotient[2] <= 0;
		ctrl_to_mem.quotient[3] <= 0;
		ctrl_to_mem.quotient[4] <= 0;
		ctrl_to_mem.quotient[5] <= 0;
		ctrl_to_mem.remainder[1] <= 0;
		ctrl_to_mem.remainder[2] <= 0;
		ctrl_to_mem.remainder[3] <= 0;
		ctrl_to_mem.remainder[4] <= 0;
		ctrl_to_mem.remainder[5] <= 0;
		quot <= 0;
		remd <= 0;
		cnt_remd <= 0;
	end
	else begin
		if (start_calc_param_r[2]) index <= 3'd0;
		else if (index==3'd5)  index <= 3'd5;
		else index <= (flag_index_change)? index+3'd1 : index;

		if (start_calc_param_r[2]) cnt_quot <= 3'd0;
		else if ((index==3'd4 && flag_index_change) || index==3'd5 ) cnt_quot <= 3'd6;
		else cnt_quot <= (flag_index_change)? 3'd0 : cnt_quot+3'd1;

		if (start_calc_param_r[2])   ctrl_to_mem.quotient[1:5] <= { {4{20'd0}}, ctrl_to_mem.quotient[0] };
		else begin
			ctrl_to_mem.quotient[1:4] <= (flag_index_change)? ctrl_to_mem.quotient[2:5] : ctrl_to_mem.quotient[1:4];
			ctrl_to_mem.quotient[5] <= (flag_index_change)? quot+cnt_remd : ctrl_to_mem.quotient[5];
		end

		if (start_calc_param_r[2])  quot <= ctrl_to_mem.quotient[0];
		else quot <= (flag_index_change)? quot+cnt_remd : quot+ctrl_to_mem.quotient[5];

		if (start_calc_param_r[2])  cnt_remd <= 0;
		else if (index==3'd4) cnt_remd <= 0;
		else if (flag_index_change) cnt_remd <= 0;
		else cnt_remd <= (remd < ctrl_to_mem.twdl_demontr[index+3'd1] )? cnt_remd : cnt_remd+3'd1;

		if (start_calc_param_r[2])  remd <= ctrl_to_mem.remainder[0];
		else remd <= (remd < ctrl_to_mem.twdl_demontr[index+3'd1] )? remd : remd-ctrl_to_mem.twdl_demontr[index+3'd1];

		if (start_calc_param_r[2])   ctrl_to_mem.remainder[1:5] <= { {4{12'd0}}, ctrl_to_mem.remainder[0] };
		else begin
			ctrl_to_mem.remainder[1:4] <= (flag_index_change)? ctrl_to_mem.remainder[2:5] : ctrl_to_mem.remainder[1:4];
			ctrl_to_mem.remainder[5] <= (flag_index_change)? remd : ctrl_to_mem.remainder[5];
		end
	end
end


// assign ctrl_to_mem.NumOfFactors = NumOfFactors;
// assign ctrl_to_mem.Nf = Nf;
// assign ctrl_to_mem.dftpts_div_Nf = dftpts_div_Nf;
// // twddle demoninator
// assign ctrl_to_mem.twdl_demontr = twdl_demontr;
// assign ctrl_to_mem.stage_of_rdx2 = stage_of_rdx2;

// logic [2:0]  cnt_Nf, next_factor;
// // Compute parameters
// always@(posedge clk)
// begin
// 	if (!rst_n) 
// 	begin
// 		Nf <= 0;
// 		dftpts_div_Nf <= 0;
// 		twdl_demontr <= 0;
// 		cnt_Nf <= 0;
// 		N_iter <= 0;
// 		NumOfFactors <= 0;
// 		stage_of_rdx2 <= 0;
// 	end
// 	else begin
// 		if (sink_sop)
// 			cnt_Nf <= 3'd1;
// 		else if (cnt_Nf != 3'd0 && cnt_Nf != 3'd6)
// 			cnt_Nf <= cnt_Nf + 3'd1;
// 		else
// 			cnt_Nf <= 0;

// 		if (sink_sop) 
// 			N_iter <= dftpts;
// 		else if (cnt_Nf != 0) 
// 			N_iter <= N_iter/next_factor;
// 		else N_iter <= N_iter;

// 		for (j=3'd0; j<=3'd5; j++) begin
// 			Nf[j] <= (cnt_Nf == j+3'd1)? next_factor : Nf[j];
// 			dftpts_div_Nf[j] <= (cnt_Nf == j+3'd1)? 
// 			                 twdl_demontr[0]/next_factor : dftpts_div_Nf[j];
// 		end

// 		if (sink_sop) 
// 			twdl_demontr[0] <= dftpts;
// 		else twdl_demontr[0] <= twdl_demontr[0];
		
// 		for (j=3'd1; j<=3'd5; j++) begin
// 			twdl_demontr[j] <= (cnt_Nf == j)? twdl_demontr[j-1]/next_factor
// 			                                  : twdl_demontr[j];
// 		end

// 		if (sink_sop)
// 			NumOfFactors <= 3'd0;
// 		else if (cnt_Nf != 3'd0 && next_factor != 3'd1)
// 			NumOfFactors <= NumOfFactors + 3'd1;
// 		else
// 			NumOfFactors <= NumOfFactors;

// 		if (sink_sop)
// 			stage_of_rdx2 <= 3'd7;
// 		else if (next_factor==3'd2)
// 			stage_of_rdx2 <= NumOfFactors;
// 		else
// 			stage_of_rdx2 <= stage_of_rdx2;
// 	end
// end

// always@(*)
// 	if ( (N_iter % 3'd4)==0 )
// 		next_factor = 3'd4;
// 	else if ( (N_iter % 3'd2)==0 )
// 		next_factor = 3'd2;
// 	else if ( (N_iter % 3'd5)==0 )
// 		next_factor = 3'd5;
// 	else if ( (N_iter % 3'd3)==0 )
// 		next_factor = 3'd3;
// 	else
// 		next_factor = 3'd1;

endmodule