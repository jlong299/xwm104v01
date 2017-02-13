module mrd_dft_rdx2  #(parameter
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

always@(posedge clk)
begin
	if (!rst_n) begin
		out_val <= 0;
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
		out_val <= in_val;

		dout_real[0] <= din_real[0]+din_real[1]; 
		dout_imag[0] <= din_imag[0]+din_imag[1]; 

		dout_real[1] <= din_real[0]-din_real[1]; 
		dout_imag[1] <= din_imag[0]-din_imag[1]; 

		dout_real[2] <= 0; 
		dout_imag[2] <= 0; 

		dout_real[3] <= 0; 
		dout_imag[3] <= 0; 

		dout_real[4] <= 0;
		dout_imag[4] <= 0;
	end
end



endmodule