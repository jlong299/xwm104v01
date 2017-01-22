module mrd_dft_rdx4  #(parameter
	wDataInOut = 30
	)
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [0:4][wDataInOut-1:0] din_real,
	input signed [0:4][wDataInOut-1:0] din_imag,

	output logic out_val,
	output logic signed [0:4][wDataInOut-1:0] dout_real,
	output logic signed [0:4][wDataInOut-1:0] dout_imag  
);

always@(posedge clk)
begin
	if (!rst_n) begin
		out_val <= 0;
		dout_real <= 0;
		dout_imag <= 0;
	end
	else begin
		out_val <= in_val;

		dout_real[0] <= din_real[0]+din_real[1]+din_real[2]+din_real[3]; 
		dout_imag[0] <= din_imag[0]+din_imag[1]+din_imag[2]+din_imag[3]; 

		dout_real[1] <= din_real[0]+din_imag[1]-din_real[2]-din_imag[3]; 
		dout_imag[1] <= din_imag[0]-din_real[1]-din_imag[2]+din_real[3]; 

		dout_real[2] <= din_real[0]-din_real[1]+din_real[2]-din_real[3]; 
		dout_imag[2] <= din_imag[0]-din_imag[1]+din_imag[2]-din_imag[3]; 

		dout_real[3] <= din_real[0]-din_imag[1]-din_real[2]+din_imag[3]; 
		dout_imag[3] <= din_imag[0]+din_real[1]-din_imag[2]-din_real[3]; 
	end
end



endmodule