module pipe_reg_5(
	input [4:0] in,
    input clock,
	input reset,
	input wrn,
	output reg [4:0]out
	);
 
	always @(posedge clock,negedge reset) 
	begin
		if(!reset)
			out <= 5'b00000;
		else 
			if(wrn)
				out <= in;
	end
endmodule 