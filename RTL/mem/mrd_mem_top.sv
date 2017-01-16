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

logic rden, wren;
logic [0:6] rden_rd;
logic [0:6][7:0]  rdaddr, wraddr;
logic [0:6][7:0]  rdaddr_rd;
logic [0:4][11:0]  addrs_butterfly;
logic [0:4][7:0]  bank_addr_rd, bank_addr_rd_r, bank_addr_rd_rr;
logic [0:4][2:0]  bank_index_rd, bank_index_rd_r, bank_index_rd_rr, 
                  div7_rmdr_rd;
logic [0:6][29:0] d_real_rd, d_imag_rd;
logic [0:6][29:0] din_real_RAM, din_imag_RAM;

logic [0:6][29:0] wrdin_real, wrdin_imag;
logic [0:6][7:0]  wraddr_RAM, wraddr_wr;
logic [0:6]  wren_wr;

//------------------------------------------------
//------------------ 1st stage: Sink -------------
//------------------------------------------------
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

//------------------------------------------------
//------------------ 2nd stage: Read -------------
//------------------------------------------------


always@(posedge clk)
begin
	if (!rst_n) 
	begin
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
	end
end

genvar  k;
generate
for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : rden_addr_index
always@(posedge clk)
begin
	if (!rst_n) 
	begin
		rden_rd[k] <= 0;
		rdaddr_rd[k] <= 0;
	end
	else 
	begin
		if (bank_index_rd[0]== k || bank_index_rd[1]== k ||
			bank_index_rd[2]== k || bank_index_rd[3]== k ||
			bank_index_rd[4]== k )
				rden_rd[k] <= 1'b1 & rd_ongoing_r[0];
		else rden_rd[k] <= 1'b0;

		if (bank_index_rd[0]==k) rdaddr_rd[k] <= bank_addr_rd[0]; 
		else if (bank_index_rd[1]==k) rdaddr_rd[k] <= bank_addr_rd[1]; 
		else if (bank_index_rd[2]==k) rdaddr_rd[k] <= bank_addr_rd[2]; 
		else if (bank_index_rd[3]==k) rdaddr_rd[k] <= bank_addr_rd[3]; 
		else if (bank_index_rd[4]==k) rdaddr_rd[k] <= bank_addr_rd[4];
	end
end
end
endgenerate

genvar i;
generate
for (i=0; i<=6; i++)  begin : din_switch
always@(*)
begin
if (ctrl.state==2'b00) 
begin
	din_real_RAM[i] = { {12{input_real_r[in_dly][17]}},input_real_r[in_dly] };
	din_imag_RAM[i] = { {12{input_imag_r[in_dly][17]}},input_imag_r[in_dly] };
end
else 
begin
	din_real_RAM[i] = wrdin_real[i];
	din_imag_RAM[i] = wrdin_imag[i];
end		
end	 
end
endgenerate 


generate
	for (k=3'd0; k < 3'd5; k=k+3'd1) begin : addr_banks
	divider_7 divider_7_inst (
		.dividend 	(addrs_butterfly[k]),  

		.quotient 	(bank_addr_rd[k]),
		.remainder 	(div7_rmdr_rd[k])
	);
	// index 3'd7 means the index is not valid
	assign bank_index_rd[k] = (k >= ctrl.Nf[ctrl.current_stage]) ?
	                          3'd7 : div7_rmdr_rd[k];
	end
endgenerate

generate
	for (i=0; i<5; i++) begin : rd_out
	always@(*)
	begin
		out_rdx2345_data.d_real[i] = d_real_rd[(bank_index_rd_rr[i])]; 
		out_rdx2345_data.d_imag[i] = d_imag_rd[(bank_index_rd_rr[i])]; 
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
		.wraddr (wraddr_RAM[7:0]),
		.din_real (din_real_RAM[i]),
		.din_imag (din_imag_RAM[i]),

		.rden (rden_rd[i]),
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
	cnt_rd_stop = dftpts/(ctrl.Nf[ctrl.current_stage]);
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

		stat_to_ctrl.wr_ongoing <= (ctrl.state==2'b10) ? 
		                           in_rdx2345_data.valid : 1'b0;
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


//------------------------------------------------
//------------------ 3rd stage: Write ------------
//------------------------------------------------

generate
for (i=0; i<7; i++) begin : wraddr_RAM_gen
assign wraddr_RAM[i]= (ctrl.stage==2'b00)? bank_addr_sink[7:0] : wraddr_wr[i];
end
endgenerate

generate
for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : wren_wr_gen
always@(posedge clk)
begin
	if (!rst_n)
	begin
		wren_wr[k] <= 0;
		wraddr_wr[k] <= 0;
	end
	else
	begin
		if (in_rdx2345_data.bank_index[0]== k || 
			in_rdx2345_data.bank_index[1]== k ||
			in_rdx2345_data.bank_index[2]== k || 
			in_rdx2345_data.bank_index[3]== k ||
			in_rdx2345_data.bank_index[4]== k )
				wren_wr[k] <= 1'b1 & in_rdx2345_data.valid;
		else wren_wr[k] <= 1'b0;

		if (in_rdx2345_data.bank_index[0]==k) 
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[0]; 
		else if (in_rdx2345_data.bank_index[1]==k) 
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[1]; 
		else if (in_rdx2345_data.bank_index[2]==k) 
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[2]; 
		else if (in_rdx2345_data.bank_index[3]==k) 
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[3]; 
		else if (in_rdx2345_data.bank_index[4]==k) 
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[4];
	end
end
end
endgenerate


endmodule