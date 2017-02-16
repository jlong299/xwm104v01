module mrd_FSMsink (
	input clk,
	input rst_n,

	input [2:0] fsm,
	input [2:0] fsm_r,

	mrd_ctrl_if  ctrl,
	mrd_st_if  in_data,
	mrd_mem_wr wrRAM_FSMsink,

	output logic [11:0] bank_addr_sink,  //!!!???  7:0
	output logic sink_3_4,

	output logic [11:0]  dftpts,
	output logic [0:5][2:0] Nf,
	output logic [0:5][11:0] dftpts_div_Nf, 
	output logic [0:5][11:0]  twdl_demontr
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
parameter Rd = 3'd3;
logic [11:0]  bank_addr_sink_pre;
logic [2:0]  bank_index_sink, bank_index_sink_pre;
logic [11:0]  addr_sink_CTA;

logic [11:0]  cnt_sink;

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
		cnt_sink <= (in_data.valid)? cnt_sink+12'd1 : 0;
		if (cnt_sink != 12'd0 && cnt_sink==
			(ctrl.twdl_demontr[0] - ctrl.twdl_demontr[1] - 12'd1))
			sink_3_4 <= 1'b1;
		else sink_3_4 <= 1'b0;
	end
end

endmodule