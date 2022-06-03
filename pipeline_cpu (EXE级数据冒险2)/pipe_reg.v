module pipe_reg(
	input [31:0] in,
    input clock,
	input reset,
	input wrn,
	output reg [31:0]out
	);

	always @(posedge clock,negedge reset) 
	begin
    if(!reset)
		out <= 32'h0000_0000;
	else 
		if(wrn)
		out <= in;
	end
endmodule 
	   
	   
	