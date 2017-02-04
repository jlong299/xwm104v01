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
logic [29:0]  source_real, source_imag;
logic [3:0]  cnt_sink_sop;

integer wr_file;
initial begin
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
localparam logic [15:0] gap = 16'd1550;

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
	end
	else
	begin
		dftpts_in <= 12'd1200;
		cnt0 <= (cnt0 == dftpts_in + gap)? 16'd0 : cnt0+1'b1;
		sink_sop <= (cnt0==16'd10 && cnt_sink_sop!=4'd4);
		sink_eop <= (cnt0==16'd10+dftpts_in);
		sink_valid <= (cnt0>=16'd10 && cnt0<16'd10+dftpts_in);

		cnt_sink_sop <= (sink_sop && cnt_sink_sop!=4'd4)? cnt_sink_sop+4'd1 : cnt_sink_sop;

		if (cnt0 <= 16'd11+dftpts_in)
		begin
			sink_real <= {2'b00, cnt0} - 18'd10;
			sink_imag <= {2'b00, cnt0} - 18'd10;
		end
		else
		begin
			sink_real <= 0;
			sink_imag <= 0;
		end
	end
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
	.dftpts_in  (dftpts_in),
	.inverse  (inverse),

	.source_valid  (source_valid),
	.source_ready  (1'b1),
	.source_sop  (source_sop),
	.source_eop  (source_eop),
	.source_real  (source_real),
	.source_imag  (source_imag),
	.dftpts_out  ()
);


logic [15:0]  cnt_val_debug;
always@(posedge clk)
begin
	if (!rst_n)
		cnt_val_debug <= 0;
	else
	begin
			if (source_valid && cnt_val_debug <= 16'd1200)
			begin
				cnt_val_debug <= cnt_val_debug + 16'd1;
				$fwrite(wr_file, "%d %d\n", $signed(source_real), $signed(source_imag));
			end

			if (cnt_val_debug==16'd1200)  
			begin
				$fclose(wr_file);
				cnt_val_debug <= 16'd1201;
			end
	end

end

endmodule