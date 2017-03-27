`timescale 1 ns / 1 ns
module mrd_rdx2345_v2_tb (

	);

reg clk;    // Clock
reg rst_n;  // Asynchronous reset active low

logic in_val;
logic signed [18-1:0] din_real [0:4];
logic signed [18-1:0] din_imag [0:4];

logic unsigned [1:0] margin_in = 2'b00;
logic unsigned [3:0] exp_in = 3'b0000;

logic out_val;
logic signed [18-1:0] dout_real [0:4];
logic signed [18-1:0] dout_imag [0:4];  
logic unsigned [3:0] exp_out;

logic out_val_53;
logic signed [18-1:0] dout_real_53 [0:4];
logic signed [18-1:0] dout_imag_53 [0:4];  
logic unsigned [3:0] exp_out_53;

initial	begin
	rst_n = 0;
	clk = 0;

	# 100 rst_n = 1'b1;
end

always # 5 clk = ~clk; //100M


// PN 23  [23 18 0]
logic [22:0]   x;
logic [9:0]  cnt;
integer j;
always@(posedge clk) 
begin
	if (!rst_n)
	begin
		x <= 23'h05555;
		cnt <= 0;
		in_val <= 0;
		// for (j=0; j<=4; j++) begin
		// 	din_real[j] <= 0;
		// 	din_imag[j] <= 0;
		// end
	end
	else begin
		x[0] <= x[4] ^ x[22];
		x[22:1] <= x[21:0];

		cnt <= (cnt[8:5]==4'd12)? 0 : cnt + 1;
		// din_real[0] <= (cnt[8:5]==4'd1)? {{4{x[17]}},x[13:0]} : din_real[0];
		// din_imag[0] <= (cnt[8:5]==4'd2)? {{4{x[17]}},x[13:0]} : din_imag[0];
		// din_real[1] <= (cnt[8:5]==4'd3)? {{4{x[17]}},x[13:0]} : din_real[1];
		// din_imag[1] <= (cnt[8:5]==4'd4)? {{4{x[17]}},x[13:0]} : din_imag[1];
		// din_real[2] <= (cnt[8:5]==4'd5)? {{4{x[17]}},x[13:0]} : din_real[2];
		// din_imag[2] <= (cnt[8:5]==4'd6)? {{4{x[17]}},x[13:0]} : din_imag[2];
		// din_real[3] <= (cnt[8:5]==4'd7)? {{4{x[17]}},x[13:0]} : din_real[3];
		// din_imag[3] <= (cnt[8:5]==4'd8)? {{4{x[17]}},x[13:0]} : din_imag[3];
		// din_real[4] <= (cnt[8:5]==4'd9)? {{4{x[17]}},x[13:0]} : din_real[4];
		// din_imag[4] <= (cnt[8:5]==4'd10)? {{4{x[17]}},x[13:0]} : din_imag[4];

		// din_real[0] <= 18'sh1ffff;
		// din_imag[0] <= 18'sh00000;
		// din_real[1] <= 18'sh30000;
		// din_imag[1] <= 18'sh1ffff;
		// din_real[2] <= 18'sh30000;
		// din_imag[2] <= 18'sh20000;

		in_val <= (cnt[8:5]==4'd11) & (cnt[4:0]==5'd1);
	end
end

reg [31:0] state=32'h12345678;
function logic [31:0] my_random;
	logic [63:0] s64;
	s64=state * state;
	state = (s64>>16) + state;
	my_random = state;
endfunction

always@(posedge clk) 
begin
	if (!rst_n)
	begin
		for (j=0; j<=4; j++) begin
			din_real[j] <= 0;
			din_imag[j] <= 0;
		end
	end
	else begin
		din_real[0] <= $signed(my_random[17:0]) >>> 3;
		din_real[1] <= $signed(my_random[17:0]) >>> 3;
		din_real[2] <= $signed(my_random[17:0]) >>> 3;
		din_real[3] <= $signed(my_random[17:0]) >>> 3;
		din_real[4] <= $signed(my_random[17:0]) >>> 3;
		din_imag[0] <= $signed(my_random[17:0]) >>> 3;
		din_imag[1] <= $signed(my_random[17:0]) >>> 3;
		din_imag[2] <= $signed(my_random[17:0]) >>> 3;
		din_imag[3] <= $signed(my_random[17:0]) >>> 3;
		din_imag[4] <= $signed(my_random[17:0]) >>> 3;
	end
end


// mrd_rdx4_2_v2  
// mrd_rdx4_2_v2_inst 
// 	(
// 	clk,    
// 	rst_n,

// 	in_val,
// 	din_real,
// 	din_imag,
// 	3'd4,

// 	margin_in,
// 	exp_in,

// 	out_val,
// 	dout_real,
// 	dout_imag,  
// 	exp_out
// );

// mrd_rdx5_v2  
// mrd_rdx5_v2_inst 
// 	(
// 	clk,    
// 	rst_n,

// 	in_val,
// 	din_real,
// 	din_imag,

// 	margin_in,
// 	exp_in,

// 	out_val,
// 	dout_real,
// 	dout_imag,  
// 	exp_out
// );

mrd_rdx3_v2  
mrd_rdx3_v2_inst 
	(
	clk,    
	rst_n,

	in_val,
	din_real,
	din_imag,

	margin_in,
	exp_in,

	out_val,
	dout_real,
	dout_imag,  
	exp_out
);

mrd_rdx5_3_4_2_v2  
mrd_rdx5_3_4_2_v2_inst 
	(
	clk,    
	rst_n,

	in_val,
	din_real,
	din_imag,
	3'd3,

	margin_in,
	exp_in,

	out_val_53,
	dout_real_53,
	dout_imag_53,  
	exp_out_53
);

logic out_val_2;
logic signed [29:0] din_real_2 [0:4];
logic signed [29:0] din_imag_2 [0:4];
logic signed [29:0] dout_real_2 [0:4];
logic signed [29:0] dout_imag_2 [0:4];
assign din_real_2[0] = { {12{din_real[0][17]}}, din_real[0]};
assign din_real_2[1] = { {12{din_real[1][17]}}, din_real[1]};
assign din_real_2[2] = { {12{din_real[2][17]}}, din_real[2]};
assign din_real_2[3] = { {12{din_real[3][17]}}, din_real[3]};
assign din_real_2[4] = { {12{din_real[4][17]}}, din_real[4]};
assign din_imag_2[0] = { {12{din_imag[0][17]}}, din_imag[0]};
assign din_imag_2[1] = { {12{din_imag[1][17]}}, din_imag[1]};
assign din_imag_2[2] = { {12{din_imag[2][17]}}, din_imag[2]};
assign din_imag_2[3] = { {12{din_imag[3][17]}}, din_imag[3]};
assign din_imag_2[4] = { {12{din_imag[4][17]}}, din_imag[4]};
mrd_dft_rdx4  #(
	.wDataInOut (30)
	)
mrd_dft_rdx4_inst
	(
	clk,    
	rst_n,

	in_val,
	din_real_2,
	din_imag_2,

	out_val_2,
	dout_real_2,
	dout_imag_2  
);

endmodule