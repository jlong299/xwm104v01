
module altmult_complex_18_mrd (
	dataa_real,
	dataa_imag,
	datab_real,
	datab_imag,
	clock,
	result_real,
	result_imag);	

	input	[17:0]	dataa_real;
	input	[17:0]	dataa_imag;
	input	[15:0]	datab_real;
	input	[15:0]	datab_imag;
	input		clock;
	output	[33:0]	result_real;
	output	[33:0]	result_imag;
endmodule
