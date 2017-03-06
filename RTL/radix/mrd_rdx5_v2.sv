module mrd_rdx5_v2  
	(
	input clk,    
	input rst_n,

	input in_val,
	input signed [18-1:0] din_real [0:4],
	input signed [18-1:0] din_imag [0:4],

	input unsigned [1:0] margin_in,
	input unsigned [3:0] exp_in,

	output logic out_val,
	output logic signed [18-1:0] dout_real [0:4],
	output logic signed [18-1:0] dout_imag [0:4], 
	output logic unsigned [3:0] exp_out
);

localparam unsigned [1:0] worst_case_growth = 2'd3;
logic unsigned [1:0] word_growth;
logic [2:0] val_r;
reg [18-1:0] p1_x0_r, p1_x0_i; //1.17
reg [20-1:0] p1_x1_r, p1_x1_i; //3.17
wire [19-1:0] wir1_p1_x1_r, wir1_p1_x1_i, wir1_p1_x2_r, wir1_p1_x2_i, wir1_p1_x3_r, wir1_p1_x3_i, wir1_p1_x4_r, wir1_p1_x4_i;
wire [20-1:0] wir2_p1_x1_r, wir2_p1_x1_i, wir2_p1_x2_r, wir2_p1_x2_i, wir2_p1_x5_r, wir2_p1_x5_i;
reg [18-1:0] p1_x2_r, p1_x2_i, p1_x5_r, p1_x5_i; //3.15
reg [18-1:0] p1_x3_r, p1_x3_i, p1_x4_r, p1_x4_i; //2.16

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

//---------- 2nd pipeline -------------
logic signed [21-1:0] p2_x0_r, p2_x0_i; //4.17
logic signed [23-1:0] p2_x1_r, p2_x1_i; //4.19
logic signed [24-1:0] p2_x2_r, p2_x2_i, p2_x3_r, p2_x3_i, p2_x4_r, p2_x4_i, p2_x5_r, p2_x5_i; //4.20
wire signed [20-1:0] wir1_p2_x0_r, wir1_p2_x0_i;
wire signed [22-1:0] wir1_p2_x1_r, wir1_p2_x1_i;
wire signed [36-1:0] wir1_p2_x2_r, wir1_p2_x2_i;
wire signed [36-1:0] wir1_p2_x3_r, wir1_p2_x3_i;
wire signed [36-1:0] wir1_p2_x4_r, wir1_p2_x4_i;
wire signed [36-1:0] wir1_p2_x5_r, wir1_p2_x5_i;

assign wir1_p2_x0_r = {p1_x0_r, 2'b00};
assign wir1_p2_x0_i = {p1_x0_i, 2'b00};
assign wir1_p2_x1_r = {p1_x1_r[19], p1_x1_r[19], p1_x1_r};
assign wir1_p2_x1_i = {p1_x1_i[19], p1_x1_i[19], p1_x1_i};

assign wir1_p2_x2_r = p1_x2_r * 18'sh11E37 ; //1.17
assign wir1_p2_x2_i = p1_x2_i * 18'sh11E37 ;
assign wir1_p2_x3_r = p1_x3_i * -18'sh2EC1D ; //2.16
assign wir1_p2_x3_i = p1_x3_r * 18'sh2EC1D ;
assign wir1_p2_x4_r = p1_x4_i * -18'sh34601 ; //1.17
assign wir1_p2_x4_i = p1_x4_r * 18'sh34601 ;
assign wir1_p2_x5_r = p1_x5_i * -18'sh1E6F1 ; //1.17
assign wir1_p2_x5_i = p1_x5_r * 18'sh1E6F1 ;

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
		p2_x4_r <= 0;
		p2_x4_i <= 0;
		p2_x5_r <= 0;
		p2_x5_i <= 0;
	end
	else begin
		p2_x0_r <= p1_x0_r + p1_x1_r;
		p2_x0_i <= p1_x0_i + p1_x1_i;
		p2_x1_r <= wir1_p2_x0_r - wir1_p2_x1_r;
		p2_x1_i <= wir1_p2_x0_i - wir1_p2_x1_i;
		p2_x2_r <= wir1_p2_x2_r[35:12];
		p2_x2_i <= wir1_p2_x2_i[35:12];
		p2_x3_r <= wir1_p2_x3_r[35:12];
		p2_x3_i <= wir1_p2_x3_i[35:12];
		p2_x4_r <= {wir1_p2_x4_r[35],wir1_p2_x4_r[35:13]};
		p2_x4_i <= {wir1_p2_x4_i[35],wir1_p2_x4_i[35:13]};
		p2_x5_r <= wir1_p2_x5_r[35:12];
		p2_x5_i <= wir1_p2_x5_i[35:12];
	end
end

//---------- 3rd pipeline -------------
logic signed [24-1:0] p3_x0_r, p3_x0_i, p3_x1_r, p3_x1_i, p3_x2_r, p3_x2_i,
               p3_x3_r, p3_x3_i, p3_x4_r, p3_x4_i;  //4.20
wire signed [24-1:0] wir0_p3_x1_r, wir0_p3_x1_i;               
wire signed [25-1:0] wir1_p3_x1_r, wir1_p3_x1_i, wir1_p3_x2_r, wir1_p3_x2_i, 
                     wir1_p3_x3_r, wir1_p3_x3_i, wir1_p3_x4_r, wir1_p3_x4_i;             
wire signed [25-1:0] wir2_p3_x1_r, wir2_p3_x1_i, wir2_p3_x2_r, wir2_p3_x2_i, 
                     wir2_p3_x3_r, wir2_p3_x3_i, wir2_p3_x4_r, wir2_p3_x4_i;             

assign wir0_p3_x1_r = {p2_x1_r,1'b0};
assign wir0_p3_x1_i = {p2_x1_i,1'b0};
assign wir1_p3_x1_r = wir0_p3_x1_r + p2_x2_r;
assign wir1_p3_x1_i = wir0_p3_x1_i + p2_x2_i;
assign wir1_p3_x2_r = p2_x4_r + p2_x5_r;
assign wir1_p3_x2_i = p2_x4_i + p2_x5_i;
assign wir1_p3_x3_r = p2_x1_r - p2_x2_r;
assign wir1_p3_x3_i = p2_x1_i - p2_x2_i;
assign wir1_p3_x4_r = p2_x3_r + p2_x5_r;
assign wir1_p3_x4_i = p2_x3_i + p2_x5_i; 

assign wir2_p3_x1_r = wir1_p3_x1_r + wir1_p3_x2_r;
assign wir2_p3_x1_i = wir1_p3_x1_i + wir1_p3_x2_i;
assign wir2_p3_x2_r = wir1_p3_x1_r - wir1_p3_x2_r;
assign wir2_p3_x2_i = wir1_p3_x1_i - wir1_p3_x2_i;
assign wir2_p3_x3_r = wir1_p3_x3_r + wir1_p3_x4_r;
assign wir2_p3_x3_i = wir1_p3_x3_i + wir1_p3_x4_i;
assign wir2_p3_x4_r = wir1_p3_x3_r - wir1_p3_x4_r;
assign wir2_p3_x4_i = wir1_p3_x3_i - wir1_p3_x4_i;

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
		p3_x0_r <= {p2_x0_r, 3'b000};
		p3_x0_i <= {p2_x0_i, 3'b000};
		p3_x1_r <= p2_x1_r[23:0];
		p3_x1_i <= p2_x1_i[23:0];
		p3_x2_r <= p2_x2_r[23:0];
		p3_x2_i <= p2_x2_i[23:0];
		p3_x3_r <= p2_x3_r[23:0];
		p3_x3_i <= p2_x3_i[23:0];
		p3_x4_r <= p2_x4_r[23:0];
		p3_x4_i <= p2_x4_i[23:0];
	end
end
always@(posedge clk) 
	word_growth = (worst_case_growth >= margin_in)?  
	               worst_case_growth - margin_in : 2'd0;

//-------- 4th pipeline   scaling & margin ------------
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

integer j;
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

		dout_real[0] <= (wir2_p4_x0_r[5])? wir2_p4_x0_r[23:6]+2'sd1 : wir2_p4_x0_r[23:6]; 
		dout_imag[0] <= (wir2_p4_x0_i[5])? wir2_p4_x0_i[23:6]+2'sd1 : wir2_p4_x0_i[23:6]; 

		dout_real[1] <= (wir2_p4_x1_r[5])? wir2_p4_x1_r[23:6]+2'sd1 : wir2_p4_x1_r[23:6];
		dout_imag[1] <= (wir2_p4_x1_i[5])? wir2_p4_x1_i[23:6]+2'sd1 : wir2_p4_x1_i[23:6];

		dout_real[2] <= (wir2_p4_x2_r[5])? wir2_p4_x2_r[23:6]+2'sd1 : wir2_p4_x2_r[23:6];
		dout_imag[2] <= (wir2_p4_x2_i[5])? wir2_p4_x2_i[23:6]+2'sd1 : wir2_p4_x2_i[23:6];

		dout_real[3] <= (wir2_p4_x3_r[5])? wir2_p4_x3_r[23:6]+2'sd1 : wir2_p4_x3_r[23:6]; 
		dout_imag[3] <= (wir2_p4_x3_i[5])? wir2_p4_x3_i[23:6]+2'sd1 : wir2_p4_x3_i[23:6]; 

		dout_real[4] <= (wir2_p4_x4_r[5])? wir2_p4_x4_r[23:6]+2'sd1 : wir2_p4_x4_r[23:6];
		dout_imag[4] <= (wir2_p4_x4_i[5])? wir2_p4_x4_i[23:6]+2'sd1 : wir2_p4_x4_i[23:6];

		exp_out <= (val_r[1])? exp_in + word_growth : exp_out; 
	end
end


endmodule