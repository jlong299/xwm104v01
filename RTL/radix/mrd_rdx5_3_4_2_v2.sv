module mrd_rdx5_3_4_2_v2  
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [18-1:0] din_real [0:4],
	input signed [18-1:0] din_imag [0:4],
	input [2:0] factor,
	input inverse,

	input unsigned [1:0] margin_in,
	input unsigned [3:0] exp_in,

	output logic out_val,
	output logic signed [18-1:0] dout_real [0:4],
	output logic signed [18-1:0] dout_imag [0:4], 
	output logic unsigned [3:0] exp_out
);

logic unsigned [1:0] worst_case_growth;
logic unsigned [1:0] word_growth;
logic [5:0] val_r;
logic signed [18-1:0] p1_x0_r, p1_x0_i; //1.17
logic signed [20-1:0] p1_x1_r, p1_x1_i; //3.17
logic signed [19-1:0] wir1_p1_x1_r, wir1_p1_x1_i, wir1_p1_x2_r, wir1_p1_x2_i, wir1_p1_x3_r, wir1_p1_x3_i, wir1_p1_x4_r, wir1_p1_x4_i;
wire signed [20-1:0] wir2_p1_x1_r, wir2_p1_x1_i, wir2_p1_x2_r, wir2_p1_x2_i, wir2_p1_x5_r, wir2_p1_x5_i;
logic signed [18-1:0] p1_x2_r, p1_x2_i, p1_x5_r, p1_x5_i; //3.15
logic signed [18-1:0] p1_x3_r, p1_x3_i, p1_x4_r, p1_x4_i; //2.16

logic signed [18-1:0] din_real_0_r, din_imag_0_r;

assign worst_case_growth = (factor==3'd5 || factor==3'd4)? 2'd3 : 2'd2;

//---------- 1st pipeline -------------
logic signed [18-1:0] din_real_t [0:4];
logic signed [18-1:0] din_imag_t [0:4]; 
always@(*) begin
	case (factor)
	3'd5 : begin
		din_real_t[0] = din_real[0];
		din_imag_t[0] = din_imag[0];
		din_real_t[1] = din_real[1];
		din_imag_t[1] = din_imag[1];
		din_real_t[2] = din_real[2];
		din_imag_t[2] = din_imag[2];
		din_real_t[3] = din_real[4];
		din_imag_t[3] = din_imag[4];
		din_real_t[4] = din_real[3];
		din_imag_t[4] = din_imag[3];
	end
	3'd3 : begin
		din_real_t[0] = din_real[0];
		din_imag_t[0] = din_imag[0];
		din_real_t[1] = din_real[1];
		din_imag_t[1] = din_imag[1];
		din_real_t[2] = din_real[2];
		din_imag_t[2] = din_imag[2];
		din_real_t[3] = 0;
		din_imag_t[3] = 0;
		din_real_t[4] = 0;
		din_imag_t[4] = 0;
	end
	3'd4 : begin
		din_real_t[0] = 0;
		din_imag_t[0] = 0;
		din_real_t[1] = din_real[0];
		din_imag_t[1] = din_imag[0];
		din_real_t[2] = din_real[1];
		din_imag_t[2] = din_imag[1];
		din_real_t[3] = din_real[2];
		din_imag_t[3] = din_imag[2];
		din_real_t[4] = din_real[3];
		din_imag_t[4] = din_imag[3];
	end
	3'd2 : begin
		din_real_t[0] = 0;
		din_imag_t[0] = 0;
		din_real_t[1] = din_real[0];
		din_imag_t[1] = din_imag[0];
		din_real_t[2] = din_real[2];
		din_imag_t[2] = din_imag[2];
		din_real_t[3] = din_real[1];
		din_imag_t[3] = din_imag[1];
		din_real_t[4] = din_real[3];
		din_imag_t[4] = din_imag[3];
	end
	default : begin
		din_real_t = din_real;
		din_imag_t = din_imag;
	end
	endcase
end

always@(posedge clk) begin
	wir1_p1_x1_r <= din_real_t[1] + din_real_t[3];
	wir1_p1_x1_i <= din_imag_t[1] + din_imag_t[3];
	wir1_p1_x2_r <= din_real_t[2] + din_real_t[4];
	wir1_p1_x2_i <= din_imag_t[2] + din_imag_t[4];

	wir1_p1_x3_r <= din_real_t[1] - din_real_t[3];
	wir1_p1_x3_i <= din_imag_t[1] - din_imag_t[3];

	wir1_p1_x4_r <= din_real_t[2] - din_real_t[4];
	wir1_p1_x4_i <= din_imag_t[2] - din_imag_t[4];

	din_real_0_r <= din_real_t[0];
	din_imag_0_r <= din_imag_t[0];
end

//---------- 1st+1 pipeline -------------
assign wir2_p1_x1_r = wir1_p1_x1_r + wir1_p1_x2_r;

assign wir2_p1_x2_r = (factor==3'd5)? wir1_p1_x1_r - wir1_p1_x2_r : -wir1_p1_x1_r + wir1_p1_x2_r;

assign wir2_p1_x5_r = wir1_p1_x3_r + wir1_p1_x4_r;
assign wir2_p1_x1_i = wir1_p1_x1_i + wir1_p1_x2_i;

assign wir2_p1_x2_i = (factor==3'd5)? wir1_p1_x1_i - wir1_p1_x2_i : -wir1_p1_x1_i + wir1_p1_x2_i;

assign wir2_p1_x5_i = wir1_p1_x3_i + wir1_p1_x4_i;

integer j;
always@(posedge clk)
begin
	if (!rst_n) begin
		p1_x0_r <= 0;
		p1_x0_i <= 0;
		p1_x1_r <= 0;
		p1_x1_i <= 0;
		p1_x2_r <= 0;
		p1_x2_i <= 0;
		p1_x5_r <= 0;
		p1_x5_i <= 0;
		p1_x3_r <= 0;
		p1_x3_i <= 0;
		p1_x4_r <= 0;
		p1_x4_i <= 0;
	end
	else begin
		p1_x0_r <= din_real_0_r;
		p1_x0_i <= din_imag_0_r;
		p1_x1_r <= wir2_p1_x1_r;
		p1_x1_i <= wir2_p1_x1_i;

		if (factor==3'd5) begin
		p1_x2_r <= (wir2_p1_x2_r[1])? wir2_p1_x2_r[19:2]+2'sd1 : wir2_p1_x2_r[19:2];
		p1_x2_i <= (wir2_p1_x2_i[1])? wir2_p1_x2_i[19:2]+2'sd1 : wir2_p1_x2_i[19:2];
		end
		else begin // factor==3
		p1_x2_r <= (wir2_p1_x2_r[0])? wir2_p1_x2_r[18:1]+2'sd1 : wir2_p1_x2_r[18:1];
		p1_x2_i <= (wir2_p1_x2_i[0])? wir2_p1_x2_i[18:1]+2'sd1 : wir2_p1_x2_i[18:1];
		end

		p1_x5_r <= (wir2_p1_x5_r[1])? wir2_p1_x5_r[19:2]+2'sd1 : wir2_p1_x5_r[19:2];
		p1_x5_i <= (wir2_p1_x5_i[1])? wir2_p1_x5_i[19:2]+2'sd1 : wir2_p1_x5_i[19:2];
		p1_x3_r <= (wir1_p1_x3_r[0])? wir1_p1_x3_r[18:1]+2'sd1 : wir1_p1_x3_r[18:1];
		p1_x3_i <= (wir1_p1_x3_i[0])? wir1_p1_x3_i[18:1]+2'sd1 : wir1_p1_x3_i[18:1];
		p1_x4_r <= (wir1_p1_x4_r[0])? wir1_p1_x4_r[18:1]+2'sd1 : wir1_p1_x4_r[18:1];
		p1_x4_i <= (wir1_p1_x4_i[0])? wir1_p1_x4_i[18:1]+2'sd1 : wir1_p1_x4_i[18:1];
	end
end

logic signed [18-1:0] p1r_x0_r, p1r_x0_i; //1.17
logic signed [20-1:0] p1r_x1_r, p1r_x1_i; //3.17
// logic signed [18-1:0] p1r_x2_r, p1r_x2_i, p1r_x5_r, p1r_x5_i; //3.15
// logic signed [18-1:0] p1r_x3_r, p1r_x3_i, p1r_x4_r, p1r_x4_i; //2.16

//---------- 2nd+1 pipeline -------------
//--- Input Registers for DSP Mult ---------
always@(posedge clk) begin
	p1r_x0_r <= p1_x0_r;
	p1r_x0_i <= p1_x0_i;
	p1r_x1_r <= p1_x1_r;
	p1r_x1_i <= p1_x1_i;
	// p1r_x2_r <= p1_x2_r;
	// p1r_x2_i <= p1_x2_i;
	// p1r_x3_i <= p1_x3_i;
	// p1r_x3_r <= p1_x3_r;
	// p1r_x4_i <= p1_x4_i;
	// p1r_x4_r <= p1_x4_r;
	// p1r_x5_i <= p1_x5_i;
	// p1r_x5_r <= p1_x5_r;
end

//---------- 3rd+1 pipeline -------------
logic signed [21-1:0] p2_x0_r, p2_x0_i; //4.17
logic signed [23-1:0] p2_x1_r, p2_x1_i; //4.19
wire signed [20-1:0] wir1_p2_x0_r, wir1_p2_x0_i;
logic signed [22-1:0] wir1_p2_x1_r, wir1_p2_x1_i;
// wire signed [36-1:0] wir1_p2_x2_r, wir1_p2_x2_i;
// wire signed [36-1:0] wir1_p2_x3_r, wir1_p2_x3_i;
// wire signed [36-1:0] wir1_p2_x4_r, wir1_p2_x4_i;
// wire signed [36-1:0] wir1_p2_x5_r, wir1_p2_x5_i;

logic signed [36-1:0] p2_x2_r, p2_x2_i, p2_x3_r, p2_x3_i, p2_x4_r, p2_x4_i, p2_x5_r, p2_x5_i; //4.20

assign wir1_p2_x0_r = {p1r_x0_r, 2'b00};
assign wir1_p2_x0_i = {p1r_x0_i, 2'b00};

always@(*) begin
	if (factor==3'd5) begin
		wir1_p2_x1_r = {p1r_x1_r[19], p1r_x1_r[19], p1r_x1_r};
		wir1_p2_x1_i = {p1r_x1_i[19], p1r_x1_i[19], p1r_x1_i};
	end
	else begin// factor==3
		wir1_p2_x1_r = {p1r_x1_r[19], p1r_x1_r, 1'b0};
		wir1_p2_x1_i = {p1r_x1_i[19], p1r_x1_i, 1'b0};
	end
end

logic signed [18-1:0]  coeff [2:5];
logic signed [18-1:0]  coeff2_n, coeff3_n, coeff4_n, coeff5_n;
always@(posedge clk) begin
	if (!rst_n) begin
		coeff[2] <= 0;
		coeff[3] <= 0;
		coeff[4] <= 0;
		coeff[5] <= 0;
		coeff2_n <= 0;
		coeff3_n <= 0;
		coeff4_n <= 0;
		coeff5_n <= 0;
	end
	else begin
		// FFT
		if (factor==3'd5) begin
			// FFT and IFFT
			coeff[2] <= 18'sh11E37 ; //1.17
			coeff2_n <= 18'sh11E37 ; //1.17
		end
		else begin// factor == 3
			if (inverse == 1'b0) begin // FFT
				coeff[2] <= 18'sh1BB68 ; //1.17
				coeff2_n <= -18'sh1BB68;
			end
			else begin	// IFFT
				coeff[2] <= -18'sh1BB68 ; //1.17
				coeff2_n <= 18'sh1BB68;
			end
		end

		if (inverse == 1'b0) begin// FFT
			coeff[3] <= 18'sh2760E ; //2.16
			coeff3_n <= -18'sh2760E;
			coeff[4] <= 18'sh34601 ; //1.17
			coeff4_n <= -18'sh34601 ; //1.17
			coeff[5] <= 18'sh1E6F1 ; //1.17
			coeff5_n <= -18'sh1E6F1 ; //1.17
		end
		else begin	// IFFT
			coeff[3] <= -18'sh2760E ; //2.16
			coeff3_n <= 18'sh2760E;
			coeff[4] <= -18'sh34601 ; //1.17
			coeff4_n <= 18'sh34601 ; //1.17
			coeff[5] <= -18'sh1E6F1 ; //1.17
			coeff5_n <= 18'sh1E6F1 ; //1.17
		end
	end

end

// assign wir1_p2_x2_r = p1r_x2_r * coeff[2]; //1.17
// assign wir1_p2_x2_i = p1r_x2_i * coeff2_n;
// assign wir1_p2_x3_r = p1r_x3_i * coeff3_n; //2.16
// assign wir1_p2_x3_i = p1r_x3_r * coeff[3];
// assign wir1_p2_x4_r = p1r_x4_i * coeff4_n; //1.17
// assign wir1_p2_x4_i = p1r_x4_r * coeff[4];
// assign wir1_p2_x5_r = p1r_x5_i * coeff5_n ; //1.17
// assign wir1_p2_x5_i = p1r_x5_r * coeff[5] ;

lpm_mult_18_mrd u0 (
	.dataa  (p1_x2_r),  //  mult_input.dataa
	.datab  (coeff[2]),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x2_r)  // mult_output.result
);
lpm_mult_18_mrd u1 (
	.dataa  (p1_x2_i),  //  mult_input.dataa
	.datab  (coeff2_n),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x2_i)  // mult_output.result
);
lpm_mult_18_mrd u2 (
	.dataa  (p1_x3_i),  //  mult_input.dataa
	.datab  (coeff3_n),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x3_r)  // mult_output.result
);
lpm_mult_18_mrd u3 (
	.dataa  (p1_x3_r),  //  mult_input.dataa
	.datab  (coeff[3]),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x3_i)  // mult_output.result
);
lpm_mult_18_mrd u4 (
	.dataa  (p1_x4_i),  //  mult_input.dataa
	.datab  (coeff4_n),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x4_r)  // mult_output.result
);
lpm_mult_18_mrd u5 (
	.dataa  (p1_x4_r),  //  mult_input.dataa
	.datab  (coeff[4]),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x4_i)  // mult_output.result
);
lpm_mult_18_mrd u6 (
	.dataa  (p1_x5_i),  //  mult_input.dataa
	.datab  (coeff5_n),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x5_r)  // mult_output.result
);
lpm_mult_18_mrd u7 (
	.dataa  (p1_x5_r),  //  mult_input.dataa
	.datab  (coeff[5]),  //            .datab
	.clock  (clk),  //            .clock
	.result (p2_x5_i)  // mult_output.result
);

always@(posedge clk)
begin
	if (!rst_n) begin
		p2_x0_r <= 0;
		p2_x0_i <= 0;
		p2_x1_r <= 0;
		p2_x1_i <= 0;

		// p2_x2_r <= 0;
		// p2_x2_i <= 0;
		// p2_x3_r <= 0;
		// p2_x3_i <= 0;
		// p2_x4_r <= 0;
		// p2_x4_i <= 0;
		// p2_x5_r <= 0;
		// p2_x5_i <= 0;
	end
	else begin
		p2_x0_r <= p1r_x0_r + p1r_x1_r;
		p2_x0_i <= p1r_x0_i + p1r_x1_i;
		p2_x1_r <= wir1_p2_x0_r - wir1_p2_x1_r;
		p2_x1_i <= wir1_p2_x0_i - wir1_p2_x1_i;
		// p2_x2_r <= wir1_p2_x2_r;
		// p2_x2_i <= wir1_p2_x2_i;
		// p2_x3_r <= wir1_p2_x3_r;
		// p2_x3_i <= wir1_p2_x3_i;
		// p2_x4_r <= wir1_p2_x4_r;
		// p2_x4_i <= wir1_p2_x4_i;
		// p2_x5_r <= wir1_p2_x5_r;
		// p2_x5_i <= wir1_p2_x5_i;
	end
end



//---------- 4th+1 pipeline -------------
logic signed [24-1:0] wir_p2_x2_r, wir_p2_x2_i, wir_p2_x3_r, wir_p2_x3_i, 
       wir_p2_x4_r, wir_p2_x4_i, wir_p2_x5_r, wir_p2_x5_i; //4.20

always@(*) begin
	if (factor==3'd5) begin
		wir_p2_x2_r = p2_x2_r[35:12];
		wir_p2_x2_i = p2_x2_i[35:12];
	end
	else begin
		wir_p2_x2_r = {p2_x2_i[35],p2_x2_i[35:13]};
		wir_p2_x2_i = {p2_x2_r[35],p2_x2_r[35:13]};
	end
end

assign wir_p2_x3_r = p2_x3_r[35:12];
assign wir_p2_x3_i = p2_x3_i[35:12];
assign wir_p2_x4_r = {p2_x4_r[35],p2_x4_r[35:13]};
assign wir_p2_x4_i = {p2_x4_i[35],p2_x4_i[35:13]};
assign wir_p2_x5_r = p2_x5_r[35:12];
assign wir_p2_x5_i = p2_x5_i[35:12];

logic signed [24-1:0] p3_x0_r, p3_x0_i, p3_x1_r, p3_x1_i, p3_x2_r, p3_x2_i,
               p3_x3_r, p3_x3_i, p3_x4_r, p3_x4_i;  //4.20
wire signed [24-1:0] wir0_p3_x1_r, wir0_p3_x1_i;               
logic signed [25-1:0] wir1_p3_x1_r, wir1_p3_x1_i, wir1_p3_x2_r, wir1_p3_x2_i, 
                     wir1_p3_x3_r, wir1_p3_x3_i, wir1_p3_x4_r, wir1_p3_x4_i;             
logic signed [25-1:0] wir2_p3_x1_r, wir2_p3_x1_i, wir2_p3_x2_r, wir2_p3_x2_i, 
                     wir2_p3_x3_r, wir2_p3_x3_i, wir2_p3_x4_r, wir2_p3_x4_i;         

assign wir0_p3_x1_r = {p2_x1_r,1'b0};
assign wir0_p3_x1_i = {p2_x1_i,1'b0};

// assign wir1_p3_x1_r = wir0_p3_x1_r + wir_p2_x2_r;
// assign wir1_p3_x1_i = wir0_p3_x1_i + wir_p2_x2_i;

// assign wir1_p3_x2_r = (factor==3'd5)? wir_p2_x4_r + wir_p2_x5_r : 0;
// assign wir1_p3_x2_i = (factor==3'd5)? wir_p2_x4_i + wir_p2_x5_i : 0;

// assign wir1_p3_x3_r = wir0_p3_x1_r - wir_p2_x2_r;
// assign wir1_p3_x3_i = wir0_p3_x1_i - wir_p2_x2_i;

// assign wir1_p3_x4_r = (factor==3'd5)? wir_p2_x3_r + wir_p2_x5_r : 0;
// assign wir1_p3_x4_i = (factor==3'd5)? wir_p2_x3_i + wir_p2_x5_i : 0;

logic signed [21-1:0] p2_x0_r_dly, p2_x0_i_dly; //4.17
always@(posedge clk) begin
	if (!rst_n) begin
		p2_x0_r_dly <= 0;
		p2_x0_i_dly <= 0;
		wir1_p3_x1_r <= 0;
		wir1_p3_x1_i <= 0;
		wir1_p3_x2_r <= 0;
		wir1_p3_x2_i <= 0;
		wir1_p3_x3_r <= 0;
		wir1_p3_x3_i <= 0;
		wir1_p3_x4_r <= 0;
		wir1_p3_x4_i <= 0;
	end
	else begin
	case (factor) 
		3'd5 : begin
			wir1_p3_x1_r <= wir0_p3_x1_r + wir_p2_x2_r;
			wir1_p3_x1_i <= wir0_p3_x1_i + wir_p2_x2_i;
			wir1_p3_x2_r <= wir_p2_x4_r + wir_p2_x5_r;
			wir1_p3_x2_i <= wir_p2_x4_i + wir_p2_x5_i;
			wir1_p3_x3_r <= wir0_p3_x1_r - wir_p2_x2_r;
			wir1_p3_x3_i <= wir0_p3_x1_i - wir_p2_x2_i;
			wir1_p3_x4_r <= wir_p2_x3_r + wir_p2_x5_r;
			wir1_p3_x4_i <= wir_p2_x3_i + wir_p2_x5_i;
		end
		3'd3 : begin
			wir1_p3_x1_r <= wir0_p3_x1_r + wir_p2_x2_r;
			wir1_p3_x1_i <= wir0_p3_x1_i + wir_p2_x2_i;
			wir1_p3_x2_r <= 0;
			wir1_p3_x2_i <= 0;
			wir1_p3_x3_r <= wir0_p3_x1_r - wir_p2_x2_r;
			wir1_p3_x3_i <= wir0_p3_x1_i - wir_p2_x2_i;
			wir1_p3_x4_r <= 0;
			wir1_p3_x4_i <= 0;
		end
		3'd4 : begin
			wir1_p3_x1_r <= { {3{wir1_p1_x1_r[18]}}, wir1_p1_x1_r,3'b0};  //2.17 --> 5.20
			wir1_p3_x1_i <= { {3{wir1_p1_x1_i[18]}}, wir1_p1_x1_i,3'b0};
			wir1_p3_x2_r <= { {3{wir1_p1_x2_r[18]}}, wir1_p1_x2_r,3'b0};
			wir1_p3_x2_i <= { {3{wir1_p1_x2_i[18]}}, wir1_p1_x2_i,3'b0};
			wir1_p3_x3_r <= { {3{wir1_p1_x3_r[18]}}, wir1_p1_x3_r,3'b0};
			wir1_p3_x3_i <= { {3{wir1_p1_x3_i[18]}}, wir1_p1_x3_i,3'b0};
			wir1_p3_x4_r <= { {3{wir1_p1_x4_r[18]}}, wir1_p1_x4_r,3'b0};
			wir1_p3_x4_i <= { {3{wir1_p1_x4_i[18]}}, wir1_p1_x4_i,3'b0};
		end
		default : begin // case 3'd4, 3'd2
			wir1_p3_x1_r <= { {3{wir1_p1_x1_r[18]}}, wir1_p1_x1_r,3'b0};  //2.17 --> 5.20
			wir1_p3_x1_i <= { {3{wir1_p1_x1_i[18]}}, wir1_p1_x1_i,3'b0};
			wir1_p3_x2_r <= { {3{wir1_p1_x2_r[18]}}, wir1_p1_x2_r,3'b0};
			wir1_p3_x2_i <= { {3{wir1_p1_x2_i[18]}}, wir1_p1_x2_i,3'b0};
			wir1_p3_x3_r <= { {3{wir1_p1_x3_r[18]}}, wir1_p1_x3_r,3'b0};
			wir1_p3_x3_i <= { {3{wir1_p1_x3_i[18]}}, wir1_p1_x3_i,3'b0};
			wir1_p3_x4_r <= { {3{wir1_p1_x4_r[18]}}, wir1_p1_x4_r,3'b0};
			wir1_p3_x4_i <= { {3{wir1_p1_x4_i[18]}}, wir1_p1_x4_i,3'b0};
		end
	endcase
	p2_x0_r_dly <= p2_x0_r;
	p2_x0_i_dly <= p2_x0_i;
	end
end


always@(*) begin
	if (factor==3'd2) begin
		wir2_p3_x1_r = wir1_p3_x1_r;
		wir2_p3_x1_i = wir1_p3_x1_i;
		wir2_p3_x2_r = wir1_p3_x2_r;
		wir2_p3_x2_i = wir1_p3_x2_i;
		wir2_p3_x3_r = wir1_p3_x3_r;
		wir2_p3_x3_i = wir1_p3_x3_i;
		wir2_p3_x4_r = wir1_p3_x4_r;
		wir2_p3_x4_i = wir1_p3_x4_i;
	end
	else begin
		wir2_p3_x1_r = wir1_p3_x1_r + wir1_p3_x2_r;
		wir2_p3_x1_i = wir1_p3_x1_i + wir1_p3_x2_i;
		wir2_p3_x2_r = wir1_p3_x1_r - wir1_p3_x2_r;
		wir2_p3_x2_i = wir1_p3_x1_i - wir1_p3_x2_i;
		if (factor == 3'd4) begin
			if (inverse == 1'b0) begin
				wir2_p3_x3_r = wir1_p3_x3_r + wir1_p3_x4_i;
				wir2_p3_x3_i = wir1_p3_x3_i - wir1_p3_x4_r;
				wir2_p3_x4_r = wir1_p3_x3_r - wir1_p3_x4_i;
				wir2_p3_x4_i = wir1_p3_x3_i + wir1_p3_x4_r;
			end
			else begin
				wir2_p3_x3_r = wir1_p3_x3_r - wir1_p3_x4_i;
				wir2_p3_x3_i = wir1_p3_x3_i + wir1_p3_x4_r;
				wir2_p3_x4_r = wir1_p3_x3_r + wir1_p3_x4_i;
				wir2_p3_x4_i = wir1_p3_x3_i - wir1_p3_x4_r;
			end
		end
		else begin
			wir2_p3_x3_r = wir1_p3_x3_r + wir1_p3_x4_r;
			wir2_p3_x3_i = wir1_p3_x3_i + wir1_p3_x4_i;
			wir2_p3_x4_r = wir1_p3_x3_r - wir1_p3_x4_r;
			wir2_p3_x4_i = wir1_p3_x3_i - wir1_p3_x4_i;
		end
	end
end

always@(posedge clk)
begin
	if (!rst_n) begin
		p3_x0_r <= 0;
		p3_x0_i <= 0;
		p3_x1_r <= 0;
		p3_x1_i <= 0;
		p3_x2_r <= 0;
		p3_x2_i <= 0;
		p3_x3_r <= 0;
		p3_x3_i <= 0;
		p3_x4_r <= 0;
		p3_x4_i <= 0;
	end
	else begin
		p3_x0_r <= {p2_x0_r_dly, 3'b000};
		p3_x0_i <= {p2_x0_i_dly, 3'b000};
		p3_x1_r <= wir2_p3_x1_r[23:0];
		p3_x1_i <= wir2_p3_x1_i[23:0];
		p3_x2_r <= wir2_p3_x2_r[23:0];
		p3_x2_i <= wir2_p3_x2_i[23:0];
		p3_x3_r <= wir2_p3_x3_r[23:0];
		p3_x3_i <= wir2_p3_x3_i[23:0];
		p3_x4_r <= wir2_p3_x4_r[23:0];
		p3_x4_i <= wir2_p3_x4_i[23:0];
	end
end
always@(posedge clk) 
	word_growth <= (worst_case_growth >= margin_in)?  
	               worst_case_growth - margin_in : 2'd0;

//-------- 5th +1 pipeline   scaling & margin ------------
logic signed [27-1:0] wir1_p4_x0_r, wir1_p4_x0_i;
logic signed [27-1:0] wir1_p4_x1_r, wir1_p4_x1_i;
logic signed [27-1:0] wir1_p4_x2_r, wir1_p4_x2_i;
logic signed [27-1:0] wir1_p4_x3_r, wir1_p4_x3_i;
logic signed [27-1:0] wir1_p4_x4_r, wir1_p4_x4_i;
logic signed [27-1:0] wir2_p4_x0_r, wir2_p4_x0_i;
logic signed [27-1:0] wir2_p4_x1_r, wir2_p4_x1_i;
logic signed [27-1:0] wir2_p4_x2_r, wir2_p4_x2_i;
logic signed [27-1:0] wir2_p4_x3_r, wir2_p4_x3_i;
logic signed [27-1:0] wir2_p4_x4_r, wir2_p4_x4_i;

assign wir1_p4_x0_r = {p3_x0_r, 3'd0};
assign wir1_p4_x0_i = {p3_x0_i, 3'd0};
assign wir1_p4_x1_r = {p3_x1_r, 3'd0};
assign wir1_p4_x1_i = {p3_x1_i, 3'd0};
assign wir1_p4_x2_r = {p3_x2_r, 3'd0};
assign wir1_p4_x2_i = {p3_x2_i, 3'd0};
assign wir1_p4_x3_r = {p3_x3_r, 3'd0};
assign wir1_p4_x3_i = {p3_x3_i, 3'd0};
assign wir1_p4_x4_r = {p3_x4_r, 3'd0};
assign wir1_p4_x4_i = {p3_x4_i, 3'd0};

always@(*) begin
case (word_growth)
	2'd0 : begin
		wir2_p4_x0_r = wir1_p4_x0_r;
		wir2_p4_x0_i = wir1_p4_x0_i;
		wir2_p4_x1_r = wir1_p4_x1_r;
		wir2_p4_x1_i = wir1_p4_x1_i;
		wir2_p4_x2_r = wir1_p4_x2_r;
		wir2_p4_x2_i = wir1_p4_x2_i;
		wir2_p4_x3_r = wir1_p4_x3_r;
		wir2_p4_x3_i = wir1_p4_x3_i;
		wir2_p4_x4_r = wir1_p4_x4_r;
		wir2_p4_x4_i = wir1_p4_x4_i;
	end
	2'd1 : begin
		wir2_p4_x0_r = wir1_p4_x0_r >>> 1 ;
		wir2_p4_x0_i = wir1_p4_x0_i >>> 1 ;
		wir2_p4_x1_r = wir1_p4_x1_r >>> 1 ;
		wir2_p4_x1_i = wir1_p4_x1_i >>> 1 ;
		wir2_p4_x2_r = wir1_p4_x2_r >>> 1 ;
		wir2_p4_x2_i = wir1_p4_x2_i >>> 1 ;
		wir2_p4_x3_r = wir1_p4_x3_r >>> 1 ;
		wir2_p4_x3_i = wir1_p4_x3_i >>> 1 ;
		wir2_p4_x4_r = wir1_p4_x4_r >>> 1 ;
		wir2_p4_x4_i = wir1_p4_x4_i >>> 1 ;
	end
	2'd2 : begin
		wir2_p4_x0_r = wir1_p4_x0_r >>> 2 ;
		wir2_p4_x0_i = wir1_p4_x0_i >>> 2 ;
		wir2_p4_x1_r = wir1_p4_x1_r >>> 2 ;
		wir2_p4_x1_i = wir1_p4_x1_i >>> 2 ;
		wir2_p4_x2_r = wir1_p4_x2_r >>> 2 ;
		wir2_p4_x2_i = wir1_p4_x2_i >>> 2 ;
		wir2_p4_x3_r = wir1_p4_x3_r >>> 2 ;
		wir2_p4_x3_i = wir1_p4_x3_i >>> 2 ;
		wir2_p4_x4_r = wir1_p4_x4_r >>> 2 ;
		wir2_p4_x4_i = wir1_p4_x4_i >>> 2 ;
	end
	2'd3 : begin
		wir2_p4_x0_r = wir1_p4_x0_r >>> 3 ;
		wir2_p4_x0_i = wir1_p4_x0_i >>> 3 ;
		wir2_p4_x1_r = wir1_p4_x1_r >>> 3 ;
		wir2_p4_x1_i = wir1_p4_x1_i >>> 3 ;
		wir2_p4_x2_r = wir1_p4_x2_r >>> 3 ;
		wir2_p4_x2_i = wir1_p4_x2_i >>> 3 ;
		wir2_p4_x3_r = wir1_p4_x3_r >>> 3 ;
		wir2_p4_x3_i = wir1_p4_x3_i >>> 3 ;
		wir2_p4_x4_r = wir1_p4_x4_r >>> 3 ;
		wir2_p4_x4_i = wir1_p4_x4_i >>> 3 ;
	end
endcase
end

logic signed [18-1:0] dout_real_t [0:4];
logic signed [18-1:0] dout_imag_t [0:4]; 

always@(posedge clk)
begin
	if (!rst_n) begin
		out_val <= 0;
		val_r <= 0;
		exp_out <= 0;
		// for (j=0; j<=4; j++) begin
		// 	dout_real[j] <= 0;
		// 	dout_imag[j] <= 0;
		// end
	end
	else begin
		// {out_val, val_r} <= {val_r, in_val};
		val_r <= {val_r[4:0], in_val};
		if (factor==3'd3 || factor==3'd5)
			out_val <= val_r[5];
		else
			out_val <= val_r[2];

		dout_real_t[0] <= (wir2_p4_x0_r[5])? wir2_p4_x0_r[23:6]+2'sd1 : wir2_p4_x0_r[23:6]; 
		dout_imag_t[0] <= (wir2_p4_x0_i[5])? wir2_p4_x0_i[23:6]+2'sd1 : wir2_p4_x0_i[23:6]; 

		dout_real_t[1] <= (wir2_p4_x1_r[5])? wir2_p4_x1_r[23:6]+2'sd1 : wir2_p4_x1_r[23:6];
		dout_imag_t[1] <= (wir2_p4_x1_i[5])? wir2_p4_x1_i[23:6]+2'sd1 : wir2_p4_x1_i[23:6];

		dout_real_t[2] <= (wir2_p4_x2_r[5])? wir2_p4_x2_r[23:6]+2'sd1 : wir2_p4_x2_r[23:6];
		dout_imag_t[2] <= (wir2_p4_x2_i[5])? wir2_p4_x2_i[23:6]+2'sd1 : wir2_p4_x2_i[23:6];

		dout_real_t[3] <= (wir2_p4_x3_r[5])? wir2_p4_x3_r[23:6]+2'sd1 : wir2_p4_x3_r[23:6];
		dout_imag_t[3] <= (wir2_p4_x3_i[5])? wir2_p4_x3_i[23:6]+2'sd1 : wir2_p4_x3_i[23:6];

		dout_real_t[4] <= (wir2_p4_x4_r[5])? wir2_p4_x4_r[23:6]+2'sd1 : wir2_p4_x4_r[23:6]; 
		dout_imag_t[4] <= (wir2_p4_x4_i[5])? wir2_p4_x4_i[23:6]+2'sd1 : wir2_p4_x4_i[23:6]; 

		if (factor==3'd3 || factor==3'd5) 
			exp_out <= (val_r[4])? exp_in + word_growth : exp_out; 
		else
			exp_out <= (val_r[1])? exp_in + word_growth : exp_out; 
	end
end

always@(*) begin
	if (factor==3'd5 || factor==3'd3) begin
		dout_real[0] = dout_real_t[0];
		dout_imag[0] = dout_imag_t[0];
	end
	else begin
		dout_real[0] = dout_real_t[1];
		dout_imag[0] = dout_imag_t[1];
	end

	if (factor==3'd5) begin
		dout_real[1] = dout_real_t[2];
		dout_imag[1] = dout_imag_t[2];
	end
	else if (factor==3'd3) begin
		dout_real[1] = dout_real_t[1];
		dout_imag[1] = dout_imag_t[1];
	end
	else begin
		dout_real[1] = dout_real_t[3];
		dout_imag[1] = dout_imag_t[3];
	end

	if (factor==3'd5 || factor==3'd3) begin
		dout_real[2] = dout_real_t[3];
		dout_imag[2] = dout_imag_t[3];
	end
	else begin
		dout_real[2] = dout_real_t[2];
		dout_imag[2] = dout_imag_t[2];
	end

	if (factor==3'd3) begin
		dout_real[3] = 0;
		dout_imag[3] = 0;
	end
	else begin
		dout_real[3] = dout_real_t[4];
		dout_imag[3] = dout_imag_t[4];
	end

	if (factor==3'd5) begin
		dout_real[4] = dout_real_t[1];
		dout_imag[4] = dout_imag_t[1];
	end
	else begin
		dout_real[4] = 0;
		dout_imag[4] = 0;
	end

end


// assign dout_real[0] = (wir2_p4_x0_r[5])? wir2_p4_x0_r[23:6]+2'sd1 : wir2_p4_x0_r[23:6]; 
// assign dout_imag[0] = (wir2_p4_x0_i[5])? wir2_p4_x0_i[23:6]+2'sd1 : wir2_p4_x0_i[23:6]; 

// assign dout_real[1] = (wir2_p4_x2_r[5])? wir2_p4_x2_r[23:6]+2'sd1 : wir2_p4_x2_r[23:6];
// assign dout_imag[1] = (wir2_p4_x2_i[5])? wir2_p4_x2_i[23:6]+2'sd1 : wir2_p4_x2_i[23:6];

// assign dout_real[2] = (wir2_p4_x3_r[5])? wir2_p4_x3_r[23:6]+2'sd1 : wir2_p4_x3_r[23:6];
// assign dout_imag[2] = (wir2_p4_x3_i[5])? wir2_p4_x3_i[23:6]+2'sd1 : wir2_p4_x3_i[23:6];

// assign dout_real[3] = (wir2_p4_x4_r[5])? wir2_p4_x4_r[23:6]+2'sd1 : wir2_p4_x4_r[23:6]; 
// assign dout_imag[3] = (wir2_p4_x4_i[5])? wir2_p4_x4_i[23:6]+2'sd1 : wir2_p4_x4_i[23:6]; 

// assign dout_real[4] = (wir2_p4_x1_r[5])? wir2_p4_x1_r[23:6]+2'sd1 : wir2_p4_x1_r[23:6];
// assign dout_imag[4] = (wir2_p4_x1_i[5])? wir2_p4_x1_i[23:6]+2'sd1 : wir2_p4_x1_i[23:6];



endmodule