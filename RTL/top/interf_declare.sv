interface dft_st_if (input bit clk);
	logic rst_n;
	logic valid, ready, sop, eop;
	logic [17:0] d_real, d_imag;
	logic [11:0] dftpts; // Number of DFT points
	logic inverse;

	modport ST_IN (input clk, rst_n, valid, sop, eop, d_real, d_imag,
		                 dftpts, inverse,
		           output ready);
	modport ST_OUT (input clk, rst_n, ready,
		            output valid, sop, eop, d_real, d_imag, dftpts, inverse);
endinterface