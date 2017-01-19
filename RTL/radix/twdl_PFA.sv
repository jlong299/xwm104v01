module twdl_PFA #(parameter
	wDataInOut = 30
	)
 (
	input clk,    
	input rst_n,  

	input [2:0]  factor;
	input [7:0]  tw_ROM_addr_step;
	input [7:0]  tw_ROM_exp_ceil;
	input [7:0]  tw_ROM_exp_time;

	input  in_val;
	input  [0:4][wDataInOut-1:0]  din_real;
	input  [0:4][wDataInOut-1:0]  din_imag;

	output  out_val;
	output [0:4][wDataInOut-1:0]  dout_real;
	output [0:4][wDataInOut-1:0]  dout_imag
);



endmodule