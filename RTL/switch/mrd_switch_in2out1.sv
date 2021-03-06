module mrd_switch_in2out1 (
	input sw,
	mrd_st_if  in_data_0, in_data_1,
	mrd_st_if  out_data
);

assign in_data_0.ready = (sw)? 1'b0 : out_data.ready;
assign in_data_1.ready = (!sw)? 1'b0 : out_data.ready;

assign out_data.valid = (sw)? in_data_1.valid : in_data_0.valid;
assign out_data.sop = (sw)? in_data_1.sop : in_data_0.sop;
assign out_data.eop = (sw)? in_data_1.eop : in_data_0.eop;
assign out_data.dout_real = (sw)? in_data_1.dout_real : in_data_0.dout_real;
assign out_data.dout_imag = (sw)? in_data_1.dout_imag : in_data_0.dout_imag;
assign out_data.dftpts = (sw)? in_data_1.dftpts : in_data_0.dftpts;
assign out_data.inverse = (sw)? in_data_1.inverse : in_data_0.inverse;

endmodule