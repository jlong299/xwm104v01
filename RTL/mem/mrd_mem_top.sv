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
logic  clr_n_PFA_addr, clr_n_PFA_addr_o;
logic  [9:0]  n1_PFA_in, n2_PFA_in, n3_PFA_in;
logic  [9:0]  k1_PFA_out, k2_PFA_out, k3_PFA_out;

localparam  in_dly = 1;
logic [in_dly:0]  input_valid_r;
logic [in_dly:0][17:0]  input_real_r;
logic [in_dly:0][17:0]  input_imag_r;

logic [3:0] rd_ongoing_r;

assign stat_to_ctrl.sink_sop = in_data.sop;
assign stat_to_ctrl.dftpts = in_data.dftpts;

logic [11:0]  bank_addr_sink;
logic [2:0] bank_index_sink;
logic [0:6]  wren_sink;


logic [0:6] rden, wren;
logic [0:6] rden_rd;
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

logic [1:0] ctrl_state_r;
logic [11:0] cnt_rd_ongoing, cnt_rd_stop, cnt_source_ongoing;

logic [11:0] N_PFA_out;
logic [0:6]  rden_source;
logic [11:0]  bank_addr_source;
logic [2:0] bank_index_source, bank_index_source_r;
logic [0:6][29:0] dout_real_RAM, dout_imag_RAM;
logic [0:6][7:0]  rdaddr_RAM;


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
		if (ctrl.state==2'b00 && in_data.sop)
			dftpts <= in_data.dftpts;
		else if (ctrl.state==2'b10 && ctrl_state_r==2'b00)
			dftpts <= ctrl.dftpts;
		else
			dftpts <= dftpts;

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


divider_7 divider_7_inst0 (
	.dividend 	(N_PFA_in),  

	.quotient 	(bank_addr_sink),
	.remainder 	(bank_index_sink)
);

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
		else  rdaddr_rd[k] <= 0;
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
	divider_7 divider_7_inst1 (
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

always@(*)
begin
	if (ctrl.state==2'b01 || ctrl.state==2'b10 )
	begin
		case (ctrl.current_stage)
		3'd0 :
		begin
			out_rdx2345_data.factor <= 3'd4;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd16;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd4;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd75;
		end
		3'd1 :
		begin
			out_rdx2345_data.factor <= 3'd4;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd0;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd1;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd1;
		end
		3'd2 :
		begin
			out_rdx2345_data.factor <= 3'd5;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd1;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd5;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd3;
		end
		3'd3 :
		begin
			out_rdx2345_data.factor <= 3'd5;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd0;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd1;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd1;
		end
		3'd4 :
		begin
			out_rdx2345_data.factor <= 3'd3;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd0;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd1;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd1;
		end
		3'd5 :
		begin
			out_rdx2345_data.factor <= 3'd1;
			out_rdx2345_data.tw_ROM_addr_step <= 8'd0;
			out_rdx2345_data.tw_ROM_exp_ceil <= 8'd1;
			out_rdx2345_data.tw_ROM_exp_time <= 8'd1;
		end
		endcase
	end
	else
	begin
		out_rdx2345_data.factor <= 3'd1;
		out_rdx2345_data.tw_ROM_addr_step <= 8'd0;
		out_rdx2345_data.tw_ROM_exp_ceil <= 8'd0;
		out_rdx2345_data.tw_ROM_exp_time <= 8'd0;
	end
end


generate
	for (i=0; i<7; i++) begin : RAM_banks
	mrd_RAM_fake RAM_fake(
		.clk (clk),
		.wren (wren[i]),
		.wraddr (wraddr_RAM[i]),
		.din_real (din_real_RAM[i]),
		.din_imag (din_imag_RAM[i]),

		.rden (rden[i]),
		.rdaddr (rdaddr_RAM[i]),
		.dout_real (dout_real_RAM[i]),
		.dout_imag (dout_imag_RAM[i])
		);
	end
endgenerate

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
		stat_to_ctrl.source_ongoing <= 0;

		//source_ongoing_r <= 0;

		cnt_rd_ongoing <= 0;
		rd_ongoing_r <= 0;
		cnt_source_ongoing <= 0;
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

		if (ctrl.state==2'b11 && ctrl_state_r!=2'b11)                          
			cnt_source_ongoing <= 12'd1;
		else if (cnt_source_ongoing != 12'd0)
			cnt_source_ongoing <= (cnt_source_ongoing==dftpts+'d2) ?
		                           12'd0 : cnt_source_ongoing + 12'd1;
		else
			cnt_source_ongoing <= 0;

		stat_to_ctrl.source_ongoing <= (cnt_source_ongoing != 12'd0);
	end
end

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
assign wraddr_RAM[i]= (ctrl.state==2'b00)? bank_addr_sink[7:0] 
                      : wraddr_wr[i];
assign wren[i] = (ctrl.state==2'b00)? (wren_sink[i] & input_valid_r[in_dly])
                  : wren_wr[i] ;
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
		wrdin_real[k] <= 0;
		wrdin_imag[k] <= 0;
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
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[0];
			wrdin_real[k] <= in_rdx2345_data.d_real[0]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[0]; 
		end
		else if (in_rdx2345_data.bank_index[1]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[1];
			wrdin_real[k] <= in_rdx2345_data.d_real[1]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[1]; 
		end 
		else if (in_rdx2345_data.bank_index[2]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[2]; 
			wrdin_real[k] <= in_rdx2345_data.d_real[2]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[2]; 
		end
		else if (in_rdx2345_data.bank_index[3]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[3];
			wrdin_real[k] <= in_rdx2345_data.d_real[3]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[3]; 
		end 
		else if (in_rdx2345_data.bank_index[4]==k) 
		begin
			wraddr_wr[k] <= in_rdx2345_data.bank_addr[4];
			wrdin_real[k] <= in_rdx2345_data.d_real[4]; 
			wrdin_imag[k] <= in_rdx2345_data.d_imag[4]; 
		end
		else
		begin
			wraddr_wr[k] <= 0;
			wrdin_real[k] <= 0; 
			wrdin_imag[k] <= 0;
		end 
	end
end
end
endgenerate

//------------------------------------------------
//------------------ 4th stage: Source ------------
//------------------------------------------------
always@(posedge clk)
begin
	if (!rst_n)
	begin
		clr_n_PFA_addr_o <= 0;
	end
	else
	begin
		if (cnt_source_ongoing == 12'd1)
			clr_n_PFA_addr_o <= 1'b1;
		else if (cnt_source_ongoing == dftpts+'d1)
			clr_n_PFA_addr_o <= 1'b0;
		else
			clr_n_PFA_addr_o <= clr_n_PFA_addr_o;
	end
end

logic [2:0]  k1,k2,k3,k4,k5,k6; 

PFA_addr_trans_out #(
		.wDataInOut (10)
	)
PFA_addr_trans_o_inst
	(
	.clk  (clk),    
	.rst_n  (rst_n), 

	.clr_n (clr_n_PFA_addr_o),

	.Nf1 (ctrl.Nf_PFA[0]),  //N1
	.Nf2 (ctrl.Nf_PFA[1]),  //N2
	.Nf3 (ctrl.Nf_PFA[2]),  //N3
	.q_p (ctrl.q_p_o),  //q'
	.r_p (ctrl.r_p_o),  //r'

	.k1 (k1_PFA_out),
	.k2 (k2_PFA_out),
	.k3 (k3_PFA_out)
);

//-------- Below is only 1200 case -----------
assign k1 = k1_PFA_out % 3'd4;
assign k2 = k1_PFA_out / 3'd4;
assign k3 = k2_PFA_out % 3'd5;
assign k4 = k2_PFA_out / 3'd5;
assign k5 = k3_PFA_out;
assign k6 = 0;
always@(posedge clk)
begin 
	if (!rst_n)
	begin
		N_PFA_out <= 0;
	end
	else
	begin
		N_PFA_out <= k1*10'd300 + k2*10'd75 + k3*10'd15 + k4*10'd3 + k5 + k6;
	end
end


//-------------------------------------------- 


always@(posedge clk)
begin 
	if (!rst_n)
	begin
		bank_index_source_r <= 0;
	end
	else
	begin
		// N_PFA_out <= (stat_to_ctrl.source_ongoing)? N_PFA_out+12'd1 
		//                  : 12'd0 ;
		bank_index_source_r <= bank_index_source;
	end
end

divider_7 divider_7_inst2 (
	.dividend 	(N_PFA_out),  

	.quotient 	(bank_addr_source),
	.remainder 	(bank_index_source)
);

always@(*)
begin
	case (bank_index_source)
	3'd0:  rden_source = 7'b1000000;
	3'd1:  rden_source = 7'b0100000;
	3'd2:  rden_source = 7'b0010000;
	3'd3:  rden_source = 7'b0001000;
	3'd4:  rden_source = 7'b0000100;
	3'd5:  rden_source = 7'b0000010;
	3'd6:  rden_source = 7'b0000001;
	default: rden_source = 7'd0;
	endcase
end

generate
for (i=0; i<7; i++) begin : rdaddr_RAM_gen
assign rdaddr_RAM[i]= (ctrl.state==2'b01)? rdaddr_rd[i] : bank_addr_source;
assign rden[i] = (ctrl.state==2'b01)? rden_rd[i] : 
                 (rden_source[i] & stat_to_ctrl.source_ongoing);
assign d_real_rd[i] = (ctrl.state==2'b01)? dout_real_RAM[i] : 30'd0;
assign d_imag_rd[i] = (ctrl.state==2'b01)? dout_imag_RAM[i] : 30'd0;
end
endgenerate

assign out_data.d_real = dout_real_RAM[bank_index_source_r];
assign out_data.d_imag = dout_imag_RAM[bank_index_source_r];

always@(posedge clk)
begin
	if (!rst_n)
	begin
		out_data.sop <= 0;
		out_data.eop <= 0;
		out_data.valid <= 0;
	end
	else
	begin
		out_data.sop <= (cnt_source_ongoing==12'd3)? 1'b1 : 1'b0;
		out_data.eop <= (cnt_source_ongoing==dftpts+12'd2)? 1'b1 : 1'b0;
		if (cnt_source_ongoing==12'd3)
			out_data.valid <= 1'b1;
		else if (out_data.eop)
			out_data.valid <= 1'b0;
		else
			out_data.valid <= out_data.valid;
	end
end

endmodule