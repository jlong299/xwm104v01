module mrd_switch_rdx2345 (
	input sw,    
	mrd_rdx2345_if  from_mem0,
	mrd_rdx2345_if  to_mem0,
	mrd_rdx2345_if  from_mem1,
	mrd_rdx2345_if  to_mem1,
	mrd_rdx2345_if  from_rdx2345,
	mrd_rdx2345_if  to_rdx2345
);

assign to_rdx2345 = (sw)? from_mem1 : from_mem0 ;

assign to_mem0.fsm = (sw)? from_rdx2345 : 0 ;
assign to_mem1.fsm = (sw)? 0 : from_rdx2345 ;

endmodule