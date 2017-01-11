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
	logic [4:0][2:0]  bank_index;
	logic [4:0][9:0]  bank_addr;
	mrd_tw_if tw();
endinterface


interface mrd_ctrl_if ();
	//state: set state of mrd_mem_top 
	//00 sink; 
	//11 source; 
	//01 rd;  
	//10 wr
	logic [1:0] state;
	// CTA stage
	logic [2:0] current_stage;

	logic [0:5][2:0] Nf;
	logic [0:2][9:0] Nf_PFA;
	logic [9:0] q_p;
	logic [9:0] r_p;
endinterface

//mrd_stat_if :  State signals from mrd_mem_top to mrd_ctrl_fsm.
//    1) sink_sop
//    2) dftpts : valid when sink_sop==1
//    3) sink_ongoing :  =1 when sink process is ongoing
//    4) source_ongoing :  =1 when source process is ongoing
//    5) rd_ongoing :  =1 when rd process is ongoing
//    6) wr_ongoing :  =1 when wr process is ongoing
interface mrd_stat_if ();
	logic sink_sop;
	logic [11:0]  dftpts;
	logic sink_ongoing;
	logic source_ongoing;
	logic rd_ongoing;
	logic wr_ongoing;
endinterface