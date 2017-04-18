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

	input twdl_sop,
	input [wDataIn-1:0] numerator,
	input [wDataIn-1:0] demoninator,
  	input [20-1:0] twdl_quotient,
  	input [12-1:0] twdl_remainder,

	output logic signed [wDataOut-1:0] dout_real_1,
	output logic signed [wDataOut-1:0] dout_imag_1,
	output logic signed [wDataOut-1:0] dout_real_3,
	output logic signed [wDataOut-1:0] dout_imag_3
);

// logic [31:0] quotient, quotient_round;
logic [20-1:0] quotient;
logic signed [wDataOut-1:0]  cosine [0:3];
logic signed [wDataOut-1:0]  sine [0:3];
logic [wDataIn-1:0]  remainder;

// divider_pipe0  #(
// 	.w_divident  (44),
// 	.w_divisor  (12)
// 	)
// divider_pipe0_inst (
// 	.clk  (clk),  
// 	.rst_n  (rst_n),

// 	.dividend  ({numerator, 32'd0}),  
// 	.divisor  (demoninator),

// 	.quotient  (quotient),
// 	.remainder  (remainder)
// );

 // ----------------------------------------------
 // quotient = numerator * 2^32 / demoninator
 // remainder = numerator * 2^32 % demoninator
 // ----------------------------------------------

 //----- Only 1200 --------
 // 2^20 = 1200 * 873 + 976
 // 2^20 = 300 * 3495 + 76
 // 2^20 = 75 * 13981 + 1
 // 2^20 = 15 * 69905 + 1
 // 2^20 = 3 * 349525 + 1

logic [20-1:0]  quotient_temp;
logic [12-1:0]  remainder_temp, remainder_remain;
logic remainder_carry_in;
logic [12-1:0] cnt_numerator;
always@(posedge clk) begin
	if (!rst_n) begin
		cnt_numerator <= 0;
	end
	else begin
		if (twdl_sop)
			cnt_numerator <= 12'd1;
		else 
			cnt_numerator <= (cnt_numerator == numerator-12'd1)? 12'd0 : cnt_numerator+12'd1;
	end
end
always@(posedge clk) begin
	if (!rst_n) begin
		quotient <= 0;
		remainder <= 0;
	end
	else begin
		// if (twdl_sop==1'b1 || cnt_numerator==12'd0) begin
		if (twdl_sop==1'b1 || cnt_numerator==12'd0 || demoninator==12'd3 || demoninator==12'd1 ) begin
			quotient <= 0;
			remainder <= 0;
		end
		else begin
			quotient <= quotient_temp + remainder_carry_in;
			remainder <= remainder_remain;
		end
	end
end

assign quotient_temp = quotient + twdl_quotient;
assign remainder_temp = remainder + twdl_remainder;
assign remainder_carry_in = (remainder_temp < demoninator)? 1'd0 : 1'd1;
assign remainder_remain = (remainder_temp < demoninator)? remainder_temp : remainder_temp-demoninator;

// assign quotient_round = (remainder > (demoninator >>1)) ?
//                         quotient + 1'd1 : quotient;


// localparam An = 32000/1.647;
// localparam An = 16384/1.647;
logic [wDataOut-1:0]  xin = An;

logic [20-1:0] quotient_r [0:3];
always@(posedge clk) begin
	if (!rst_n) begin
		quotient_r[0] <= 0;
		//quotient_r[1] <= 0;
		quotient_r[2] <= 0;
		//quotient_r[3] <= 0;
	end
	else begin
		quotient_r[0] <= quotient;
		//quotient_r[1] <= quotient + quotient;
		quotient_r[2] <= quotient + {quotient,1'b0};
		//quotient_r[3] <= {quotient,1'b0} + {quotient,1'b0};
	end
end


  // // Generate table of atan values
  // logic signed [20-1:0] atan_table [0:30];
 
  // assign atan_table[00] = 'b00100000000000000000; // 45.000 degrees -> atan(2^0)
  // assign atan_table[01] = 'b00010010111001000000; // 26.565 degrees -> atan(2^-1)
  // assign atan_table[02] = 'b00001001111110110011; // 14.036 degrees -> atan(2^-2)
  // assign atan_table[03] = 'b00000101000100010001; // atan(2^-3)
  // assign atan_table[04] = 'b00000010100010110000;
  // assign atan_table[05] = 'b00000001010001011101;
  // assign atan_table[06] = 'b00000000101000101111;
  // assign atan_table[07] = 'b00000000010100010111;
  // assign atan_table[08] = 'b00000000001010001011;
  // assign atan_table[09] = 'b00000000000101000101;
  // assign atan_table[10] = 'b00000000000010100010;
  // assign atan_table[11] = 'b00000000000001010001;
  // assign atan_table[12] = 'b00000000000000101000;
  // assign atan_table[13] = 'b00000000000000010100;
  // assign atan_table[14] = 'b00000000000000001010;
  // assign atan_table[15] = 'b00000000000000000101;
  // assign atan_table[16] = 'b00000000000000000010;
  // assign atan_table[17] = 'b00000000000000000001;

  logic signed [20-1:0] atan_table [0:12];

  assign atan_table[00] = 'b00100000000000000000; // 45.000 degrees -> atan(2^0)
  assign atan_table[01] = 'b00010010111001000000; // 26.565 degrees -> atan(2^-1)
  assign atan_table[02] = 'b00001001111110110011; // 14.036 degrees -> atan(2^-2)
  assign atan_table[03] = 'b00000101000100010001; // atan(2^-3)
  assign atan_table[04] = 'b00000010100010110000;
  assign atan_table[05] = 'b00000001010001011101;
  assign atan_table[06] = 'b00000000101000101111;
  assign atan_table[07] = 'b00000000010100010111;
  assign atan_table[08] = 'b00000000001010001011;
  assign atan_table[09] = 'b00000000000101000101;
  assign atan_table[10] = 'b00000000000010100010;
  assign atan_table[11] = 'b00000000000001010001;
  assign atan_table[12] = 'b00000000000000101000;
  // assign atan_table[13] = 'b00000000000000010100;


CORDIC_v02
cordic_inst(clk, cosine[0], sine[0], xin, 16'd0, quotient_r[0], atan_table);

CORDIC_v02
cordic_inst2(clk, cosine[2], sine[2], xin, 16'd0, quotient_r[2], atan_table);

always@(posedge clk) dout_real_1 <= cosine[0];
always@(posedge clk) dout_imag_1 <= - sine[0];
always@(posedge clk) dout_real_3 <= cosine[2];
always@(posedge clk) dout_imag_3 <= - sine[2];

endmodule