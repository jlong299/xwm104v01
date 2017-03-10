
module ff_rdx_data (
	data,
	wrreq,
	rdreq,
	clock,
	sclr,
	q);	

	input	[35:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		sclr;
	output	[35:0]	q;
endmodule
