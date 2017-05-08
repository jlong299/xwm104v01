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
	size,
	inverse,

	source_valid,
	source_sop,
	source_eop,
	source_real,
	source_imag,
	source_exp
	// dftpts_out
);

input clk;
input rst_n;
input sink_valid;
output sink_ready;
input sink_sop;
input sink_eop;
input [17:0] sink_real;
input [17:0] sink_imag;
// input [11:0] dftpts_in;
input [5:0] size;
input inverse;

output reg source_valid;
// input  source_ready;
output reg source_sop;
output reg source_eop;
output reg [17:0] source_real;
output reg [17:0] source_imag;
output reg [3:0] source_exp;
// output reg [11:0] dftpts_out;

reg rst_n_sync, rst_n_r0, rst_n_r1, rst_n_r2, source_eop_r;
always@(posedge clk)
begin
	rst_n_sync <= rst_n_r2 & (~source_eop_r);
	rst_n_r2 <= rst_n_r1;
	rst_n_r1 <= rst_n_r0;
	rst_n_r0 <= rst_n;
	source_eop_r <= source_eop;
end

mrd_st_if sink_st();
mrd_st_if source_st();

assign sink_st.valid = sink_valid;
assign sink_st.sop = sink_sop;
assign sink_st.eop = sink_eop;
assign sink_st.din_real = sink_real;
assign sink_st.din_imag = sink_imag;
// assign sink_st.dftpts = dftpts_in;
assign sink_st.size = size;
// assign sink_st.inverse = inverse;
// assign sink_ready = sink_st.ready;

assign source_valid = source_st.valid;
assign source_sop = source_st.sop;
assign source_eop = source_st.eop;
assign source_real = source_st.dout_real;
assign source_imag = source_st.dout_imag;
assign source_exp = source_st.exp;
// assign dftpts_out = source_st.dftpts;
// assign source_st.ready = source_ready;

mrd_rdx2345_if rdx2345_to_mem();
mrd_rdx2345_if mem_to_rdx2345();

mrd_ctrl_if ctrl_to_mem();

logic [2:0] fsm;

mrd_mem_top_v2
mem0 (
	.clk (clk),
	.rst_n (rst_n_sync),

	.in_data ( sink_st ),
	.in_rdx2345_data ( rdx2345_to_mem ),

	.ctrl (ctrl_to_mem),

	.out_data ( source_st ),
	.out_rdx2345_data ( mem_to_rdx2345 ),
	.fsm (fsm),
	.sink_ready (sink_ready)
	);

//Radix 2/3/4/5 core  &  twiddle CORDIC
mrd_rdx2345_twdl 
rdx2345_twdl(
	.clk (clk),
	.rst_n (rst_n_sync), 

	.sink_sop (sink_sop),
	.inverse (inverse),
	.source_eop (source_eop),
	.from_mem (mem_to_rdx2345),
	.to_mem (rdx2345_to_mem)
	);

// Control & FSM
mrd_ctrl_fsm 
ctrl_fsm(
	.clk (clk),
	.rst_n (rst_n_sync),

	.fsm (fsm),
	.sink_sop (sink_sop),
	// .dftpts (dftpts_in),
	.size (size),

	.ctrl_to_mem (ctrl_to_mem)
	);


endmodule