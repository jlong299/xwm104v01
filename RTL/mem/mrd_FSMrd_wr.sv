module mrd_FSMrd_wr (
	input clk,
	input rst_n,

	input [2:0] fsm,

	mrd_mem_wr wrRAM_FSMrd,
	mrd_rdx2345_if in_rdx2345_data,

	output logic wr_ongoing,
	output logic wr_ongoing_r
);
// parameter Idle = 3'd0, Sink = 3'd1, Wait_to_rd = 3'd2,
//   			Rd = 3'd3,  Wait_wr_end = 3'd4,  Source = 3'd5;
parameter Rd = 3'd3,  Wait_wr_end = 3'd4;
genvar k;
generate
for (k=3'd0; k <= 3'd6; k=k+3'd1) begin : wren_wr_gen
always@(posedge clk)
begin
	if (!rst_n)
	begin
		wrRAM_FSMrd.wren[k] <= 0;
		wrRAM_FSMrd.wraddr[k] <= 0;
		wrRAM_FSMrd.din_real[k] <= 0;
		wrRAM_FSMrd.din_imag[k] <= 0;
	end
	else
	begin
		if (in_rdx2345_data.bank_index[0]== k || 
			in_rdx2345_data.bank_index[1]== k ||
			in_rdx2345_data.bank_index[2]== k || 
			in_rdx2345_data.bank_index[3]== k ||
			in_rdx2345_data.bank_index[4]== k )
				wrRAM_FSMrd.wren[k] <= 1'b1 & in_rdx2345_data.valid;
		else wrRAM_FSMrd.wren[k] <= 1'b0;

		if (in_rdx2345_data.bank_index[0]==k) 
		begin
			wrRAM_FSMrd.wraddr[k] <= in_rdx2345_data.bank_addr[0];
			wrRAM_FSMrd.din_real[k] <= in_rdx2345_data.d_real[0]; 
			wrRAM_FSMrd.din_imag[k] <= in_rdx2345_data.d_imag[0]; 
		end
		else if (in_rdx2345_data.bank_index[1]==k) 
		begin
			wrRAM_FSMrd.wraddr[k] <= in_rdx2345_data.bank_addr[1];
			wrRAM_FSMrd.din_real[k] <= in_rdx2345_data.d_real[1]; 
			wrRAM_FSMrd.din_imag[k] <= in_rdx2345_data.d_imag[1]; 
		end 
		else if (in_rdx2345_data.bank_index[2]==k) 
		begin
			wrRAM_FSMrd.wraddr[k] <= in_rdx2345_data.bank_addr[2]; 
			wrRAM_FSMrd.din_real[k] <= in_rdx2345_data.d_real[2]; 
			wrRAM_FSMrd.din_imag[k] <= in_rdx2345_data.d_imag[2]; 
		end
		else if (in_rdx2345_data.bank_index[3]==k) 
		begin
			wrRAM_FSMrd.wraddr[k] <= in_rdx2345_data.bank_addr[3];
			wrRAM_FSMrd.din_real[k] <= in_rdx2345_data.d_real[3]; 
			wrRAM_FSMrd.din_imag[k] <= in_rdx2345_data.d_imag[3]; 
		end 
		else if (in_rdx2345_data.bank_index[4]==k) 
		begin
			wrRAM_FSMrd.wraddr[k] <= in_rdx2345_data.bank_addr[4];
			wrRAM_FSMrd.din_real[k] <= in_rdx2345_data.d_real[4]; 
			wrRAM_FSMrd.din_imag[k] <= in_rdx2345_data.d_imag[4]; 
		end
		else
		begin
			wrRAM_FSMrd.wraddr[k] <= 0;
			wrRAM_FSMrd.din_real[k] <= 0; 
			wrRAM_FSMrd.din_imag[k] <= 0;
		end 
	end
end
end
endgenerate

always@(posedge clk)
begin
	if (!rst_n)
	begin
		wr_ongoing <= 0;
		wr_ongoing_r <= 0;
	end
	else
	begin
		wr_ongoing <= (fsm==Rd || fsm==Wait_wr_end) ? 
		                           in_rdx2345_data.valid : 1'b0;
		wr_ongoing_r <= wr_ongoing;
	end
end

endmodule