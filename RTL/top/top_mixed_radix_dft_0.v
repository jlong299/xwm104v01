
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
input sink_ready;
input sink_sop;
input sink_eop;
input [17:0] sink_real;
input [17:0] sink_imag;
input [11:0] dftpts_in;
input reverse;

output reg source_valid;
output reg source_ready;
output reg source_sop;
output reg source_eop;
output reg [17:0] source_real;
output reg [17:0] source_imag;
output reg [11:0] dftpts_out;

reg sw_in, sw_out;
reg [17:0] sink_real_1, sink_real_2, sink_imag_1, sink_imag_2;

switch_in1out2 #(
	.wDataInOut (36)
	)
switch_in (
	.in_data ( {sink_real, sink_imag} ),
	.sw (sw_in),

	.out_data_1 ( {sink_real_1, sink_imag_1} ),
	.out_data_2 ( {sink_real_2, sink_imag_2} )
	);


switch_in2out1 #(
	.wDataInOut (36)
	)
switch_out (
	.in_data_1 ( {source_real_1, source_imag_1} ),
	.in_data_2 ( {source_real_2, source_imag_2} ),
	.sw (sw_out),

	.out_data ( {source_real, source_imag} )
	);





endmodule