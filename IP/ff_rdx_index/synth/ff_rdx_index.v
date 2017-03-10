// ff_rdx_index.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module ff_rdx_index (
		input  wire [54:0] data,  //  fifo_input.datain
		input  wire        wrreq, //            .wrreq
		input  wire        rdreq, //            .rdreq
		input  wire        clock, //            .clk
		input  wire        sclr,  //            .sclr
		output wire [54:0] q      // fifo_output.dataout
	);

	ff_rdx_index_fifo_151_i22ugba fifo_0 (
		.data  (data),  //  fifo_input.datain
		.wrreq (wrreq), //            .wrreq
		.rdreq (rdreq), //            .rdreq
		.clock (clock), //            .clk
		.sclr  (sclr),  //            .sclr
		.q     (q)      // fifo_output.dataout
	);

endmodule