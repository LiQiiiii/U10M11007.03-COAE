`include "pipe_reg.v"
module if_id(pc4, inst, clock, reset, dpc4, dinst);
	input [31:0] pc4; 
    input [31:0] inst;  
    input 	clock;
    input 	reset;
	output [31:0] dpc4; 
	output [31:0] dinst;  

	pipe_reg nextpc(pc4,clock,reset,dpc4);
	pipe_reg id(inst,clock,reset,dinst);
endmodule
		
	    
	    