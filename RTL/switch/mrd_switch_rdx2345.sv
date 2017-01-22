module mrd_switch_rdx2345 (
	input sw,    
	mrd_rdx2345_if  from_mem0,
	mrd_rdx2345_if  to_mem0,
	mrd_rdx2345_if  from_mem1,
	mrd_rdx2345_if  to_mem1,
	mrd_rdx2345_if  from_rdx2345,
	mrd_rdx2345_if  to_rdx2345
);

assign to_rdx2345.factor = (sw)? from_mem1.factor : from_mem0.factor ;
assign to_rdx2345.valid = (sw)? from_mem1.valid : from_mem0.valid ;
assign to_rdx2345.d_real = (sw)? from_mem1.d_real : from_mem0.d_real ;
assign to_rdx2345.d_imag = (sw)? from_mem1.d_imag : from_mem0.d_imag ;
assign to_rdx2345.bank_index = (sw)? from_mem1.bank_index : 
                               from_mem0.bank_index ;
assign to_rdx2345.bank_addr = (sw)? from_mem1.bank_addr : 
                              from_mem0.bank_addr ;
assign to_rdx2345.tw_ROM_addr_step = (sw)? from_mem1.tw_ROM_addr_step : 
                                  from_mem0.tw_ROM_addr_step ;
assign to_rdx2345.tw_ROM_exp_ceil = (sw)? from_mem1.tw_ROM_exp_ceil : 
                                  from_mem0.tw_ROM_exp_ceil ;
assign to_rdx2345.tw_ROM_exp_time = (sw)? from_mem1.tw_ROM_exp_time : 
                                  from_mem0.tw_ROM_exp_time ;


assign to_mem0.factor = (sw)? from_rdx2345.factor : 0 ;
assign to_mem0.valid = (sw)? from_rdx2345.valid : 0 ;
assign to_mem0.d_real[0] = (sw)? from_rdx2345.d_real[0] : 0 ;
assign to_mem0.d_real[1] = (sw)? from_rdx2345.d_real[1] : 0 ;
assign to_mem0.d_real[2] = (sw)? from_rdx2345.d_real[2] : 0 ;
assign to_mem0.d_real[3] = (sw)? from_rdx2345.d_real[3] : 0 ;
assign to_mem0.d_real[4] = (sw)? from_rdx2345.d_real[4] : 0 ;
assign to_mem0.d_imag[0] = (sw)? from_rdx2345.d_imag[0] : 0 ;
assign to_mem0.d_imag[1] = (sw)? from_rdx2345.d_imag[1] : 0 ;
assign to_mem0.d_imag[2] = (sw)? from_rdx2345.d_imag[2] : 0 ;
assign to_mem0.d_imag[3] = (sw)? from_rdx2345.d_imag[3] : 0 ;
assign to_mem0.d_imag[4] = (sw)? from_rdx2345.d_imag[4] : 0 ;
assign to_mem0.bank_index = (sw)? from_rdx2345.bank_index : 
                               0 ;
assign to_mem0.bank_addr = (sw)? from_rdx2345.bank_addr : 
                              0 ;
assign to_mem0.tw_ROM_addr_step = (sw)? from_rdx2345.tw_ROM_addr_step : 
                                  0 ;
assign to_mem0.tw_ROM_exp_ceil = (sw)? from_rdx2345.tw_ROM_exp_ceil : 
                                  0 ;
assign to_mem0.tw_ROM_exp_time = (sw)? from_rdx2345.tw_ROM_exp_time : 
                                  0 ;

assign to_mem1.factor = (sw)? 0 : from_rdx2345.factor ;
assign to_mem1.valid = (sw)? 0 : from_rdx2345.valid ;
assign to_mem1.d_real[0] = (sw)? 0 : from_rdx2345.d_real[0] ;
assign to_mem1.d_real[1] = (sw)? 0 : from_rdx2345.d_real[1] ;
assign to_mem1.d_real[2] = (sw)? 0 : from_rdx2345.d_real[2] ;
assign to_mem1.d_real[3] = (sw)? 0 : from_rdx2345.d_real[3] ;
assign to_mem1.d_real[4] = (sw)? 0 : from_rdx2345.d_real[4] ;
assign to_mem1.d_imag[0] = (sw)? 0 : from_rdx2345.d_imag[0] ;
assign to_mem1.d_imag[1] = (sw)? 0 : from_rdx2345.d_imag[1] ;
assign to_mem1.d_imag[2] = (sw)? 0 : from_rdx2345.d_imag[2] ;
assign to_mem1.d_imag[3] = (sw)? 0 : from_rdx2345.d_imag[3] ;
assign to_mem1.d_imag[4] = (sw)? 0 : from_rdx2345.d_imag[4] ;
assign to_mem1.bank_index = (sw)? 0 : from_rdx2345.bank_index ; 
assign to_mem1.bank_addr = (sw)? 0 : from_rdx2345.bank_addr ; 
assign to_mem1.tw_ROM_addr_step = (sw)? 0 : 
                                     from_rdx2345.tw_ROM_addr_step ;
assign to_mem1.tw_ROM_exp_ceil = (sw)? 0 : from_rdx2345.tw_ROM_exp_ceil; 
assign to_mem1.tw_ROM_exp_time = (sw)? 0 : from_rdx2345.tw_ROM_exp_time; 

endmodule