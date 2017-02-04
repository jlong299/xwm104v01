`timescale 1 ns / 1 ns
module mrd_twdl_tb (
);
	localparam wDataIn = 12;
	localparam wDataOut = 16;

	logic clk;
	logic rst_n;

	logic [wDataIn-1:0] numerator;
	logic [wDataIn-1:0] demoninator;

	logic [wDataOut-1:0] dout_real;
	logic [wDataOut-1:0] dout_imag;
	
initial	begin
	rst_n = 0;
	clk = 0;

	# 100 rst_n = 1'b1;
end
always # 5 clk = ~clk; //100M

always@(posedge clk)
begin
	if (!rst_n)	begin
		numerator <= 12'd0;
		demoninator <= 12'd1200;
	end
	else begin
		numerator <= numerator + 1'd1;
	end
end

mrd_twdl #(
	12,
	16
	)
mrd_twdl_inst (
	clk,
	rst_n,

	numerator,
	demoninator,

	dout_real,
	dout_imag
);

endmodule