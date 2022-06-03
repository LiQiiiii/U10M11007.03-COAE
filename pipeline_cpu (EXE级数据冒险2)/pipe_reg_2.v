module pipe_reg_2(
	input [1:0] in,
	input clock,
	input reset,
	input wrn,
	output reg [1:0]out
	);
 
	always @(posedge clock,negedge reset) 
	begin
    if(!reset)
		out <= 2'b00;
	else 
		if(wrn)
			out <= in;
	end
endmodule 