module mrd_rdx2345_twdl (
	input clk,    
	input rst_n,  

	mrd_rdx2345_if from_mem,
	mrd_rdx2345_if to_mem
);

always@(posedge clk)
begin
	to_mem.fsm <= from_mem.fsm;
	to_mem.valid <= from_mem.valid;
	to_mem.d_real <= from_mem.d_real;
	to_mem.d_imag <= from_mem.d_imag;
	to_mem.bank_index <= from_mem.bank_index;
	to_mem.bank_addr <= from_mem.bank_addr;
	to_mem.tw_ROM_sel <= from_mem.tw_ROM_sel;
	to_mem.tw_ROM_addr_step <= from_mem.tw_ROM_addr_step;
	to_mem.tw_ROM_exp_ceil <= from_mem.tw_ROM_exp_ceil;
	to_mem.tw_ROM_exp_time <= from_mem.tw_ROM_exp_time;
end

endmodule