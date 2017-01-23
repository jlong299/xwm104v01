module mrd_dft_rdx5  #(parameter
	wDataInOut = 30
	)
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [wDataInOut-1:0] din_real [0:4],
	input signed [wDataInOut-1:0] din_imag [0:4],

	output logic out_val,
	output logic signed [wDataInOut-1:0] dout_real [0:4],
	output logic signed [wDataInOut-1:0] dout_imag [0:4]  
);

localparam wDataTemp = 48;
logic [1:0] val_r;

logic signed [wDataInOut-1:0] pm1_real [1:6];
logic signed [wDataInOut-1:0] pm2_real [1:6];
logic signed [wDataInOut-1:0] pm3_real [1:6];
logic signed [wDataInOut-1:0] pm1_imag [1:6];
logic signed [wDataInOut-1:0] pm2_imag [1:6];
logic signed [wDataInOut-1:0] pm3_imag [1:6];
logic signed [wDataInOut-1:0] p1_real [1:6];
logic signed [wDataTemp-1:0] p2_real [1:6];
logic signed [wDataInOut-1:0] p3_real [1:6];
logic signed [wDataInOut-1:0] p1_imag [1:6];
logic signed [wDataTemp-1:0] p2_imag [1:6];
logic signed [wDataInOut-1:0] p3_imag [1:6];

logic signed [wDataInOut-1:0] p2_real_tr [1:6];
logic signed [wDataInOut-1:0] p2_imag_tr [1:6];

assign pm1_real[2] = din_real[1] + din_real[4];
assign pm1_real[3] = din_real[2] + din_real[3];
assign pm1_real[4] = din_real[1] - din_real[4];
assign pm1_real[5] = din_real[2] - din_real[3];
assign pm1_imag[2] = din_imag[1] + din_imag[4];
assign pm1_imag[3] = din_imag[2] + din_imag[3];
assign pm1_imag[4] = din_imag[1] - din_imag[4];
assign pm1_imag[5] = din_imag[2] - din_imag[3];

always@(posedge clk)
begin
	if (!rst_n) begin
		p1_real[1] <= 0;
		p1_real[2] <= 0;
		p1_real[3] <= 0;
		p1_real[4] <= 0;
		p1_real[5] <= 0;
		p1_real[6] <= 0;

		p2_real[1] <= 0;
		p2_real[2] <= 0;
		p2_real[3] <= 0;
		p2_real[4] <= 0;
		p2_real[5] <= 0;
		p2_real[6] <= 0;

		p1_imag[1] <= 0;
		p1_imag[2] <= 0;
		p1_imag[3] <= 0;
		p1_imag[4] <= 0;
		p1_imag[5] <= 0;
		p1_imag[6] <= 0;

		p2_imag[1] <= 0;
		p2_imag[2] <= 0;
		p2_imag[3] <= 0;
		p2_imag[4] <= 0;
		p2_imag[5] <= 0;
		p2_imag[6] <= 0;
	end
	else begin
		// 1st pipeline
		p1_real[1] <= din_real[0];
		p1_real[2] <= pm1_real[2] + pm1_real[3];
		p1_real[3] <= pm1_real[2] - pm1_real[3];
		p1_real[4] <= pm1_real[4];
		p1_real[5] <= pm1_real[5];
		p1_real[6] <= pm1_real[4] + pm1_real[5];

		p1_imag[1] <= din_imag[0];
		p1_imag[2] <= pm1_imag[2] + pm1_imag[3];
		p1_imag[3] <= pm1_imag[2] - pm1_imag[3];
		p1_imag[4] <= pm1_imag[4];
		p1_imag[5] <= pm1_imag[5];
		p1_imag[6] <= pm1_imag[4] + pm1_imag[5];

		// 2nd pipeline
		p2_real[1] <= p1_real[1] + p1_real[2];
		p2_imag[1] <= p1_imag[1] + p1_imag[2];

		p2_real[2] <= p1_real[1] - p1_real[2]/4;
		p2_imag[2] <= p1_imag[1] - p1_imag[2]/4;

		p2_real[3] <= p1_real[3] * $signed(18'd9159) ;
		p2_imag[3] <= p1_imag[3] * $signed(18'd9159) ;
		// p2_real[3] <= p1_real[3] * 0.559 ;
		// p2_imag[3] <= p1_imag[3] * 0.559 ;

		p2_real[4] <= p1_imag[4] * $signed(18'd25215);
		p2_imag[4] <= p1_real[4] * $signed(-18'd25215);
		// p2_real[4] <= p1_imag[4] * 1.539;
		// p2_imag[4] <= p1_real[4] * (-1.539);

		p2_real[5] <= p1_imag[5] * $signed(18'd5931);
		p2_imag[5] <= p1_real[5] * $signed(-18'd5931);
		// p2_real[5] <= p1_imag[5] * 0.362;
		// p2_imag[5] <= p1_real[5] * (-0.362);

		// p2_real[6] <= p1_imag[5] * (-0.951);
		// p2_imag[6] <= p1_real[5] * 0.951;
		p2_real[6] <= p1_imag[6] * $signed(-18'd15581);
		p2_imag[6] <= p1_real[6] * $signed(18'd15581);
	end
end

genvar i;
generate
	for (i=3; i<=6; i++) begin
		assign p2_real_tr[i] =p2_real[i][wDataInOut+14-1 : 14];
		assign p2_imag_tr[i] =p2_imag[i][wDataInOut+14-1 : 14];
	end
endgenerate;
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
		dout_real[0] <= 0;
		dout_real[1] <= 0;
		dout_real[2] <= 0;
		dout_real[3] <= 0;
		dout_real[4] <= 0;
		dout_imag[0] <= 0;
		dout_imag[1] <= 0;
		dout_imag[2] <= 0;
		dout_imag[3] <= 0;
		dout_imag[4] <= 0;
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