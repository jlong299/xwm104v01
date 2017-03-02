module mrd_rdx3_v2  
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

localparam wDataTemp = 48;
logic [1:0] val_r;

logic signed [17:0] p1_0_r, p1_0_i;
logic signed [18:0] p1_1_r, p1_1_i;
logic signed [17:0] p1_2_r, p1_2_i;
wire signed [18:0] wire_p1_2_r, wire_p1_2_i;

//---------- 1st pipeline --------------
assign wire_p1_2_r = -din_real[1] + din_real[2];
assign wire_p1_2_i = -din_imag[1] + din_imag[2];
always@(posedge clk)
begin
	if (!rst_n) begin
			p1_0_r <= 0;
			p1_0_i <= 0;
			p1_1_r <= 0;
			p1_1_i <= 0;
			p1_2_r <= 0;
			p1_2_i <= 0;
	end
	else begin
		// 1st pipeline
		p1_0_r <= din_real[0];
		p1_0_i <= din_imag[0];
		p1_1_r <= din_real[1] + din_real[2];
		p1_1_i <= din_imag[1] + din_imag[2];
		p1_2_r <= (wire_p1_2_r[0])? wire_p1_2_r[18:1]+2'sd1 : wire_p1_2_r[18:1];
		p1_2_i <= (wire_p1_2_i[0])? wire_p1_2_i[18:1]+2'sd1 : wire_p1_2_i[18:1];
	end
end

//---------- 2nd pipeline --------------
always@(posedge clk)
begin
	if (!rst_n) begin
			p1_0_r <= 0;
			p1_0_i <= 0;
			p1_1_r <= 0;
			p1_1_i <= 0;
			p1_2_r <= 0;
			p1_2_i <= 0;
	end
	else begin
		p2_real[1] <= p1_real[1] + p1_real[2];
		p2_imag[1] <= p1_imag[1] + p1_imag[2];

		p2_real[2] <= p1_real[1] - (p1_real[2] >>>1);
		p2_imag[2] <= p1_imag[1] - (p1_imag[2] >>>1);

		p2_real[3] <= p1_imag[3] * -18'sd14189 ;
		p2_imag[3] <= p1_real[3] * 18'sd14189 ;
	end
end

assign p2_real_tr[1] = p2_real[1];
assign p2_imag_tr[1] = p2_imag[1];
assign p2_real_tr[2] = p2_real[2];
assign p2_imag_tr[2] = p2_imag[2];
assign p2_real_tr[3] = (p2_real[3] >>>14);
assign p2_imag_tr[3] = (p2_imag[3] >>>14);


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

		dout_real[1] <= p2_real_tr[2] + p2_real_tr[3]; 
		dout_imag[1] <= p2_imag_tr[2] + p2_imag_tr[3];

		dout_real[2] <= p2_real_tr[2] - p2_real_tr[3]; 
		dout_imag[2] <= p2_imag_tr[2] - p2_imag_tr[3]; 

		dout_real[3] <= 0; 
		dout_imag[3] <= 0; 

		dout_real[4] <= 0;
		dout_imag[4] <= 0;
	end
end



endmodule