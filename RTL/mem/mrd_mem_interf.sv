// "mrd" refers to "mixed radix dft"

package mrd_mem_pkt;
	parameter int wDATA = 30;
	parameter int wADDR = 8;
endpackage  // globals

interface mrd_mem_wr ();
	logic wren;
	logic [mrd_mem_pkt::wADDR-1:0] wraddr;
	logic [mrd_mem_pkt::wDATA-1:0] din_real;
	logic [mrd_mem_pkt::wDATA-1:0] din_imag;
endinterface

