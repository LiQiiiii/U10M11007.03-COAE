module pipe_reg_6(
	input [5:0] in,
    input clock,
	input reset,
	input wrn,
	output reg [5:0]out
	);
 
	always @(posedge clock,negedge reset) 
	begin
		if(!reset)
			out <= 6'b000000;
		else 
			if(wrn)
				out <= in;
	end	
endmodule 