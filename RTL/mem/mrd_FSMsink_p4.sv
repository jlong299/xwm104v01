module mrd_FSMsink_p4 #(parameter
	wADDR = 8 
	)
	(
	input clk,
	input rst_n,

	input [2:0] fsm,
	
	mrd_ctrl_if  ctrl,
	mrd_st_if_p4  in_data,
	mrd_mem_wr wrRAM_FSMsink,

	output logic sink_end,
	output logic overTime
	// output logic twdl_sop_sink
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
localparam Idle = 3'd0, Sink = 3'd1;

logic [wADDR-1:0]  bank_addr_sink [0:3];
logic unsigned [2:0]  bank_index_sink [0:3];
logic [11:0]  addr_sink_CTA;

logic [11:0]  cnt_sink;

genvar i;
generate
for (i=3'd0; i<=3'd3; i=i+3'd1) begin : u0
	always@(posedge clk) begin
		if (!rst_n) begin
			bank_index_sink[i] <= 0;
			bank_addr_sink[i] <= 0;
		end
		else begin
			if (in_data.valid==1'b0) begin
				bank_index_sink[i] <= i;
				bank_addr_sink[i] <= 0;
			end
			else begin
				if (bank_index_sink[i] <= 3'd2) begin
					bank_index_sink[i] <= bank_index_sink[i] + 3'd4;
					bank_addr_sink[i] <= bank_addr_sink[i];
				end
				else begin
					bank_index_sink[i] <= bank_index_sink[i] - 3'd3;
					bank_addr_sink[i] <= bank_addr_sink[i] + 2'd1;
				end
			end
		end
	end
end
endgenerate

generate 
for (i=3'd0; i<=3'd6; i=i+3'd1) begin : u1
	always@(posedge clk) begin
		if (!rst_n) begin
			wrRAM_FSMsink.wren[i] <= 0;
			wrRAM_FSMsink.wraddr[i] <= 0;
			wrRAM_FSMsink.din_real[i] <= 0;
			wrRAM_FSMsink.din_imag[i] <= 0;
		end
		else begin
			if (in_data.valid) begin
				if (bank_index_sink[0] == i) begin
					wrRAM_FSMsink.wren[i] <= 1'b1;
					wrRAM_FSMsink.wraddr[i] <= bank_addr_sink[0];
					wrRAM_FSMsink.din_real[i] <= in_data.din_real[0];
					wrRAM_FSMsink.din_imag[i] <= in_data.din_imag[0];
				end
				else if (bank_index_sink[1] == i) begin
					wrRAM_FSMsink.wren[i] <= 1'b1;
					wrRAM_FSMsink.wraddr[i] <= bank_addr_sink[1];
					wrRAM_FSMsink.din_real[i] <= in_data.din_real[1];
					wrRAM_FSMsink.din_imag[i] <= in_data.din_imag[1];
				end
				else if (bank_index_sink[2] == i) begin
					wrRAM_FSMsink.wren[i] <= 1'b1;
					wrRAM_FSMsink.wraddr[i] <= bank_addr_sink[2];
					wrRAM_FSMsink.din_real[i] <= in_data.din_real[2];
					wrRAM_FSMsink.din_imag[i] <= in_data.din_imag[2];
				end
				else if (bank_index_sink[3] == i) begin
					wrRAM_FSMsink.wren[i] <= 1'b1;
					wrRAM_FSMsink.wraddr[i] <= bank_addr_sink[3];
					wrRAM_FSMsink.din_real[i] <= in_data.din_real[3];
					wrRAM_FSMsink.din_imag[i] <= in_data.din_imag[3];
				end
				else begin
					wrRAM_FSMsink.wren[i] <= 1'b0;
					wrRAM_FSMsink.wraddr[i] <= 0;
					wrRAM_FSMsink.din_real[i] <= 0;
					wrRAM_FSMsink.din_imag[i] <= 0;
				end
			end
			else begin
				wrRAM_FSMsink.wren[i] <= 1'b0;
				wrRAM_FSMsink.wraddr[i] <= 0;
				wrRAM_FSMsink.din_real[i] <= 0;
				wrRAM_FSMsink.din_imag[i] <= 0;
			end
		end
	end
end
endgenerate

logic [11:0] cnt_overTime;
always@(posedge clk)
begin 
	if(!rst_n)  begin
		sink_end <= 0;
		cnt_sink <= 0;
		cnt_overTime <= 0;
		overTime <= 0;
		// twdl_sop_sink <= 0;
	end
	else begin
		cnt_sink <= (in_data.valid)? cnt_sink+12'd1 : 12'd0;
		if (cnt_sink != 12'd0 && cnt_sink==ctrl.twdl_demontr[0][11:2])
			sink_end <= 1'b1;
		else sink_end <= 1'b0;

		cnt_overTime <= (fsm==Sink)? cnt_overTime + 12'd1 : 12'd0;
		overTime <= (cnt_overTime==12'd2047)? 1'b1 : 1'b0;

		// twdl_sop_sink <= (cnt_sink==ctrl.twdl_demontr[0][11:2] + ctrl.twdl_demontr[0][11:1] - 12'd3);
	end
end

endmodule