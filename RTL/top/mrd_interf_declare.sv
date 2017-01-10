// "mrd" refer to "mixed radix dft"

// interface dft_st_if (input bit clk);
interface mrd_st_if ();
	logic valid, ready, sop, eop;
	logic [17:0] d_real, d_imag;
	logic [11:0] dftpts; // Number of DFT points
	logic inverse;

	modport ST_IN (input valid, sop, eop, d_real, d_imag, dftpts, inverse,
		           output ready);
	modport ST_OUT (input ready,
		            output valid, sop, eop, d_real, d_imag, dftpts, inverse);
endinterface


interface mrd_tw_if (); // Twiddle parameters
	logic [1:0]  tw_ROM_sel;
	logic [7:0]  tw_ROM_addr_step;
	logic [7:0]  tw_ROM_exp_ceil;
	logic [7:0]  tw_ROM_exp_time;
endinterface

interface mrd_rdx2345_if ();
	logic [1:0]  fsm;
	logic valid;
	logic [4:0][17:0] d_real;
	logic [4:0][17:0] d_imag;
	mrd_tw_if tw();
endinterface


interface mrd_ctrl_if ();
	logic is_sink_stat;
	logic is_source_stat;
	logic is_rd_stat;
	logic is_wr_stat;
	

endinterface