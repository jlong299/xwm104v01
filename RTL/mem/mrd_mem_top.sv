//-----------------------------------------------------------------
// Module Name:        	mrd_mem_top.sv
// Project:             Mixed Radix DFT
// Description:         Memory top module 
// Author:				Long Jiang
//------------------------------------------------------------------
//  Version 0.1   2017-01-11
//  Description :   
//------------------------------------------------------------------
module mrd_mem_top (
	input clk,  
	input rst_n,

	mrd_st_if.ST_IN  in_data,
	mrd_rdx2345_if  in_rdx2345_data,

	mrd_ctrl_if  ctrl,

	mrd_st_if.ST_OUT  out_data,
	mrd_rdx2345_if  out_rdx2345_data,
	mrd_stat_if  stat_to_ctrl
);

logic [11:0]  dftpts, N_PFA_in;
logic  clr_n_PFA_addr;
logic  [9:0]  n1_PFA_in, n2_PFA_in, n3_PFA_in;

localparam  in_dly = 1;
logic [in_dly:0]  input_valid_r;
logic [in_dly:0][17:0]  input_real_r;
logic [in_dly:0][17:0]  input_imag_r;

assign stat_to_ctrl.sink_sop = in_data.sop;
assign stat_to_ctrl.dftpts = in_data.dftpts;

always@(posedge clk)
begin
	if (!rst_n)
	begin
		dftpts <= 0;
		clr_n_PFA_addr <= 0;
	end
	else
	begin
		dftpts <= (ctrl.state==2'b00 && in_data.sop)? in_data.dftpts : dftpts;

		if (in_data.sop)
			clr_n_PFA_addr <= 1'b1;
		else if (in_data.eop)
			clr_n_PFA_addr <= 1'b0;
		else
			clr_n_PFA_addr <= clr_n_PFA_addr;

	end
end

PFA_addr_trans #(
		.wDataInOut (10)
	)
PFA_addr_trans_inst
	(
	.clk  (clk),    
	.rst_n  (rst_n), 

	.clr_n (clr_n_PFA_addr),

	.Nf1 (ctrl.Nf_PFA[0]),  //N1
	.Nf2 (ctrl.Nf_PFA[1]),  //N2
	.Nf3 (ctrl.Nf_PFA[2]),  //N3
	.q_p (ctrl.q_p),  //q'
	.r_p (ctrl.r_p),  //r'

	.n1 (n1_PFA_in),
	.n2 (n2_PFA_in),
	.n3 (n3_PFA_in)
);

always@(posedge clk)
begin
	N_PFA_in <= n1_PFA_in*ctrl.Nf_PFA[1]*ctrl.Nf_PFA[2]
	        + n2_PFA_in*ctrl.Nf_PFA[2] + n3_PFA_in;
	input_valid_r[in_dly:0] <= {input_valid_r[in_dly-1:0],
	                              in_data.valid} ;
	input_real_r[in_dly:0] <= {input_real_r[in_dly-1:0],in_data.d_real};
	input_imag_r[in_dly:0] <= {input_imag_r[in_dly-1:0],in_data.d_imag};
end

logic [11:0]  bank_addr_sink;
logic [2:0] bank_index_sink;
divider_7 divider_7_inst (
	.dividend 	(N_PFA_in),  

	.quotient 	(bank_addr_sink),
	.remainder 	(bank_index_sink)
);

logic [6:0]  wren_sink;

always@(*)
begin
	case (bank_index_sink)
	3'd0:  wren_sink = 7'b0000001;
	3'd1:  wren_sink = 7'b0000010;
	3'd2:  wren_sink = 7'b0000100;
	3'd3:  wren_sink = 7'b0001000;
	3'd4:  wren_sink = 7'b0010000;
	3'd5:  wren_sink = 7'b0100000;
	3'd6:  wren_sink = 7'b1000000;
	default: wren_sink = 7'd0;
	endcase
end

genvar i;
generate
	for (i=0; i<7; i++) begin : RAM_banks
	mrd_RAM_fake
	RAM_fake(
		.clk (clk),
		.wren (wren_sink[i] & input_valid_r[in_dly] & (ctrl.state==2'b00)),
		.wraddr (bank_addr_sink[7:0]),
		.din_real ({ {12{input_real_r[in_dly][17]}}, 
			          input_real_r[in_dly] }),
		.din_imag ({ {12{input_imag_r[in_dly][17]}}, 
			          input_imag_r[in_dly] }),

		.rden (1'b0),
		.rdaddr (8'd0),
		.dout_real (),
		.dout_imag ()
		);
	end
endgenerate

always@(posedge clk)
begin
	if (!rst_n)
	begin
		stat_to_ctrl.sink_ongoing <= 0;
	end
	else
	begin
		if (in_data.sop)  stat_to_ctrl.sink_ongoing <= 1'b1;
		else if (input_valid_r[in_dly:in_dly-1]==2'b10)
			stat_to_ctrl.sink_ongoing <= 1'b0;
		else
			stat_to_ctrl.sink_ongoing <= stat_to_ctrl.sink_ongoing;
	end
end
assign stat_to_ctrl.source_ongoing = 1'b0;






endmodule