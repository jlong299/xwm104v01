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
output reg [17:0] source_real;
output reg [17:0] source_imag;
output reg [11:0] dftpts_out;

reg rst_n_sync, rst_n_r0, rst_n_r1;
always@(posedge clk)
begin
	rst_n_sync <= rst_n_r1;
	rst_n_r1 <= rst_n_r0;
	rst_n_r0 <= rst_n;
end

dft_st_if sink_st(clk);
dft_st_if sink_st_0(clk);
dft_st_if sink_st_1(clk);
dft_st_if source_st(clk);

assign sink_st.rst_n = rst_n_sync;
assign sink_st.valid = sink_valid;
assign sink_st.sop = sink_sop;
assign sink_st.eop = sink_eop;
assign sink_st.d_real = sink_real;
assign sink_st.d_imag = sink_imag;
assign sink_st.dftpts = dftpts_in;
assign sink_st.inverse = inverse;
assign sink_ready = sink_st.ready;

assign source_valid = source_st.valid;
assign source_sop = source_st.sop;
assign source_eop = source_st.eop;
assign source_real = source_st.d_real;
assign source_imag = source_st.d_imag;
assign dftpts_out = source_st.dftpts;
assign source_st.ready = source_ready;

localparam logic sw_in = 1'b0;
localparam logic sw_out = 1'b1;

switch_in1out2
switch_in (
	.in_data ( sink_st ),
	.sw (sw_in),

	.out_data_0 ( sink_st_0 ),
	.out_data_1 ( sink_st_1 )
	);

switch_in2out1
switch_out (
	.in_data_0 ( source_st_0 ),
	.in_data_1 ( source_st_1 ),
	.sw (sw_out),

	.out_data ( source_st )
	);


mem_top_0
mem_0 (
	.in_data ( sink_st_0 ),


	.out_data ( source_st_0 )
	)



endmodule