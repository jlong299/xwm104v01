`timescale 1 ns / 1 ns
module top_tb (

	);

reg clk;    // Clock
reg rst_n;  // Asynchronous reset active low
logic sink_valid;
logic [17:0] sink_real;
logic [17:0] sink_imag;
logic sink_sop;
logic sink_eop;
logic [11:0] dftpts_in;
logic inverse;

logic source_valid, source_sop, source_eop;
logic signed [17:0]  source_real, source_imag;
logic [3:0] source_exp;
logic [3:0]  cnt_sink_sop;

integer 	data_file, scan_file, wr_file;
logic [31:0] 	captured_data, captured_data_imag;
logic [15:0]  cnt_file_end; 

initial begin
	data_file = $fopen("dft_src.dat","r");
	if (data_file == 0) begin
		$display("dft_src handle was NULL");
		$finish;
	end

	wr_file = $fopen("top_result.dat","w");
	if (wr_file == 0) begin
		$display("top_result handle was NULL");
		$finish;
	end
end

initial	begin
	rst_n = 0;
	clk = 0;
	// clr = 1'b1;

	# 100 rst_n = 1'b1;
	// # 100 clr = 1'b0;
end

always # 5 clk = ~clk; //100M

logic [15:0]  cnt0;
localparam logic [15:0] gap = 16'd3000;
localparam logic [11:0] dftpts = 12'd1200;
logic rd_file_end;

always@(posedge clk) 
begin
	if (!rst_n)
	begin
		sink_valid <= 0;
		sink_real <= 0;
		sink_imag <= 0;
		sink_sop <= 0;
		sink_eop <= 0;
		dftpts_in <= 0;
		inverse <= 0;
		cnt0 <= 0;
		cnt_sink_sop <= 0;
		cnt_file_end <= 0;
		rd_file_end <= 0;
	end
	else
	begin
		//dftpts_in <= dftpts;
		if (cnt0==1 && !rd_file_end) begin
			scan_file = $fscanf(data_file, "%d\n", captured_data);
			dftpts_in = captured_data;
		end

		if (dftpts_in < 180)
			cnt0 <= (cnt0 == dftpts_in + 600)? 16'd0 : cnt0+1'b1;
		else
			cnt0 <= (cnt0 == dftpts_in + 4*dftpts_in)? 16'd0 : cnt0+1'b1;

		sink_sop <= (cnt0==16'd10 && !rd_file_end);
		sink_eop <= (cnt0==16'd10+dftpts_in-1 && !rd_file_end);
		sink_valid <= (cnt0>=16'd10 && cnt0<16'd10+dftpts_in && !rd_file_end);

		cnt_sink_sop <= (sink_sop && cnt_sink_sop!=4'd4)? cnt_sink_sop+4'd1 : cnt_sink_sop;



		// if (cnt0 <= 16'd11+dftpts_in)
		// begin
		// 	sink_real <= {2'b00, cnt0} - 18'd10;
		// 	sink_imag <= {2'b00, cnt0} - 18'd10;
		// end
		// else
		// begin
		// 	sink_real <= 0;
		// 	sink_imag <= 0;
		// end

		if (!rd_file_end) begin
		if (cnt0>=16'd10 && cnt0<16'd10+dftpts_in) begin
			if (!$feof(data_file)) begin
				scan_file = $fscanf(data_file, "%d %d\n", captured_data, captured_data_imag);
				sink_real = captured_data[17:0];
				sink_imag = captured_data_imag[17:0];
			end
			else begin
				sink_real = 0;
				sink_imag = 0;
			end
		end
		else
		begin
			if ($feof(data_file))
			begin
				// $fseek(data_file,0,0);
				// cnt_file_end = cnt_file_end + 16'd1;
				// if (cnt_file_end==param_cnt_file_end) $fclose(data_file);
				cnt_file_end = cnt_file_end + 16'd1;
				$fclose(data_file);
				rd_file_end <= 1'b1;
			end
		end
		end
		

	end
end

logic [5:0] size;
always@(*) begin
	case (dftpts_in)
		12'd1200 : size = 6'd33;
		12'd1152 : size = 6'd32;
		12'd1080 : size = 6'd31;
		12'd972 : size = 6'd30;
		12'd960 : size = 6'd29;
		12'd900 : size = 6'd28;
		12'd864 : size = 6'd27;
		12'd768 : size = 6'd26;
		12'd720 : size = 6'd25;
		12'd648 : size = 6'd24;
		12'd600 : size = 6'd23;
		12'd576 : size = 6'd22;
		12'd540 : size = 6'd21;
		12'd480 : size = 6'd20;
		12'd432 : size = 6'd19;
		12'd384 : size = 6'd18;
		12'd360 : size = 6'd17;
		12'd324 : size = 6'd16;
		12'd300 : size = 6'd15;
		12'd288 : size = 6'd14;
		12'd240 : size = 6'd13;
		12'd216 : size = 6'd12;
		12'd192 : size = 6'd11;
		12'd180 : size = 6'd10;
		12'd144 : size = 6'd9;
		12'd120 : size = 6'd8;
		12'd108 : size = 6'd7;
		12'd96 : size = 6'd6;
		12'd72 : size = 6'd5;
		12'd60 : size = 6'd4;
		12'd48 : size = 6'd3;
		12'd36 : size = 6'd2;
		12'd24 : size = 6'd1;
		12'd12 : size = 6'd0;
	default : size = 6'd0;
	endcase
end

top_mixed_radix_dft_0 
top_inst(
	.clk  (clk),    // Clock
	.rst_n  (rst_n),  // Asynchronous reset active low
	
	.sink_valid  (sink_valid),
	.sink_ready  (sink_ready),
	.sink_sop  (sink_sop),
	.sink_eop  (sink_eop),
	.sink_real  (sink_real),
	.sink_imag  (sink_imag),
	// .dftpts_in  (dftpts_in),
	.size  (size),
	.inverse  (inverse),

	.source_valid  (source_valid),
	.source_ready  (1'b1),
	.source_sop  (source_sop),
	.source_eop  (source_eop),
	.source_real  (source_real),
	.source_imag  (source_imag),
	.source_exp (source_exp)
	// .dftpts_out  ()
);


logic [15:0]  cnt_val_debug, cnt_close_file;
logic signed [29:0]  real_adj, imag_adj;
always@(posedge clk)
begin
	if (!rst_n) begin
		cnt_val_debug <= 0;
		cnt_close_file <= 0;
	end
	else
	begin
			if (source_valid)
			begin
				cnt_val_debug <= cnt_val_debug + 16'd1;
				real_adj = source_real*$signed(2**source_exp);
				imag_adj = source_imag*$signed(2**source_exp);
				$fwrite(wr_file, "%d %d\n", $signed(real_adj), $signed(imag_adj));
			end

			// if (cnt_val_debug==dftpts)  
			// begin
			// 	$fclose(wr_file);
			// 	cnt_val_debug <= dftpts + 16'd1;
			// end

			cnt_close_file <= (rd_file_end)? cnt_close_file+1 : 0;
			if (cnt_close_file == 16'd3200)
				$fclose(wr_file);
	end

end

endmodule