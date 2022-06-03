module pipe_reg_2(
	   input [1:0] in,
       input clock,
	   input reset,
	   //input op,
	   output reg [1:0]out
 );
 
	always @(posedge clock,negedge reset) begin
    if(!reset)
	   out <= 0;
	else 
	   out <= in;
	end
endmodule 