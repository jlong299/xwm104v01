module mrd_ROM_fake (
	input clk,

	input [2:0]  factor,
	input [7:0]  rdaddr,

	output logic signed [17:0] dout_real,
	output logic signed [17:0] dout_imag
);

// logic [59:0]  mem[0:255];
logic signed [29:0]  mem2_r[0:255];
logic signed [29:0]  mem2_i[0:255];
logic signed [29:0]  mem3_r[0:255];
logic signed [29:0]  mem3_i[0:255];
logic signed [29:0]  mem5_r[0:255];
logic signed [29:0]  mem5_i[0:255];
always@(posedge clk)
begin
	if (factor==3'd5)
	begin
		dout_real <= mem5_r[rdaddr];
		dout_imag <= mem5_i[rdaddr];
	end
	else if (factor==3'd3)
	begin
		dout_real <= mem3_r[rdaddr];
		dout_imag <= mem3_i[rdaddr];
	end
	else
	begin
		dout_real <= mem2_r[rdaddr];
		dout_imag <= mem2_i[rdaddr];
	end
end


assign mem2_r[0] = 18'd65536;
assign mem2_i[0] = 18'd0;
assign mem2_r[1] = 18'd65516;
assign mem2_i[1] = -18'd1608;
assign mem2_r[2] = 18'd65457;
assign mem2_i[2] = -18'd3216;
assign mem2_r[3] = 18'd65358;
assign mem2_i[3] = -18'd4821;
assign mem2_r[4] = 18'd65220;
assign mem2_i[4] = -18'd6424;
assign mem2_r[5] = 18'd65043;
assign mem2_i[5] = -18'd8022;
assign mem2_r[6] = 18'd64827;
assign mem2_i[6] = -18'd9616;
assign mem2_r[7] = 18'd64571;
assign mem2_i[7] = -18'd11204;
assign mem2_r[8] = 18'd64277;
assign mem2_i[8] = -18'd12785;
assign mem2_r[9] = 18'd63944;
assign mem2_i[9] = -18'd14359;
assign mem2_r[10] = 18'd63572;
assign mem2_i[10] = -18'd15924;
assign mem2_r[11] = 18'd63162;
assign mem2_i[11] = -18'd17479;
assign mem2_r[12] = 18'd62714;
assign mem2_i[12] = -18'd19024;
assign mem2_r[13] = 18'd62228;
assign mem2_i[13] = -18'd20557;
assign mem2_r[14] = 18'd61705;
assign mem2_i[14] = -18'd22078;
assign mem2_r[15] = 18'd61145;
assign mem2_i[15] = -18'd23586;
assign mem2_r[16] = 18'd60547;
assign mem2_i[16] = -18'd25080;
assign mem2_r[17] = 18'd59914;
assign mem2_i[17] = -18'd26558;
assign mem2_r[18] = 18'd59244;
assign mem2_i[18] = -18'd28020;
assign mem2_r[19] = 18'd58538;
assign mem2_i[19] = -18'd29466;
assign mem2_r[20] = 18'd57798;
assign mem2_i[20] = -18'd30893;
assign mem2_r[21] = 18'd57022;
assign mem2_i[21] = -18'd32303;
assign mem2_r[22] = 18'd56212;
assign mem2_i[22] = -18'd33692;
assign mem2_r[23] = 18'd55368;
assign mem2_i[23] = -18'd35062;
assign mem2_r[24] = 18'd54491;
assign mem2_i[24] = -18'd36410;
assign mem2_r[25] = 18'd53581;
assign mem2_i[25] = -18'd37736;
assign mem2_r[26] = 18'd52639;
assign mem2_i[26] = -18'd39040;
assign mem2_r[27] = 18'd51665;
assign mem2_i[27] = -18'd40320;
assign mem2_r[28] = 18'd50660;
assign mem2_i[28] = -18'd41576;
assign mem2_r[29] = 18'd49624;
assign mem2_i[29] = -18'd42806;
assign mem2_r[30] = 18'd48559;
assign mem2_i[30] = -18'd44011;
assign mem2_r[31] = 18'd47464;
assign mem2_i[31] = -18'd45190;
assign mem2_r[32] = 18'd46341;
assign mem2_i[32] = -18'd46341;
assign mem2_r[33] = 18'd45190;
assign mem2_i[33] = -18'd47464;
assign mem2_r[34] = 18'd44011;
assign mem2_i[34] = -18'd48559;
assign mem2_r[35] = 18'd42806;
assign mem2_i[35] = -18'd49624;
assign mem2_r[36] = 18'd41576;
assign mem2_i[36] = -18'd50660;
assign mem2_r[37] = 18'd40320;
assign mem2_i[37] = -18'd51665;
assign mem2_r[38] = 18'd39040;
assign mem2_i[38] = -18'd52639;
assign mem2_r[39] = 18'd37736;
assign mem2_i[39] = -18'd53581;
assign mem2_r[40] = 18'd36410;
assign mem2_i[40] = -18'd54491;
assign mem2_r[41] = 18'd35062;
assign mem2_i[41] = -18'd55368;
assign mem2_r[42] = 18'd33692;
assign mem2_i[42] = -18'd56212;
assign mem2_r[43] = 18'd32303;
assign mem2_i[43] = -18'd57022;
assign mem2_r[44] = 18'd30893;
assign mem2_i[44] = -18'd57798;
assign mem2_r[45] = 18'd29466;
assign mem2_i[45] = -18'd58538;
assign mem2_r[46] = 18'd28020;
assign mem2_i[46] = -18'd59244;
assign mem2_r[47] = 18'd26558;
assign mem2_i[47] = -18'd59914;
assign mem2_r[48] = 18'd25080;
assign mem2_i[48] = -18'd60547;
assign mem2_r[49] = 18'd23586;
assign mem2_i[49] = -18'd61145;
assign mem2_r[50] = 18'd22078;
assign mem2_i[50] = -18'd61705;
assign mem2_r[51] = 18'd20557;
assign mem2_i[51] = -18'd62228;
assign mem2_r[52] = 18'd19024;
assign mem2_i[52] = -18'd62714;
assign mem2_r[53] = 18'd17479;
assign mem2_i[53] = -18'd63162;
assign mem2_r[54] = 18'd15924;
assign mem2_i[54] = -18'd63572;
assign mem2_r[55] = 18'd14359;
assign mem2_i[55] = -18'd63944;
assign mem2_r[56] = 18'd12785;
assign mem2_i[56] = -18'd64277;
assign mem2_r[57] = 18'd11204;
assign mem2_i[57] = -18'd64571;
assign mem2_r[58] = 18'd9616;
assign mem2_i[58] = -18'd64827;
assign mem2_r[59] = 18'd8022;
assign mem2_i[59] = -18'd65043;
assign mem2_r[60] = 18'd6424;
assign mem2_i[60] = -18'd65220;
assign mem2_r[61] = 18'd4821;
assign mem2_i[61] = -18'd65358;
assign mem2_r[62] = 18'd3216;
assign mem2_i[62] = -18'd65457;
assign mem2_r[63] = 18'd1608;
assign mem2_i[63] = -18'd65516;
assign mem2_r[64] = 18'd0;
assign mem2_i[64] = -18'd65536;
assign mem2_r[65] = -18'd1608;
assign mem2_i[65] = -18'd65516;
assign mem2_r[66] = -18'd3216;
assign mem2_i[66] = -18'd65457;
assign mem2_r[67] = -18'd4821;
assign mem2_i[67] = -18'd65358;
assign mem2_r[68] = -18'd6424;
assign mem2_i[68] = -18'd65220;
assign mem2_r[69] = -18'd8022;
assign mem2_i[69] = -18'd65043;
assign mem2_r[70] = -18'd9616;
assign mem2_i[70] = -18'd64827;
assign mem2_r[71] = -18'd11204;
assign mem2_i[71] = -18'd64571;
assign mem2_r[72] = -18'd12785;
assign mem2_i[72] = -18'd64277;
assign mem2_r[73] = -18'd14359;
assign mem2_i[73] = -18'd63944;
assign mem2_r[74] = -18'd15924;
assign mem2_i[74] = -18'd63572;
assign mem2_r[75] = -18'd17479;
assign mem2_i[75] = -18'd63162;
assign mem2_r[76] = -18'd19024;
assign mem2_i[76] = -18'd62714;
assign mem2_r[77] = -18'd20557;
assign mem2_i[77] = -18'd62228;
assign mem2_r[78] = -18'd22078;
assign mem2_i[78] = -18'd61705;
assign mem2_r[79] = -18'd23586;
assign mem2_i[79] = -18'd61145;
assign mem2_r[80] = -18'd25080;
assign mem2_i[80] = -18'd60547;
assign mem2_r[81] = -18'd26558;
assign mem2_i[81] = -18'd59914;
assign mem2_r[82] = -18'd28020;
assign mem2_i[82] = -18'd59244;
assign mem2_r[83] = -18'd29466;
assign mem2_i[83] = -18'd58538;
assign mem2_r[84] = -18'd30893;
assign mem2_i[84] = -18'd57798;
assign mem2_r[85] = -18'd32303;
assign mem2_i[85] = -18'd57022;
assign mem2_r[86] = -18'd33692;
assign mem2_i[86] = -18'd56212;
assign mem2_r[87] = -18'd35062;
assign mem2_i[87] = -18'd55368;
assign mem2_r[88] = -18'd36410;
assign mem2_i[88] = -18'd54491;
assign mem2_r[89] = -18'd37736;
assign mem2_i[89] = -18'd53581;
assign mem2_r[90] = -18'd39040;
assign mem2_i[90] = -18'd52639;
assign mem2_r[91] = -18'd40320;
assign mem2_i[91] = -18'd51665;
assign mem2_r[92] = -18'd41576;
assign mem2_i[92] = -18'd50660;
assign mem2_r[93] = -18'd42806;
assign mem2_i[93] = -18'd49624;
assign mem2_r[94] = -18'd44011;
assign mem2_i[94] = -18'd48559;
assign mem2_r[95] = -18'd45190;
assign mem2_i[95] = -18'd47464;
assign mem2_r[96] = -18'd46341;
assign mem2_i[96] = -18'd46341;
assign mem2_r[97] = -18'd47464;
assign mem2_i[97] = -18'd45190;
assign mem2_r[98] = -18'd48559;
assign mem2_i[98] = -18'd44011;
assign mem2_r[99] = -18'd49624;
assign mem2_i[99] = -18'd42806;
assign mem2_r[100] = -18'd50660;
assign mem2_i[100] = -18'd41576;
assign mem2_r[101] = -18'd51665;
assign mem2_i[101] = -18'd40320;
assign mem2_r[102] = -18'd52639;
assign mem2_i[102] = -18'd39040;
assign mem2_r[103] = -18'd53581;
assign mem2_i[103] = -18'd37736;
assign mem2_r[104] = -18'd54491;
assign mem2_i[104] = -18'd36410;
assign mem2_r[105] = -18'd55368;
assign mem2_i[105] = -18'd35062;
assign mem2_r[106] = -18'd56212;
assign mem2_i[106] = -18'd33692;
assign mem2_r[107] = -18'd57022;
assign mem2_i[107] = -18'd32303;
assign mem2_r[108] = -18'd57798;
assign mem2_i[108] = -18'd30893;
assign mem2_r[109] = -18'd58538;
assign mem2_i[109] = -18'd29466;
assign mem2_r[110] = -18'd59244;
assign mem2_i[110] = -18'd28020;
assign mem2_r[111] = -18'd59914;
assign mem2_i[111] = -18'd26558;
assign mem2_r[112] = -18'd60547;
assign mem2_i[112] = -18'd25080;
assign mem2_r[113] = -18'd61145;
assign mem2_i[113] = -18'd23586;
assign mem2_r[114] = -18'd61705;
assign mem2_i[114] = -18'd22078;
assign mem2_r[115] = -18'd62228;
assign mem2_i[115] = -18'd20557;
assign mem2_r[116] = -18'd62714;
assign mem2_i[116] = -18'd19024;
assign mem2_r[117] = -18'd63162;
assign mem2_i[117] = -18'd17479;
assign mem2_r[118] = -18'd63572;
assign mem2_i[118] = -18'd15924;
assign mem2_r[119] = -18'd63944;
assign mem2_i[119] = -18'd14359;
assign mem2_r[120] = -18'd64277;
assign mem2_i[120] = -18'd12785;
assign mem2_r[121] = -18'd64571;
assign mem2_i[121] = -18'd11204;
assign mem2_r[122] = -18'd64827;
assign mem2_i[122] = -18'd9616;
assign mem2_r[123] = -18'd65043;
assign mem2_i[123] = -18'd8022;
assign mem2_r[124] = -18'd65220;
assign mem2_i[124] = -18'd6424;
assign mem2_r[125] = -18'd65358;
assign mem2_i[125] = -18'd4821;
assign mem2_r[126] = -18'd65457;
assign mem2_i[126] = -18'd3216;
assign mem2_r[127] = -18'd65516;
assign mem2_i[127] = -18'd1608;
assign mem2_r[128] = -18'd65536;
assign mem2_i[128] = 18'd0;
assign mem2_r[129] = -18'd65516;
assign mem2_i[129] = 18'd1608;
assign mem2_r[130] = -18'd65457;
assign mem2_i[130] = 18'd3216;
assign mem2_r[131] = -18'd65358;
assign mem2_i[131] = 18'd4821;
assign mem2_r[132] = -18'd65220;
assign mem2_i[132] = 18'd6424;
assign mem2_r[133] = -18'd65043;
assign mem2_i[133] = 18'd8022;
assign mem2_r[134] = -18'd64827;
assign mem2_i[134] = 18'd9616;
assign mem2_r[135] = -18'd64571;
assign mem2_i[135] = 18'd11204;
assign mem2_r[136] = -18'd64277;
assign mem2_i[136] = 18'd12785;
assign mem2_r[137] = -18'd63944;
assign mem2_i[137] = 18'd14359;
assign mem2_r[138] = -18'd63572;
assign mem2_i[138] = 18'd15924;
assign mem2_r[139] = -18'd63162;
assign mem2_i[139] = 18'd17479;
assign mem2_r[140] = -18'd62714;
assign mem2_i[140] = 18'd19024;
assign mem2_r[141] = -18'd62228;
assign mem2_i[141] = 18'd20557;
assign mem2_r[142] = -18'd61705;
assign mem2_i[142] = 18'd22078;
assign mem2_r[143] = -18'd61145;
assign mem2_i[143] = 18'd23586;
assign mem2_r[144] = -18'd60547;
assign mem2_i[144] = 18'd25080;
assign mem2_r[145] = -18'd59914;
assign mem2_i[145] = 18'd26558;
assign mem2_r[146] = -18'd59244;
assign mem2_i[146] = 18'd28020;
assign mem2_r[147] = -18'd58538;
assign mem2_i[147] = 18'd29466;
assign mem2_r[148] = -18'd57798;
assign mem2_i[148] = 18'd30893;
assign mem2_r[149] = -18'd57022;
assign mem2_i[149] = 18'd32303;
assign mem2_r[150] = -18'd56212;
assign mem2_i[150] = 18'd33692;
assign mem2_r[151] = -18'd55368;
assign mem2_i[151] = 18'd35062;
assign mem2_r[152] = -18'd54491;
assign mem2_i[152] = 18'd36410;
assign mem2_r[153] = -18'd53581;
assign mem2_i[153] = 18'd37736;
assign mem2_r[154] = -18'd52639;
assign mem2_i[154] = 18'd39040;
assign mem2_r[155] = -18'd51665;
assign mem2_i[155] = 18'd40320;
assign mem2_r[156] = -18'd50660;
assign mem2_i[156] = 18'd41576;
assign mem2_r[157] = -18'd49624;
assign mem2_i[157] = 18'd42806;
assign mem2_r[158] = -18'd48559;
assign mem2_i[158] = 18'd44011;
assign mem2_r[159] = -18'd47464;
assign mem2_i[159] = 18'd45190;
assign mem2_r[160] = -18'd46341;
assign mem2_i[160] = 18'd46341;
assign mem2_r[161] = -18'd45190;
assign mem2_i[161] = 18'd47464;
assign mem2_r[162] = -18'd44011;
assign mem2_i[162] = 18'd48559;
assign mem2_r[163] = -18'd42806;
assign mem2_i[163] = 18'd49624;
assign mem2_r[164] = -18'd41576;
assign mem2_i[164] = 18'd50660;
assign mem2_r[165] = -18'd40320;
assign mem2_i[165] = 18'd51665;
assign mem2_r[166] = -18'd39040;
assign mem2_i[166] = 18'd52639;
assign mem2_r[167] = -18'd37736;
assign mem2_i[167] = 18'd53581;
assign mem2_r[168] = -18'd36410;
assign mem2_i[168] = 18'd54491;
assign mem2_r[169] = -18'd35062;
assign mem2_i[169] = 18'd55368;
assign mem2_r[170] = -18'd33692;
assign mem2_i[170] = 18'd56212;
assign mem2_r[171] = -18'd32303;
assign mem2_i[171] = 18'd57022;
assign mem2_r[172] = -18'd30893;
assign mem2_i[172] = 18'd57798;
assign mem2_r[173] = -18'd29466;
assign mem2_i[173] = 18'd58538;
assign mem2_r[174] = -18'd28020;
assign mem2_i[174] = 18'd59244;
assign mem2_r[175] = -18'd26558;
assign mem2_i[175] = 18'd59914;
assign mem2_r[176] = -18'd25080;
assign mem2_i[176] = 18'd60547;
assign mem2_r[177] = -18'd23586;
assign mem2_i[177] = 18'd61145;
assign mem2_r[178] = -18'd22078;
assign mem2_i[178] = 18'd61705;
assign mem2_r[179] = -18'd20557;
assign mem2_i[179] = 18'd62228;
assign mem2_r[180] = -18'd19024;
assign mem2_i[180] = 18'd62714;
assign mem2_r[181] = -18'd17479;
assign mem2_i[181] = 18'd63162;
assign mem2_r[182] = -18'd15924;
assign mem2_i[182] = 18'd63572;
assign mem2_r[183] = -18'd14359;
assign mem2_i[183] = 18'd63944;
assign mem2_r[184] = -18'd12785;
assign mem2_i[184] = 18'd64277;
assign mem2_r[185] = -18'd11204;
assign mem2_i[185] = 18'd64571;
assign mem2_r[186] = -18'd9616;
assign mem2_i[186] = 18'd64827;
assign mem2_r[187] = -18'd8022;
assign mem2_i[187] = 18'd65043;
assign mem2_r[188] = -18'd6424;
assign mem2_i[188] = 18'd65220;
assign mem2_r[189] = -18'd4821;
assign mem2_i[189] = 18'd65358;
assign mem2_r[190] = -18'd3216;
assign mem2_i[190] = 18'd65457;
assign mem2_r[191] = -18'd1608;
assign mem2_i[191] = 18'd65516;
assign mem2_r[192] = 18'd0;
assign mem2_i[192] = 18'd65536;
assign mem2_r[193] = 18'd1608;
assign mem2_i[193] = 18'd65516;
assign mem2_r[194] = 18'd3216;
assign mem2_i[194] = 18'd65457;
assign mem2_r[195] = 18'd4821;
assign mem2_i[195] = 18'd65358;
assign mem2_r[196] = 18'd6424;
assign mem2_i[196] = 18'd65220;
assign mem2_r[197] = 18'd8022;
assign mem2_i[197] = 18'd65043;
assign mem2_r[198] = 18'd9616;
assign mem2_i[198] = 18'd64827;
assign mem2_r[199] = 18'd11204;
assign mem2_i[199] = 18'd64571;
assign mem2_r[200] = 18'd12785;
assign mem2_i[200] = 18'd64277;
assign mem2_r[201] = 18'd14359;
assign mem2_i[201] = 18'd63944;
assign mem2_r[202] = 18'd15924;
assign mem2_i[202] = 18'd63572;
assign mem2_r[203] = 18'd17479;
assign mem2_i[203] = 18'd63162;
assign mem2_r[204] = 18'd19024;
assign mem2_i[204] = 18'd62714;
assign mem2_r[205] = 18'd20557;
assign mem2_i[205] = 18'd62228;
assign mem2_r[206] = 18'd22078;
assign mem2_i[206] = 18'd61705;
assign mem2_r[207] = 18'd23586;
assign mem2_i[207] = 18'd61145;
assign mem2_r[208] = 18'd25080;
assign mem2_i[208] = 18'd60547;
assign mem2_r[209] = 18'd26558;
assign mem2_i[209] = 18'd59914;
assign mem2_r[210] = 18'd28020;
assign mem2_i[210] = 18'd59244;
assign mem2_r[211] = 18'd29466;
assign mem2_i[211] = 18'd58538;
assign mem2_r[212] = 18'd30893;
assign mem2_i[212] = 18'd57798;
assign mem2_r[213] = 18'd32303;
assign mem2_i[213] = 18'd57022;
assign mem2_r[214] = 18'd33692;
assign mem2_i[214] = 18'd56212;
assign mem2_r[215] = 18'd35062;
assign mem2_i[215] = 18'd55368;
assign mem2_r[216] = 18'd36410;
assign mem2_i[216] = 18'd54491;
assign mem2_r[217] = 18'd37736;
assign mem2_i[217] = 18'd53581;
assign mem2_r[218] = 18'd39040;
assign mem2_i[218] = 18'd52639;
assign mem2_r[219] = 18'd40320;
assign mem2_i[219] = 18'd51665;
assign mem2_r[220] = 18'd41576;
assign mem2_i[220] = 18'd50660;
assign mem2_r[221] = 18'd42806;
assign mem2_i[221] = 18'd49624;
assign mem2_r[222] = 18'd44011;
assign mem2_i[222] = 18'd48559;
assign mem2_r[223] = 18'd45190;
assign mem2_i[223] = 18'd47464;
assign mem2_r[224] = 18'd46341;
assign mem2_i[224] = 18'd46341;
assign mem2_r[225] = 18'd47464;
assign mem2_i[225] = 18'd45190;
assign mem2_r[226] = 18'd48559;
assign mem2_i[226] = 18'd44011;
assign mem2_r[227] = 18'd49624;
assign mem2_i[227] = 18'd42806;
assign mem2_r[228] = 18'd50660;
assign mem2_i[228] = 18'd41576;
assign mem2_r[229] = 18'd51665;
assign mem2_i[229] = 18'd40320;
assign mem2_r[230] = 18'd52639;
assign mem2_i[230] = 18'd39040;
assign mem2_r[231] = 18'd53581;
assign mem2_i[231] = 18'd37736;
assign mem2_r[232] = 18'd54491;
assign mem2_i[232] = 18'd36410;
assign mem2_r[233] = 18'd55368;
assign mem2_i[233] = 18'd35062;
assign mem2_r[234] = 18'd56212;
assign mem2_i[234] = 18'd33692;
assign mem2_r[235] = 18'd57022;
assign mem2_i[235] = 18'd32303;
assign mem2_r[236] = 18'd57798;
assign mem2_i[236] = 18'd30893;
assign mem2_r[237] = 18'd58538;
assign mem2_i[237] = 18'd29466;
assign mem2_r[238] = 18'd59244;
assign mem2_i[238] = 18'd28020;
assign mem2_r[239] = 18'd59914;
assign mem2_i[239] = 18'd26558;
assign mem2_r[240] = 18'd60547;
assign mem2_i[240] = 18'd25080;
assign mem2_r[241] = 18'd61145;
assign mem2_i[241] = 18'd23586;
assign mem2_r[242] = 18'd61705;
assign mem2_i[242] = 18'd22078;
assign mem2_r[243] = 18'd62228;
assign mem2_i[243] = 18'd20557;
assign mem2_r[244] = 18'd62714;
assign mem2_i[244] = 18'd19024;
assign mem2_r[245] = 18'd63162;
assign mem2_i[245] = 18'd17479;
assign mem2_r[246] = 18'd63572;
assign mem2_i[246] = 18'd15924;
assign mem2_r[247] = 18'd63944;
assign mem2_i[247] = 18'd14359;
assign mem2_r[248] = 18'd64277;
assign mem2_i[248] = 18'd12785;
assign mem2_r[249] = 18'd64571;
assign mem2_i[249] = 18'd11204;
assign mem2_r[250] = 18'd64827;
assign mem2_i[250] = 18'd9616;
assign mem2_r[251] = 18'd65043;
assign mem2_i[251] = 18'd8022;
assign mem2_r[252] = 18'd65220;
assign mem2_i[252] = 18'd6424;
assign mem2_r[253] = 18'd65358;
assign mem2_i[253] = 18'd4821;
assign mem2_r[254] = 18'd65457;
assign mem2_i[254] = 18'd3216;
assign mem2_r[255] = 18'd65516;
assign mem2_i[255] = 18'd1608;




endmodule