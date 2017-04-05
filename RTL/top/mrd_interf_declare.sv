// "mrd" refers to "mixed radix dft"

// interface dft_st_if (input bit clk);
interface mrd_st_if ();
	logic valid, ready, sop, eop;
	logic [17:0] din_real, din_imag;
	logic [18-1:0] dout_real, dout_imag;
	logic [3:0] exp;
	// logic [5:0] dftpts; // Number of DFT points
	logic [5:0] size; // Number of DFT points  //0~33 : 12~1200
	// logic inverse;

	// modport ST_IN (input valid, sop, eop, d_real, d_imag, dftpts, inverse,
	// 	           output ready);
	// modport ST_OUT (input ready,
	// 	            output valid, sop, eop, d_real, d_imag, dftpts, inverse);
endinterface

interface mrd_rdx2345_if ();
	logic [2:0]  factor;
	logic valid;
	logic signed [18-1:0] d_real [0:4];
	logic signed [18-1:0] d_imag [0:4];
	logic [3:0] exp;
	// logic signed [0:4][29:0] d_real ;
	// logic signed [0:4][29:0] d_imag ;
	logic [0:4][2:0]  bank_index;
	logic [0:4][7:0]  bank_addr;

	// logic [0:4][11:0]  twdl_numrtr;
	logic [11:0]  twdl_numrtr_1;
	logic [11:0]  twdl_demontr; 

	logic [20-1:0] quotient;
	logic [12-1:0] remainder;
endinterface


interface mrd_ctrl_if ();
	//state: set state of mrd_mem_top 
	// logic [1:0] state;

	logic [2:0]  NumOfFactors;
	logic [0:5][2:0] Nf; // Factors
	logic [0:5][11:0] dftpts_div_Nf;  // N / Nf
	logic [0:5][11:0] twdl_demontr;   // Nf[k]*...*Nf[5]
	logic [2:0] stage_of_rdx2;
	logic [0:5][20-1:0] quotient; //For twiddle coeffe calc
	logic [0:5][12-1:0] remainder; //For twiddle coeffe calc
endinterface

// //mrd_stat_if :  State signals from mrd_mem_top to mrd_ctrl_fsm.
// interface mrd_stat_if ();
// 	logic sink_sop;
// 	logic [11:0]  dftpts;

// 	logic source_start;
// 	logic source_end; 
// endinterface