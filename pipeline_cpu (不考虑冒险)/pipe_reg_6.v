module pipe_reg_6(
	   input [5:0] in,
       input clock,
	   input reset,
	   //input op,
	   output reg [5:0]out

 );
 
	always @(posedge clock,negedge reset) 
	begin
    if(!reset)
	   out <= 0;
	else 
	   out <= in;
	end
	
endmodule 