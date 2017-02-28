// Output :   exp(-i* 2pi* numerator/demoniator)
// Delay :    24 clk cycles    numerator/demoniator --> dout_real/dout_imag
module coeff_twdl_CTA #(parameter
	wDataIn = 12,
	wDataOut = 16,
	An = 16384/1.647
	)
	(
	input clk,
	input rst_n,

	input [wDataIn-1:0] numerator,
	input [wDataIn-1:0] demoninator,

	output signed [wDataOut-1:0] dout_real,
	output signed [wDataOut-1:0] dout_imag
);

logic [31:0] quotient, quotient_round;
logic signed [wDataOut-1:0]  cosine, sine;
logic [wDataIn-1:0]  remainder;

divider_pipe0  #(
	.w_divident  (44),
	.w_divisor  (12)
	)
divider_pipe0_inst (
	.clk  (clk),  
	.rst_n  (rst_n),

	.dividend  ({numerator, 32'd0}),  
	.divisor  (demoninator),

	.quotient  (quotient),
	.remainder  (remainder)
);

assign quotient_round = (remainder > (demoninator >>1)) ?
                        quotient + 1'd1 : quotient;


  // Generate table of atan values
  wire signed [31:0] atan_table [0:30];
                          
  assign atan_table[00] = 'b00100000000000000000000000000000; // 45.000 degrees -> atan(2^0)
  assign atan_table[01] = 'b00010010111001000000010100011101; // 26.565 degrees -> atan(2^-1)
  assign atan_table[02] = 'b00001001111110110011100001011011; // 14.036 degrees -> atan(2^-2)
  assign atan_table[03] = 'b00000101000100010001000111010100; // atan(2^-3)
  assign atan_table[04] = 'b00000010100010110000110101000011;
  assign atan_table[05] = 'b00000001010001011101011111100001;
  assign atan_table[06] = 'b00000000101000101111011000011110;
  assign atan_table[07] = 'b00000000010100010111110001010101;
  assign atan_table[08] = 'b00000000001010001011111001010011;
  assign atan_table[09] = 'b00000000000101000101111100101110;
  assign atan_table[10] = 'b00000000000010100010111110011000;
  assign atan_table[11] = 'b00000000000001010001011111001100;
  assign atan_table[12] = 'b00000000000000101000101111100110;
  assign atan_table[13] = 'b00000000000000010100010111110011;
  assign atan_table[14] = 'b00000000000000001010001011111001;
  assign atan_table[15] = 'b00000000000000000101000101111100;
  assign atan_table[16] = 'b00000000000000000010100010111110;
  assign atan_table[17] = 'b00000000000000000001010001011111;
  assign atan_table[18] = 'b00000000000000000000101000101111;
  assign atan_table[19] = 'b00000000000000000000010100010111;
  assign atan_table[20] = 'b00000000000000000000001010001011;
  assign atan_table[21] = 'b00000000000000000000000101000101;
  assign atan_table[22] = 'b00000000000000000000000010100010;
  assign atan_table[23] = 'b00000000000000000000000001010001;
  assign atan_table[24] = 'b00000000000000000000000000101000;
  assign atan_table[25] = 'b00000000000000000000000000010100;
  assign atan_table[26] = 'b00000000000000000000000000001010;
  assign atan_table[27] = 'b00000000000000000000000000000101;
  assign atan_table[28] = 'b00000000000000000000000000000010;
  assign atan_table[29] = 'b00000000000000000000000000000001;
  assign atan_table[30] = 'b00000000000000000000000000000000;


// localparam An = 32000/1.647;
// localparam An = 16384/1.647;
logic [wDataOut-1:0]  xin = An;
CORDIC
cordic_inst(clk, cosine, sine, xin, 16'd0, quotient_round, atan_table);

assign dout_real = cosine;
assign dout_imag = - sine;

endmodule