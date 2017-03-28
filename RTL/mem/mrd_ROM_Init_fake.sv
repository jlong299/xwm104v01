module mrd_ROM_Init_fake (
	input clk,

	input [6:0]  rdaddr,

	output logic [63:0] q
);

logic [63:0]  mem [0:67];

always@(posedge clk)
begin
	q <= mem[rdaddr];
end


assign mem[0]  = 64'd1315484745740;
assign mem[1]  = 64'd5726601294;
assign mem[2]  = 64'd1813700968472;
assign mem[3]  = 64'd2863268098;
assign mem[4]  = 64'd1882420461604;
assign mem[5]  = 64'd1908867150;
assign mem[6]  = 64'd1951139954736;
assign mem[7]  = 64'd1431634190;
assign mem[8]  = 64'd2019859382332;
assign mem[9]  = 64'd1145307407;
assign mem[10] = 64'd2365604331592;
assign mem[11] = 64'd954401410;
assign mem[12] = 64'd2494453383264;
assign mem[13] = 64'd715785220;
assign mem[14] = 64'd2434323857516;
assign mem[15] = 64'd636289102;
assign mem[16] = 64'd2382784135288;
assign mem[17] = 64'd572653827;
assign mem[18] = 64'd2503043383440;
assign mem[19] = 64'd477169422;
assign mem[20] = 64'd2571762712756;
assign mem[21] = 64'd381748431;
assign mem[22] = 64'd2511633383616;
assign mem[23] = 64'd357893134;
assign mem[24] = 64'd2915628777688;
assign mem[25] = 64'd318113538;
assign mem[26] = 64'd2520223121648;
assign mem[27] = 64'd286327055;
assign mem[28] = 64'd3044477894944;
assign mem[29] = 64'd238555140;
assign mem[30] = 64'd2588942614828;
assign mem[31] = 64'd229049551;
assign mem[32] = 64'd2984348401988;
assign mem[33] = 64'd212076302;
assign mem[34] = 64'd2932808450408;
assign mem[35] = 64'd190844931;
assign mem[36] = 64'd3060584153472;
assign mem[37] = 64'd178917382;
assign mem[38] = 64'd3053068026288;
assign mem[39] = 64'd159057678;
assign mem[40] = 64'd3046625116640;
assign mem[41] = 64'd143134725;
assign mem[42] = 64'd3121787060764;
assign mem[43] = 64'd127212367;
assign mem[44] = 64'd3061658157632;
assign mem[45] = 64'd119279630;
assign mem[46] = 64'd2934955999832;
assign mem[47] = 64'd114497411;
assign mem[48] = 64'd3465418736264;
assign mem[49] = 64'd106039042;
assign mem[50] = 64'd3070247502544;
assign mem[51] = 64'd95424527;
assign mem[52] = 64'd3062732161792;
assign mem[53] = 64'd89460750;
assign mem[54] = 64'd3594268050272;
assign mem[55] = 64'd79503876;
assign mem[56] = 64'd3138967028612;
assign mem[57] = 64'd76350671;
assign mem[58] = 64'd3063805117376;
assign mem[59] = 64'd71569423;
assign mem[60] = 64'd3534138655692;
assign mem[61] = 64'd70659982;
assign mem[62] = 64'd3482598016056;
assign mem[63] = 64'd63585539;
assign mem[64] = 64'd3610374571136;
assign mem[65] = 64'd59641862;
assign mem[66] = 64'd3072395117744;
assign mem[67] = 64'd57228559;




endmodule