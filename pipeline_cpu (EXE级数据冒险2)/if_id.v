`include "pipe_reg_wrn.v"
module if_id(pc4, inst, clock, reset, wrn,dpc4, dinst);
	input [31:0] pc4; 
    input [31:0] inst; 
    input 	clock;
    input 	reset;
	input   wrn;
	output [31:0] dpc4; 
	output [31:0] dinst;

	pipe_reg_wrn nextpc(pc4,clock,reset,wrn,dpc4);
	pipe_reg_wrn id(inst,clock,reset,wrn,dinst);
endmodule
		
	    
	    