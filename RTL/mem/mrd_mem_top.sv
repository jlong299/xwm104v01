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
logic  n1_PFA_in, n2_PFA_in, n3_PFA_in;

localparam  input_dly = 4;
logic [0:input_dly]  input_valid_r;
logic [0:input_dly][17:0]  input_real_r;
logic [0:input_dly][17:0]  input_imag_r;

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
		dftpts <= (ctrl.state==2'b00 & in_data.sop)? in_data.dftpts : dftpts;

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
	input_valid_r[0] <= in_data.valid;
	input_real_r[0] <= in_data.d_real;
	input_imag_r[0] <= in_data.d_imag;

endmodule