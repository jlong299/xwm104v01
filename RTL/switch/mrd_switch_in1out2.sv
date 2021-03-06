module mrd_switch_in1out2 (
	input sw,
	mrd_st_if  in_data,
	mrd_st_if  out_data_0, out_data_1
);

assign in_data.ready = (sw)? out_data_1.ready : out_data_0.ready;

assign out_data_0.valid = (sw)? 1'b0 : in_data.valid;
assign out_data_0.sop = (sw)? 1'b0 : in_data.sop;
assign out_data_0.eop = (sw)? 1'b0 : in_data.eop;
assign out_data_0.din_real = (sw)? 18'b0 : in_data.din_real;
assign out_data_0.din_imag = (sw)? 18'b0 : in_data.din_imag;
assign out_data_0.dftpts = (sw)? 12'b0 : in_data.dftpts;
assign out_data_0.inverse = (sw)? 1'b0 : in_data.inverse;

assign out_data_1.valid = (!sw)? 1'b0 : in_data.valid;
assign out_data_1.sop = (!sw)? 1'b0 : in_data.sop;
assign out_data_1.eop = (!sw)? 1'b0 : in_data.eop;
assign out_data_1.din_real = (!sw)? 18'b0 : in_data.din_real;
assign out_data_1.din_imag = (!sw)? 18'b0 : in_data.din_imag;
assign out_data_1.dftpts = (!sw)? 12'b0 : in_data.dftpts;
assign out_data_1.inverse = (!sw)? 1'b0 : in_data.inverse;

endmodule