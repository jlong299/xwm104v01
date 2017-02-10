// "mrd" refer to "mixed radix dft"
module top_mixed_radix_dft_0 (
	clk,    // Clock
	rst_n,  // Asynchronous reset active low
	
	sink_valid,
	sink_ready,
	sink_sop,
	sink_eop,
	sink_real,
	sink_imag,
	dftpts_in,
	inverse,

	source_valid,
	source_ready,
	source_sop,
	source_eop,
	source_real,
	source_imag,
	dftpts_out
);

input clk;
input rst_n;
input sink_valid;
output sink_ready;
input sink_sop;
input sink_eop;
input [17:0] sink_real;
input [17:0] sink_imag;
input [11:0] dftpts_in;
input inverse;

output reg source_valid;
input  source_ready;
output reg source_sop;
output reg source_eop;
output reg [29:0] source_real;
output reg [29:0] source_imag;
output reg [11:0] dftpts_out;

reg rst_n_sync, rst_n_r0, rst_n_r1;
always@(posedge clk)
begin
	rst_n_sync <= rst_n_r1;
	rst_n_r1 <= rst_n_r0;
	rst_n_r0 <= rst_n;
end

mrd_st_if sink_st();
mrd_st_if sink_st_0();
mrd_st_if sink_st_1();
mrd_st_if source_st();
mrd_st_if source_st_0();
mrd_st_if source_st_1();

assign sink_st.valid = sink_valid;
assign sink_st.sop = sink_sop;
assign sink_st.eop = sink_eop;
assign sink_st.din_real = sink_real;
assign sink_st.din_imag = sink_imag;
assign sink_st.dftpts = dftpts_in;
assign sink_st.inverse = inverse;
assign sink_ready = sink_st.ready;

assign source_valid = source_st.valid;
assign source_sop = source_st.sop;
assign source_eop = source_st.eop;
assign source_real = source_st.dout_real;
assign source_imag = source_st.dout_imag;
assign dftpts_out = source_st.dftpts;
assign source_st.ready = source_ready;

mrd_rdx2345_if rdx2345_to_mem0();
mrd_rdx2345_if mem0_to_rdx2345();
mrd_rdx2345_if rdx2345_to_mem1();
mrd_rdx2345_if mem1_to_rdx2345();
mrd_rdx2345_if rdx2345_to_mem();
mrd_rdx2345_if mem_to_rdx2345();

mrd_ctrl_if ctrl_to_mem0();
mrd_ctrl_if ctrl_to_mem1();

mrd_stat_if stat_from_mem0();
mrd_stat_if stat_from_mem1();

logic goto_next_fsm_0, goto_next_fsm_1;
logic sw_in, sw_out, sw_1to0;

mrd_switch_in1out2
switch_in (
	.sw (sw_in),
	.in_data ( sink_st ),

	.out_data_0 ( sink_st_0 ),
	.out_data_1 ( sink_st_1 )
	);

mrd_switch_in2out1
switch_out (
	.sw (sw_out),
	.in_data_0 ( source_st_0 ),
	.in_data_1 ( source_st_1 ),

	.out_data ( source_st )
	);


mrd_mem_top_v2
mem0 (
	.clk (clk),
	.rst_n (rst_n_sync),
	.this_mem_index (1'b0),

	.in_data ( sink_st_0 ),
	.in_rdx2345_data ( rdx2345_to_mem0 ),
	// .fsm (fsm_to_mem),
	.ctrl (ctrl_to_mem0),
	.sw_rdx2345 (sw_rdx2345),

	.out_data ( source_st_0 ),
	.out_rdx2345_data ( mem0_to_rdx2345 ),
	.stat_to_ctrl (stat_from_mem0)
	);

mrd_mem_top_v2
mem1 (
	.clk (clk),
	.rst_n (rst_n_sync),
	.this_mem_index (1'b1),

	.in_data ( sink_st_1 ),
	.in_rdx2345_data ( rdx2345_to_mem1 ),
	// .fsm (fsm_to_mem),
	.ctrl (ctrl_to_mem1),
	.sw_rdx2345 (sw_rdx2345),

	.out_data ( source_st_1 ),
	.out_rdx2345_data ( mem1_to_rdx2345 ),
	.stat_to_ctrl (stat_from_mem1)
	);


mrd_switch_rdx2345
switch_rdx2345(
	.sw (sw_rdx2345),
	.from_mem0  (mem0_to_rdx2345),
	.to_mem0  (rdx2345_to_mem0),

	.from_mem1  (mem1_to_rdx2345),
	.to_mem1  (rdx2345_to_mem1),

	.from_rdx2345 (rdx2345_to_mem),
	.to_rdx2345 (mem_to_rdx2345)
	);

//Radix 2/3/4/5 core  &  twiddle ROMs
mrd_rdx2345_twdl 
rdx2345_twdl(
	.clk (clk),
	.rst_n (rst_n_sync), 

	.from_mem (mem_to_rdx2345),
	.to_mem (rdx2345_to_mem)
	);

// Control & FSM
mrd_ctrl_fsm 
ctrl_fsm(
	.clk (clk),
	.rst_n (rst_n),

	.stat_from_mem0 (stat_from_mem0),
	.stat_from_mem1 (stat_from_mem1),

	//.fsm (fsm_to_mem),
	.ctrl_to_mem0 (ctrl_to_mem0),
	.ctrl_to_mem1 (ctrl_to_mem1),

	.sw_in (sw_in),
	.sw_out (sw_out),
	.sw_rdx2345 (sw_rdx2345)

	);


endmodule