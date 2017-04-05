module mrd_FSMsink #(parameter
	wADDR = 8 
	)
	(
	input clk,
	input rst_n,

	input [2:0] fsm,
	input [2:0] fsm_r,
	
	mrd_ctrl_if  ctrl,
	mrd_st_if  in_data,
	mrd_mem_wr wrRAM_FSMsink,

	output logic sink_3_4
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
localparam Rd = 3'd3;
logic [wADDR-1:0]  bank_addr_sink_pre;
logic [2:0]  bank_index_sink, bank_index_sink_pre;
logic [11:0]  addr_sink_CTA;

logic [11:0]  cnt_sink;

always@(posedge clk) begin
	wrRAM_FSMsink.wraddr[0] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[1] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[2] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[3] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[4] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[5] <= bank_addr_sink_pre;
	wrRAM_FSMsink.wraddr[6] <= bank_addr_sink_pre;
	bank_index_sink <= bank_index_sink_pre;
end

always@(posedge clk)
begin
	if (!rst_n) begin
		bank_addr_sink_pre <= 0;
		bank_index_sink_pre  <= 0;
	end
	else begin
		if (in_data.valid) begin
			bank_index_sink_pre <= (bank_index_sink_pre==3'd6) ?
			                       3'd0 : bank_index_sink_pre + 3'd1;
			bank_addr_sink_pre <= (bank_index_sink_pre==3'd6) ?
			                   bank_addr_sink_pre + 1'd1 : bank_addr_sink_pre;
		end
		else begin
			bank_addr_sink_pre <= 0;
			bank_index_sink_pre  <= 0;
		end
	end
end

always@(*)
begin
	case (bank_index_sink)
	3'd0:  wrRAM_FSMsink.wren = 7'b1000000;
	3'd1:  wrRAM_FSMsink.wren = 7'b0100000;
	3'd2:  wrRAM_FSMsink.wren = 7'b0010000;
	3'd3:  wrRAM_FSMsink.wren = 7'b0001000;
	3'd4:  wrRAM_FSMsink.wren = 7'b0000100;
	3'd5:  wrRAM_FSMsink.wren = 7'b0000010;
	3'd6:  wrRAM_FSMsink.wren = 7'b0000001;
	default: wrRAM_FSMsink.wren = 7'd0;
	endcase
end

always@(posedge clk)
begin 
	if(!rst_n)  begin
		sink_3_4 <= 0;
		cnt_sink <= 0;
	end
	else begin
		cnt_sink <= (in_data.valid)? cnt_sink+12'd1 : 12'd0;
		if (cnt_sink != 12'd0 && cnt_sink==
			// (ctrl.twdl_demontr[0] - ctrl.twdl_demontr[1] - 12'd1))
			(ctrl.twdl_demontr[0][11:2] + ctrl.twdl_demontr[0][11:1] - 12'd1))
			sink_3_4 <= 1'b1;
		else sink_3_4 <= 1'b0;
	end
end

endmodule