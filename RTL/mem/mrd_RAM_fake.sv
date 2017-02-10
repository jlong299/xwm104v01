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

// logic [59:0]  mem[0:255];
logic [29:0]  mem_r[0:255];
logic [29:0]  mem_i[0:255];
always@(posedge clk)
begin
	if (wren)
	begin
		mem_r[wraddr] <= din_real;
		mem_i[wraddr] <= din_imag;
	end
	
	if (rden)
	begin
		dout_real <= mem_r[rdaddr];
		dout_imag <= mem_i[rdaddr];
	end
end

endmodule