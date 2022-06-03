module pipe_reg_1(
	   input in,
       input clock,
	   input reset,
	   //input op,
	   output reg out
 );
 
	always @(posedge clock,negedge reset) 
	begin
    if(!reset)
	   out <= 0;
	else 
	   out <= in;
	end
endmodule 