// mrd_RAM_IP.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module mrd_RAM_IP (
		input  wire [35:0] data,      //  ram_input.datain
		input  wire [7:0]  wraddress, //           .wraddress
		input  wire [7:0]  rdaddress, //           .rdaddress
		input  wire        wren,      //           .wren
		input  wire        clock,     //           .clock
		input  wire        rden,      //           .rden
		output wire [35:0] q          // ram_output.dataout
	);

	mrd_RAM_IP_ram_2port_151_hwholfq ram_2port_0 (
		.data      (data),      //  ram_input.datain
		.wraddress (wraddress), //           .wraddress
		.rdaddress (rdaddress), //           .rdaddress
		.wren      (wren),      //           .wren
		.clock     (clock),     //           .clock
		.rden      (rden),      //           .rden
		.q         (q)          // ram_output.dataout
	);

endmodule
