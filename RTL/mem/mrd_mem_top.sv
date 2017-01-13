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

logic [3:0] rd_ongoing_r;

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

logic [0:6]  wren_sink;

always@(*)
begin
	case (bank_index_sink)
	3'd0:  wren_sink = 7'b1000000;
	3'd1:  wren_sink = 7'b0100000;
	3'd2:  wren_sink = 7'b0010000;
	3'd3:  wren_sink = 7'b0001000;
	3'd4:  wren_sink = 7'b0000100;
	3'd5:  wren_sink = 7'b0000010;
	3'd6:  wren_sink = 7'b0000001;
	default: wren_sink = 7'd0;
	endcase
end

logic [0:6] wren, rden;
logic [0:6] rden_rd;
logic [0:6][7:0]  rdaddr, wraddr;
logic [0:6][7:0]  rdaddr_rd;
logic [0:4][11:0]  addrs_butterfly;
logic [0:4][7:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr;
logic [0:6][17:0] d_real_rd, d_imag_rd;


always@(posedge clk)
begin
	if (!rst_n) 
	begin
		rden_rd <= 0;
		rdaddr_rd <= 0;
		bank_index_rd_r <= 0;
		bank_index_rd_rr <= 0;
		bank_addr_rd_r <= 0;
		bank_addr_rd_rr <= 0;
	end
	else 
	begin
		bank_index_rd_r <= bank_index_rd;
		bank_index_rd_rr <= bank_index_rd_r;
		bank_addr_rd_r <= bank_addr_rd;
		bank_addr_rd_rr <= bank_addr_rd_r;

		if (bank_index_rd[0]==3'd0 || bank_index_rd[1]==3'd0 ||
			bank_index_rd[2]==3'd0 || bank_index_rd[3]==3'd0 ||
			bank_index_rd[4]==3'd0 )
				rden_rd[0] <= 1'b1;
		else rden_rd[0] <= 1'b0;

		if (bank_index_rd[0]==3'd1 || bank_index_rd[1]==3'd1 ||
			bank_index_rd[2]==3'd1 || bank_index_rd[3]==3'd1 ||
			bank_index_rd[4]==3'd1 )
				rden_rd[1] <= 1'b1;
		else rden_rd[1] <= 1'b0;

		if (bank_index_rd[0]==3'd2 || bank_index_rd[1]==3'd2 ||
			bank_index_rd[2]==3'd2 || bank_index_rd[3]==3'd2 ||
			bank_index_rd[4]==3'd2 )
				rden_rd[2] <= 1'b1;
		else rden_rd[2] <= 1'b0;

		if (bank_index_rd[0]==3'd3 || bank_index_rd[1]==3'd3 ||
			bank_index_rd[2]==3'd3 || bank_index_rd[3]==3'd3 ||
			bank_index_rd[4]==3'd3 )
				rden_rd[3] <= 1'b1;
		else rden_rd[3] <= 1'b0;

		if (bank_index_rd[0]==3'd4 || bank_index_rd[1]==3'd4 ||
			bank_index_rd[2]==3'd4 || bank_index_rd[3]==3'd4 ||
			bank_index_rd[4]==3'd4 )
				rden_rd[4] <= 1'b1;
		else rden_rd[4] <= 1'b0;

		if (bank_index_rd[0]==3'd5 || bank_index_rd[1]==3'd5 ||
			bank_index_rd[2]==3'd5 || bank_index_rd[3]==3'd5 ||
			bank_index_rd[4]==3'd5 )
				rden_rd[5] <= 1'b1;
		else rden_rd[5] <= 1'b0;

		if (bank_index_rd[0]==3'd6 || bank_index_rd[1]==3'd6 ||
			bank_index_rd[2]==3'd6 || bank_index_rd[3]==3'd6 ||
			bank_index_rd[4]==3'd6 )
				rden_rd[6] <= 1'b1;
		else rden_rd[6] <= 1'b0;

		if (bank_index_rd[0]==3'd0) rdaddr_rd[0] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd0) rdaddr_rd[0] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd0) rdaddr_rd[0] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd0) rdaddr_rd[0] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd0) rdaddr_rd[0] <= bank_addr_rd[4]; 

		if (bank_index_rd[0]==3'd1) rdaddr_rd[1] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd1) rdaddr_rd[1] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd1) rdaddr_rd[1] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd1) rdaddr_rd[1] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd1) rdaddr_rd[1] <= bank_addr_rd[4]; 
		
		if (bank_index_rd[0]==3'd2) rdaddr_rd[2] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd2) rdaddr_rd[2] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd2) rdaddr_rd[2] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd2) rdaddr_rd[2] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd2) rdaddr_rd[2] <= bank_addr_rd[4]; 
		
		if (bank_index_rd[0]==3'd3) rdaddr_rd[3] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd3) rdaddr_rd[3] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd3) rdaddr_rd[3] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd3) rdaddr_rd[3] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd3) rdaddr_rd[3] <= bank_addr_rd[4]; 
		
		if (bank_index_rd[0]==3'd4) rdaddr_rd[4] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd4) rdaddr_rd[4] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd4) rdaddr_rd[4] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd4) rdaddr_rd[4] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd4) rdaddr_rd[4] <= bank_addr_rd[4]; 
		
		if (bank_index_rd[0]==3'd5) rdaddr_rd[5] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd5) rdaddr_rd[5] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd5) rdaddr_rd[5] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd5) rdaddr_rd[5] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd5) rdaddr_rd[5] <= bank_addr_rd[4]; 
		
		if (bank_index_rd[0]==3'd6) rdaddr_rd[6] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==3'd6) rdaddr_rd[6] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==3'd6) rdaddr_rd[6] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==3'd6) rdaddr_rd[6] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==3'd6) rdaddr_rd[6] <= bank_addr_rd[4];

		

	end
end


	//rden <= stat_to_ctrl.rd_ongoing;

genvar i;
generate
	for (i=0; i<5; i++) begin : addr_banks
	divider_7 divider_7_inst (
		.dividend 	(addrs_butterfly[i]),  

		.quotient 	(bank_addr_rd[i]),
		.remainder 	(bank_index_rd[i])
	);
	end
endgenerate

generate
	for (i=0; i<5; i++) begin : rd_out
	always@(*)
	begin
		case (bank_index_rd_rr[i])
	    3'd0: begin
			out_rdx2345_data.d_real[i] = d_real_rd[0]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[0]; 
		end
		3'd1: begin
			out_rdx2345_data.d_real[i] = d_real_rd[1]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[1]; 
		end
		3'd2: begin
			out_rdx2345_data.d_real[i] = d_real_rd[2]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[2]; 
		end
		3'd3: begin
			out_rdx2345_data.d_real[i] = d_real_rd[3]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[3]; 
		end
		3'd4: begin
			out_rdx2345_data.d_real[i] = d_real_rd[4]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[4]; 
		end
		3'd5: begin
			out_rdx2345_data.d_real[i] = d_real_rd[5]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[5]; 
		end
		3'd6: begin
			out_rdx2345_data.d_real[i] = d_real_rd[6]; 
			out_rdx2345_data.d_imag[i] = d_imag_rd[6]; 
		end
		endcase
	end
	end
endgenerate

assign out_rdx2345_data.valid = rd_ongoing_r[2];
assign out_rdx2345_data.bank_index = bank_index_rd_rr;
assign out_rdx2345_data.bank_addr = bank_addr_rd_rr;

generate
	for (i=0; i<7; i++) begin : RAM_banks
	mrd_RAM_fake RAM_fake(
		.clk (clk),
		.wren (wren_sink[i] & input_valid_r[in_dly] & (ctrl.state==2'b00)),
		.wraddr (bank_addr_sink[7:0]),
		.din_real ({ {12{input_real_r[in_dly][17]}}, 
			          input_real_r[in_dly] }),
		.din_imag ({ {12{input_imag_r[in_dly][17]}}, 
			          input_imag_r[in_dly] }),

		.rden (rden_rd[i] & rd_ongoing_r[1]),
		.rdaddr (rdaddr_rd[i]),
		.dout_real (d_real_rd[i]),
		.dout_imag (d_imag_rd[i])
		);
	end
endgenerate

logic [1:0] ctrl_state_r;
logic [11:0] cnt_rd_ongoing, cnt_rd_stop;
always@(*)
begin
	case (ctrl.current_stage)
	3'd0 :  cnt_rd_stop = dftpts/(ctrl.Nf[0]);
	3'd1 :  cnt_rd_stop = dftpts/(ctrl.Nf[1]);
	3'd2 :  cnt_rd_stop = dftpts/(ctrl.Nf[2]);
	3'd3 :  cnt_rd_stop = dftpts/(ctrl.Nf[3]);
	3'd4 :  cnt_rd_stop = dftpts/(ctrl.Nf[4]);
	3'd5 :  cnt_rd_stop = dftpts/(ctrl.Nf[5]);
	endcase
end

always@(posedge clk)
begin
	if (!rst_n)
	begin
		ctrl_state_r <= 0;
		stat_to_ctrl.sink_ongoing <= 0;
		stat_to_ctrl.rd_ongoing <= 0;
		stat_to_ctrl.wr_ongoing <= 0;

		cnt_rd_ongoing <= 0;
		rd_ongoing_r <= 0;
	end
	else
	begin
		ctrl_state_r <= ctrl.state;

		if (in_data.sop)  stat_to_ctrl.sink_ongoing <= 1'b1;
		else if (input_valid_r[in_dly:in_dly-1]==2'b10)
			stat_to_ctrl.sink_ongoing <= 1'b0;
		else
			stat_to_ctrl.sink_ongoing <= stat_to_ctrl.sink_ongoing;

		if (ctrl.state==2'b01 && ctrl_state_r!=2'b01)
			cnt_rd_ongoing <= 12'd1;
		else if (cnt_rd_ongoing != 12'd0)
			cnt_rd_ongoing <= (cnt_rd_ongoing==cnt_rd_stop) ? 
		                       12'd0 : cnt_rd_ongoing + 12'd1;
		else
			cnt_rd_ongoing <= 0;

		stat_to_ctrl.rd_ongoing <= (cnt_rd_ongoing != 12'd0);

		rd_ongoing_r[0] <= stat_to_ctrl.rd_ongoing;
		rd_ongoing_r[3:1] <= rd_ongoing_r[2:0];
	end
end
assign stat_to_ctrl.source_ongoing = 1'b0;

CTA_addr_trans #(
		.wDataInOut (12)
	)
CTA_addr_trans_inst	(
	.clk  (clk),    
	.rst_n  (rst_n),  
	.clr_n  (stat_to_ctrl.rd_ongoing),
	.Nf  (ctrl.Nf),
	.current_stage  (ctrl.current_stage),

	.addrs_butterfly  (addrs_butterfly)
	);






endmodule