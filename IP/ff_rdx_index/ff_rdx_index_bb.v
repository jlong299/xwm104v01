
module ff_rdx_index (
	data,
	wrreq,
	rdreq,
	clock,
	sclr,
	q);	

	input	[54:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		sclr;
	output	[54:0]	q;
endmodule
