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

initial	begin
	rst_n = 0;
	clk = 0;
	// clr = 1'b1;

	# 100 rst_n = 1'b1;
	// # 100 clr = 1'b0;
end

always # 5 clk = ~clk; //100M

logic [15:0]  cnt0;
localparam logic [15:0] gap = 16'd1000;

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
	end
	else
	begin
		dftpts_in <= 12'd1200;
		cnt0 <= (cnt0 == dftpts_in + gap)? 16'd0 : cnt0+1'b1;
		sink_sop <= (cnt0==16'd1);
		sink_eop <= (cnt0==16'd1200);
		sink_valid <= (cnt0>=16'd1 && cnt0<=16'd1200);
		if (cnt0 <= 16'd1201)
		begin
			sink_real <= cnt0[11:0];
			sink_imag <= {cnt0[5:0], cnt0[11:6]};
		end
		else
		begin
			sink_real <= 0;
			sink_imag <= 0;
		end
	end
end


top_mixed_radix_dft_0 
top_mixed_radix_dft_0_inst(
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

	.source_valid  (),
	.source_ready  (1'b1),
	.source_sop  (),
	.source_eop  (),
	.source_real  (),
	.source_imag  (),
	.dftpts_out  ()
);

endmodule