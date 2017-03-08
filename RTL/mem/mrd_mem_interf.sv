// "mrd" refers to "mixed radix dft"

package mrd_mem_pkt;
	parameter int wDATA = 18;
	parameter int wADDR = 8;
endpackage  // globals

interface mrd_mem_wr ();
	logic [0:6] wren; // 7 RAMs
	logic [0:6][mrd_mem_pkt::wADDR-1:0] wraddr;
	logic [0:6][mrd_mem_pkt::wDATA-1:0] din_real;
	logic [0:6][mrd_mem_pkt::wDATA-1:0] din_imag;
endinterface

interface mrd_mem_rd ();
	logic [0:6] rden; // 7 RAMs
	logic [0:6][mrd_mem_pkt::wADDR-1:0] rdaddr;
	logic [0:6][mrd_mem_pkt::wDATA-1:0] dout_real;
	logic [0:6][mrd_mem_pkt::wDATA-1:0] dout_imag;
endinterface

