module mrd_rdx4_2_v2  
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [18-1:0] din_real [0:4],
	input signed [18-1:0] din_imag [0:4],
	input [2:0] factor,

	input unsigned [1:0] margin_in,
	input unsigned [3:0] exp_in,

	output logic out_val,
	output logic signed [18-1:0] dout_real [0:4],
	output logic signed [18-1:0] dout_imag [0:4], 
	output logic unsigned [3:0] exp_out
);

logic unsigned [1:0] worst_case_growth;
logic unsigned [1:0] word_growth;
logic [2+2:0] val_r;
logic signed [18-1:0] p1_x0_r, p1_x0_i, p1_x1_r, p1_x1_i, p1_x2_r, p1_x2_i, p1_x3_r, p1_x3_i; //1.17

assign worst_case_growth = (factor==3'd2)? 2'd2 : 2'd3;
integer j;
//---------- first 2 pipelines  Only register inputs to sync with radx5 -------------
logic signed [18-1:0] din_real_r0 [0:3];
logic signed [18-1:0] din_real_r1 [0:3];
logic signed [18-1:0] din_imag_r0 [0:3];
logic signed [18-1:0] din_imag_r1 [0:3];
always@(posedge clk) begin
	for (j=0; j<=3; j++) begin
		din_real_r0[j] <= din_real[j];
		din_real_r1[j] <= din_real_r0[j];
		din_imag_r0[j] <= din_imag[j];
		din_imag_r1[j] <= din_imag_r0[j];
	end
end

// assign din_real_r1[0] = din_real[0];
// assign din_real_r1[1] = din_real[1];
// assign din_real_r1[2] = din_real[2];
// assign din_real_r1[3] = din_real[3];
// assign din_imag_r1[0] = din_imag[0];
// assign din_imag_r1[1] = din_imag[1];
// assign din_imag_r1[2] = din_imag[2];
// assign din_imag_r1[3] = din_imag[3];

//---------- 1st pipeline -------------
always@(posedge clk)
begin
	if (!rst_n) begin
		p1_x0_r <= 0;
		p1_x0_i <= 0;
		p1_x1_r <= 0;
		p1_x1_i <= 0;
		p1_x2_r <= 0;
		p1_x2_i <= 0;
		p1_x3_r <= 0;
		p1_x3_i <= 0;
	end
	else begin
		p1_x0_r <= din_real_r1[0];
		p1_x0_i <= din_imag_r1[0];
		p1_x1_r <= (factor==3'd2)? din_real_r1[1] : din_real_r1[2];
		p1_x1_i <= (factor==3'd2)? din_imag_r1[1] : din_imag_r1[2];
		p1_x2_r <= (factor==3'd2)? din_real_r1[2] : din_real_r1[1];
		p1_x2_i <= (factor==3'd2)? din_imag_r1[2] : din_imag_r1[1];
		p1_x3_r <= din_real_r1[3];
		p1_x3_i <= din_imag_r1[3];
	end
end

//---------- 2nd pipeline -------------
logic signed [19-1:0] p2_x0_r, p2_x0_i, p2_x1_r, p2_x1_i, p2_x2_r, p2_x2_i, p2_x3_r, p2_x3_i; //2.17

always@(posedge clk)
begin
	if (!rst_n) begin
		p2_x0_r <= 0;
		p2_x0_i <= 0;
		p2_x1_r <= 0;
		p2_x1_i <= 0;
		p2_x2_r <= 0;
		p2_x2_i <= 0;
		p2_x3_r <= 0;
		p2_x3_i <= 0;
	end
	else begin
		p2_x0_r <= p1_x0_r + p1_x1_r;
		p2_x0_i <= p1_x0_i + p1_x1_i;
		p2_x1_r <= p1_x0_r - p1_x1_r;
		p2_x1_i <= p1_x0_i - p1_x1_i;
		p2_x2_r <= p1_x2_r + p1_x3_r;
		p2_x2_i <= p1_x2_i + p1_x3_i;
		p2_x3_r <= p1_x2_r - p1_x3_r;
		p2_x3_i <= p1_x2_i - p1_x3_i;
	end
end

//---------- 3rd pipeline -------------
logic signed [20-1:0] p3_x0_r, p3_x0_i, p3_x1_r, p3_x1_i, p3_x2_r, p3_x2_i, p3_x3_r, p3_x3_i; //3.17

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
	end
	else begin
		if (factor==3'd2) begin
			p3_x0_r <= p2_x0_r;
			p3_x0_i <= p2_x0_i;
			p3_x1_r <= p2_x1_r;
			p3_x1_i <= p2_x1_i;
			p3_x2_r <= p2_x2_r;
			p3_x2_i <= p2_x2_i;
			p3_x3_r <= p2_x3_r;
			p3_x3_i <= p2_x3_i;
		end
		else begin
			p3_x0_r <= p2_x0_r + p2_x2_r;
			p3_x0_i <= p2_x0_i + p2_x2_i;
			
			// FFT
			p3_x1_r <= p2_x1_r + p2_x3_i;
			p3_x1_i <= p2_x1_i - p2_x3_r;
			// Inverse FFT
			// p3_x1_r <= p2_x1_r - p2_x3_i;
			// p3_x1_i <= p2_x1_i + p2_x3_r;

			p3_x2_r <= p2_x0_r - p2_x2_r;
			p3_x2_i <= p2_x0_i - p2_x2_i;

			// FFT
			p3_x3_r <= p2_x1_r - p2_x3_i;
			p3_x3_i <= p2_x1_i + p2_x3_r;
			// Inverse FFT
			// p3_x3_r <= p2_x1_r + p2_x3_i;
			// p3_x3_i <= p2_x1_i - p2_x3_r;
		end
	end
end
always@(posedge clk) 
	word_growth = (worst_case_growth >= margin_in)?  
	               worst_case_growth - margin_in : 2'd0;

//-------- 4th pipeline   scaling & margin ------------
logic signed [23-1:0] wir1_p4_x0_r, wir1_p4_x0_i; //3.20
logic signed [23-1:0] wir1_p4_x1_r, wir1_p4_x1_i;
logic signed [23-1:0] wir1_p4_x2_r, wir1_p4_x2_i;
logic signed [23-1:0] wir1_p4_x3_r, wir1_p4_x3_i;
logic signed [23-1:0] wir2_p4_x0_r, wir2_p4_x0_i;
logic signed [23-1:0] wir2_p4_x1_r, wir2_p4_x1_i;
logic signed [23-1:0] wir2_p4_x2_r, wir2_p4_x2_i;
logic signed [23-1:0] wir2_p4_x3_r, wir2_p4_x3_i;

assign wir1_p4_x0_r = {p3_x0_r, 3'd0};
assign wir1_p4_x0_i = {p3_x0_i, 3'd0};
assign wir1_p4_x1_r = {p3_x1_r, 3'd0};
assign wir1_p4_x1_i = {p3_x1_i, 3'd0};
assign wir1_p4_x2_r = {p3_x2_r, 3'd0};
assign wir1_p4_x2_i = {p3_x2_i, 3'd0};
assign wir1_p4_x3_r = {p3_x3_r, 3'd0};
assign wir1_p4_x3_i = {p3_x3_i, 3'd0};

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
	end
endcase
end

always@(posedge clk)
begin
	if (!rst_n) begin
		out_val <= 0;
		val_r <= 0;
		exp_out <= 0;
		for (j=0; j<=4; j++) begin
			dout_real[j] <= 0;
			dout_imag[j] <= 0;
		end
	end
	else begin
		{out_val, val_r} <= {val_r, in_val};

		dout_real[0] <= (wir2_p4_x0_r[2])? wir2_p4_x0_r[20:3]+2'sd1 : wir2_p4_x0_r[20:3]; 
		dout_imag[0] <= (wir2_p4_x0_i[2])? wir2_p4_x0_i[20:3]+2'sd1 : wir2_p4_x0_i[20:3]; 

		dout_real[1] <= (wir2_p4_x1_r[2])? wir2_p4_x1_r[20:3]+2'sd1 : wir2_p4_x1_r[20:3];
		dout_imag[1] <= (wir2_p4_x1_i[2])? wir2_p4_x1_i[20:3]+2'sd1 : wir2_p4_x1_i[20:3];

		dout_real[2] <= (wir2_p4_x2_r[2])? wir2_p4_x2_r[20:3]+2'sd1 : wir2_p4_x2_r[20:3];
		dout_imag[2] <= (wir2_p4_x2_i[2])? wir2_p4_x2_i[20:3]+2'sd1 : wir2_p4_x2_i[20:3];

		dout_real[3] <= (wir2_p4_x3_r[2])? wir2_p4_x3_r[20:3]+2'sd1 : wir2_p4_x3_r[20:3]; 
		dout_imag[3] <= (wir2_p4_x3_i[2])? wir2_p4_x3_i[20:3]+2'sd1 : wir2_p4_x3_i[20:3]; 

		exp_out <= (val_r[1+2])? exp_in + word_growth : exp_out; 
	end
end


endmodule