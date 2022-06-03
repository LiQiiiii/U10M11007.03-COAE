module im(instruction,pc); 
	output [31:0] instruction;
	input [31:0] pc; 
	reg [31:0] ins_memory[1023:0];
	wire [9:0]tpc; 
  
	assign tpc = pc[11:2];  
	assign  instruction = ins_memory[tpc];  
endmodule