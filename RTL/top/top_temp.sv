module top_temp (
	input clk,    // Clock
	input rst_n  // Asynchronous reset active low

	);


logic sink_valid;
logic [17:0] sink_real;
logic [17:0] sink_imag;
logic sink_sop;
logic sink_eop;
logic [11:0] dftpts_in;
logic inverse;

logic source_valid, source_sop, source_eop;
logic [17:0]  source_real, source_imag;
logic [3:0] source_exp;

logic [15:0]  cnt0;
localparam logic [15:0] gap = 16'd3000;
localparam logic [11:0] dftpts = 12'd1200;

logic [5:0] size;

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
		size <= 0;
	end
	else
	begin
		dftpts_in <= dftpts;
		
		if (dftpts_in < 180)
			cnt0 <= (cnt0 == dftpts_in + 400)? 16'd0 : cnt0+1'b1;
		else
			cnt0 <= (cnt0 == dftpts_in + 4*dftpts_in)? 16'd0 : cnt0+1'b1;

		sink_sop <= (cnt0==16'd10);
		sink_eop <= (cnt0==16'd10+dftpts_in-1 );
		sink_valid <= (cnt0>=16'd10 && cnt0<16'd10+dftpts_in );


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

		size <= (sink_sop)? size + 6'd1 : size;

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
	.size  (size),
	.inverse  (inverse),

	.source_valid  (source_valid),
	// .source_ready  (1'b1),
	.source_sop  (source_sop),
	.source_eop  (source_eop),
	.source_real  (source_real),
	.source_imag  (source_imag),
	.source_exp (source_exp)
	// .dftpts_out  ()
);


endmodule