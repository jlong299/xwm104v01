// Accumulator type 1

// 
module acc_type1 #(parameter
		wDataInOut = 16
	)
	(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input clr,
	input ena_top,
	input in_carry,
	input [wDataInOut-1:0] 	max_acc,
	input [wDataInOut-1:0] 	inc,

	output [wDataInOut-1:0] out_acc,
	output out_carry
);

reg [wDataInOut-1:0] acc;
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
			acc <= (acc == max_acc)? 0 : acc + inc;
		else
			acc <= acc;
	end
end

always@(*)
	ena_acc = in_carry & ena_top;

always@(*)
	out_carry = (acc == max_acc) | (not(ena_top));


endmodule