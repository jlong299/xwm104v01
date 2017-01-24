module mrd_dft_rdx3  #(parameter
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

logic signed [wDataInOut-1:0] p1_real [1:3];
logic signed [wDataTemp-1:0] p2_real [1:3];
logic signed [wDataInOut-1:0] p3_real [1:3];
logic signed [wDataInOut-1:0] p1_imag [1:3];
logic signed [wDataTemp-1:0] p2_imag [1:3];
logic signed [wDataInOut-1:0] p3_imag [1:3];

logic signed [wDataInOut-1:0] p2_real_tr [1:3];
logic signed [wDataInOut-1:0] p2_imag_tr [1:3];

integer j;
always@(posedge clk)
begin
	if (!rst_n) begin
		for (j=1; j<=3; j=j+1) begin
			p1_real[j] <= 0;
			p2_real[j] <= 0;
			p1_imag[j] <= 0;
			p1_imag[j] <= 0;
		end
	end
	else begin
		// 1st pipeline
		p1_real[1] <= din_real[0];
		p1_real[2] <= din_real[1] + din_real[2];
		p1_real[3] <= din_real[2] - din_real[1];

		p1_imag[1] <= din_imag[0];
		p1_imag[2] <= din_imag[1] + din_imag[2];
		p1_imag[3] <= din_imag[2] - din_imag[1];

		// 2nd pipeline
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