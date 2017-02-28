
module ff_rdx_data (
	data,
	wrreq,
	rdreq,
	clock,
	sclr,
	q);	

	input	[59:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		sclr;
	output	[59:0]	q;
endmodule
