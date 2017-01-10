module mrd_switch_in1out2 (
	input sw,
	dft_st_if.ST_IN  in_data,
	dft_st_if.ST_OUT  out_data_0, out_data_1
);

assign in_data.ready = (sw)? out_data_1.ready : out_data_0.ready;

assign out_data_0.valid = (sw)? 1'b0 : in_data.valid;
assign out_data_0.sop = (sw)? 1'b0 : in_data.sop;
assign out_data_0.eop = (sw)? 1'b0 : in_data.eop;
assign out_data_0.d_real = (sw)? 18'b0 : in_data.d_real;
assign out_data_0.d_imag = (sw)? 18'b0 : in_data.d_imag;
assign out_data_0.dftpts = (sw)? 12'b0 : in_data.dftpts;
assign out_data_0.inverse = (sw)? 1'b0 : in_data.inverse;

assign out_data_1.valid = (!sw)? 1'b0 : in_data.valid;
assign out_data_1.sop = (!sw)? 1'b0 : in_data.sop;
assign out_data_1.eop = (!sw)? 1'b0 : in_data.eop;
assign out_data_1.d_real = (!sw)? 18'b0 : in_data.d_real;
assign out_data_1.d_imag = (!sw)? 18'b0 : in_data.d_imag;
assign out_data_1.dftpts = (!sw)? 12'b0 : in_data.dftpts;
assign out_data_1.inverse = (!sw)? 1'b0 : in_data.inverse;

endmodule