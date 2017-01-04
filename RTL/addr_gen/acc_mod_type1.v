// Accumulator and modulo type 1

// 
module acc_mod_type1 #(parameter
		wDataInOut = 16
	)
	(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input clr,
	input ena_top,
	input in_carry,
	input [wDataInOut-1:0] 	mod,
	input [wDataInOut-1:0] 	inc,

	output [wDataInOut-1:0] out_acc
);

reg [wDataInOut-1:0] acc, acc_mod;
reg 	ena_acc;

assign out_acc = acc;

always@(posedge clk)
begin
	if (!rst_n)
	begin
		acc <= 0;
	end
	else
	begin
		if (clr)
			acc <= 0;
		else if (ena_acc)
			acc <= acc_mod + inc;
		else
			acc <= acc;
	end
end

always@(*)
	acc_mod = (acc >= mod) ? (acc-mod) : acc;

always@(*)
	ena_acc = in_carry & ena_top;

endmodule