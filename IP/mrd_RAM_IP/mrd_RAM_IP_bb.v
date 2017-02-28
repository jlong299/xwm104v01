
module mrd_RAM_IP (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	q);	

	input	[59:0]	data;
	input	[7:0]	wraddress;
	input	[7:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	output	[59:0]	q;
endmodule
