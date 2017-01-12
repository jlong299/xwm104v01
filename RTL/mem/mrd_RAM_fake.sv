module mrd_RAM_fake (
	input clk,

	input wren,
	input [7:0]  wraddr,
	input [29:0] din_real,
	input [29:0] din_imag,

	input rden,
	input [7:0]  rdaddr,
	output logic [29:0] dout_real,
	output logic [29:0] dout_imag
);

logic [59:0]  mem[0:255];
always@(posedge clk)
begin
	if (wren)
	begin
		mem[wraddr][59:30] <= din_real;
		mem[wraddr][29:0] <= din_imag;
	end
	else if (rden)
	begin
		dout_real <= mem[rdaddr][59:30];
		dout_imag <= mem[rdaddr][29:0];
	end
end

endmodule