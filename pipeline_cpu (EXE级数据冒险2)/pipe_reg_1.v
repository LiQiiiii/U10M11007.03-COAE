module pipe_reg_1(
	input in,
    input clock,
	input reset,
	input wrn,
	output reg out
	);
 
	always @(posedge clock,negedge reset) 
	begin
		if(!reset)
			out <= 0;
		else 
			if(wrn)
				out <= in;
	end
endmodule 