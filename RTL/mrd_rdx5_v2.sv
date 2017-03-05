module mrd_rdx5_v2  
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [18-1:0] din_real [0:4],
	input signed [18-1:0] din_imag [0:4],

	output logic out_val,
	output logic signed [18-1:0] dout_real [0:4],
	output logic signed [18-1:0] dout_imag [0:4]  
);

logic [1:0] val_r;
reg [18-1:0] p1_x0_r, p1_x0_i;
reg [20-1:0] p1_x1_r, p1_x1_i;
wire [19-1:0] wir1_p1_x1_r, wir1_p1_x1_i, wir1_p1_x2_r, wir1_p1_x2_i, wir1_p1_x3_r, wir1_p1_x3_i, wir1_p1_x4_r, wir1_p1_x4_i;
wire [20-1:0] wir2_p1_x1_r, wir2_p1_x1_i, wir2_p1_x2_r, wir2_p1_x2_i, wir2_p1_x5_r, wir2_p1_x5_i;
reg [18-1:0] p1_x2_r, p1_x2_i, p1_x3_r, p1_x3_i, p1_x4_r, p1_x4_i, p1_x5_r, p1_x5_i;

//---------- 1st pipeline -------------
assign wir1_p1_x1_r = din_real[1] + din_real[4];
assign wir1_p1_x2_r = din_real[2] + din_real[3];
assign wir1_p1_x3_r = din_real[1] - din_real[4];
assign wir1_p1_x4_r = din_real[2] - din_real[3];
assign wir1_p1_x1_i = din_imag[1] + din_imag[4];
assign wir1_p1_x2_i = din_imag[2] + din_imag[3];
assign wir1_p1_x3_i = din_imag[1] - din_imag[4];
assign wir1_p1_x4_i = din_imag[2] - din_imag[3];

assign wir2_p1_x1_r = wir1_p1_x1_r + wir1_p1_x2_r;
assign wir2_p1_x2_r = wir1_p1_x1_r - wir1_p1_x2_r;
assign wir2_p1_x5_r = wir1_p1_x3_r + wir1_p1_x4_r;
assign wir2_p1_x1_i = wir1_p1_x1_i + wir1_p1_x2_i;
assign wir2_p1_x2_i = wir1_p1_x1_i - wir1_p1_x2_i;
assign wir2_p1_x5_i = wir1_p1_x3_i + wir1_p1_x4_i;

integer j;
always@(posedge clk)
begin
	if (!rst_n) begin
		for (j=1; j<=6; j=j+1) begin
			p1_real[j] <= 0;
			p2_real[j] <= 0;
			p1_imag[j] <= 0;
			p1_imag[j] <= 0;
		end
	end
	else begin
		p1_x0_r <= din_real[0];
		p1_x0_i <= din_imag[0];
		p1_x1_r <= wir2_p1_x1_r;
		p1_x1_i <= wir2_p1_x1_i;
		p1_x2_r <= (wir2_p1_x2_r[1])? wir2_p1_x2_r[19:2]+2'sd1 : wir2_p1_x2_r[19:2];
		p1_x2_i <= (wir2_p1_x2_i[1])? wir2_p1_x2_i[19:2]+2'sd1 : wir2_p1_x2_i[19:2];
		p1_x5_r <= (wir2_p1_x5_r[1])? wir2_p1_x5_r[19:2]+2'sd1 : wir2_p1_x5_r[19:2];
		p1_x5_i <= (wir2_p1_x5_i[1])? wir2_p1_x5_i[19:2]+2'sd1 : wir2_p1_x5_i[19:2];
		p1_x3_r <= (wir2_p1_x3_r[0])? wir1_p1_x3_r[18:1]+2'sd1 : wir1_p1_x3_r[18:1];
		p1_x3_i <= (wir2_p1_x3_i[0])? wir1_p1_x3_i[18:1]+2'sd1 : wir1_p1_x3_i[18:1];
		p1_x4_r <= (wir2_p1_x4_r[0])? wir1_p1_x4_r[18:1]+2'sd1 : wir1_p1_x4_r[18:1];
		p1_x4_i <= (wir2_p1_x4_i[0])? wir1_p1_x4_i[18:1]+2'sd1 : wir1_p1_x4_i[18:1];
	end
end

		// 2nd pipeline
		p2_real[1] <= p1_real[1] + p1_real[2];
		p2_imag[1] <= p1_imag[1] + p1_imag[2];

		p2_real[2] <= p1_real[1] - (p1_real[2] >>>2);
		p2_imag[2] <= p1_imag[1] - (p1_imag[2] >>>2);

		p2_real[3] <= p1_real[3] * 18'sd9159 ;
		p2_imag[3] <= p1_imag[3] * 18'sd9159 ;
		// p2_real[3] <= p1_real[3] * 0.559 ;
		// p2_imag[3] <= p1_imag[3] * 0.559 ;

		p2_real[4] <= p1_imag[4] * 18'sd25215;
		p2_imag[4] <= p1_real[4] * -18'sd25215;
		// p2_real[4] <= p1_imag[4] * 1.539;
		// p2_imag[4] <= p1_real[4] * (-1.539);

		p2_real[5] <= p1_imag[5] * 18'sd5931;
		p2_imag[5] <= p1_real[5] * -18'sd5931;
		// p2_real[5] <= p1_imag[5] * 0.362;
		// p2_imag[5] <= p1_real[5] * (-0.362);

		// p2_real[6] <= p1_imag[5] * (-0.951);
		// p2_imag[6] <= p1_real[5] * 0.951;
		p2_real[6] <= p1_imag[6] * -18'sd15581;
		p2_imag[6] <= p1_real[6] * 18'sd15581;
	end
end

genvar i;
generate
for (i=3; i<=6; i++) begin : gen0
	assign p2_real_tr[i] = (p2_real[i] >>> 14);
	assign p2_imag_tr[i] = (p2_imag[i] >>> 14);
end
endgenerate

assign p2_real_tr[1] = p2_real[1];
assign p2_imag_tr[1] = p2_imag[1];
assign p2_real_tr[2] = p2_real[2];
assign p2_imag_tr[2] = p2_imag[2];

assign pm3_real[2] = p2_real_tr[2] + p2_real_tr[3];
assign pm3_real[3] = p2_real_tr[5] + p2_real_tr[6];
assign pm3_real[4] = p2_real_tr[2] - p2_real_tr[3];
assign pm3_real[5] = p2_real_tr[4] + p2_real_tr[6];
assign pm3_imag[2] = p2_imag_tr[2] + p2_imag_tr[3];
assign pm3_imag[3] = p2_imag_tr[5] + p2_imag_tr[6];
assign pm3_imag[4] = p2_imag_tr[2] - p2_imag_tr[3];
assign pm3_imag[5] = p2_imag_tr[4] + p2_imag_tr[6];


// 3rd pipeline
always@(posedge clk)
begin
	if (!rst_n) begin
		out_val <= 0;
		val_r <= 0;
		for (j=0; j<=4; j++) begin
			dout_real[j] <= 0;
			dout_imag[j] <= 0;
		end
	end
	else begin
		val_r[0] <= in_val;
		val_r[1] <= val_r[0];
		out_val <= val_r[1];

		dout_real[0] <= p2_real_tr[1]; 
		dout_imag[0] <= p2_imag_tr[1]; 

		dout_real[1] <= pm3_real[2] - pm3_real[3]; 
		dout_imag[1] <= pm3_imag[2] - pm3_imag[3];

		dout_real[2] <= pm3_real[4] + pm3_real[5]; 
		dout_imag[2] <= pm3_imag[4] + pm3_imag[5]; 

		dout_real[3] <= pm3_real[4] - pm3_real[5]; 
		dout_imag[3] <= pm3_imag[4] - pm3_imag[5]; 

		dout_real[4] <= pm3_real[2] + pm3_real[3];
		dout_imag[4] <= pm3_imag[2] + pm3_imag[3];
	end
end



endmodule