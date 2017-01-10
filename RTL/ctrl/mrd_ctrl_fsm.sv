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
	output reg sw_0to1
	
);

logic [1:0]  fsm;

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
			if ( !stat_from_mem0.sink_ongoing & !stat_from_mem1.sink_ongoing
			     & !stat_from_mem0.source_ongoing 
			     & !stat_from_mem1.source_ongoing )				
				fsm <= 2'd2;
			else 
				fsm <= 2'd1;
		end
		// s2, DFT computation
		2'd2:
		begin
			fsm <= (fsm_s2_end) ? 2'd3 : 2'd2;
		end
		// s3, source data
		2'd3:
		begin
			fsm <= 2'd0;
		end
		endcase
	end
end





endmodule