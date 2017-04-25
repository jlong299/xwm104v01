// mrd_ROM_Init.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module mrd_ROM_Init (
		input  wire [6:0]  address, //  rom_input.address
		input  wire        clock,   //           .clk
		output wire [63:0] q        // rom_output.dataout
	);

	mrd_ROM_Init_rom_1port_151_bgifz3i rom_1port_0 (
		.address (address), //  rom_input.address
		.clock   (clock),   //           .clk
		.q       (q)        // rom_output.dataout
	);

endmodule
