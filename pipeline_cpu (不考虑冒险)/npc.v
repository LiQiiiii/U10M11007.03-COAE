module npc(pc,Ext_imm32,inster,busa,Npcop,zero,npc);
  input [31:0]pc;
  input [31:0]Ext_imm32;
  input [25:0]inster;
  input [31:0]busa;
  input [2:0]Npcop;
  input zero;
  output  [31:0]npc;
  
  reg [31:0]nnpc;
  
  assign npc = nnpc;

	always@(*)
	begin
	  case(Npcop)
	    3'd0: nnpc = pc+4;
		3'd1: 
		   begin
		     if(!zero)
			   nnpc = pc +4;
			 else
			  nnpc = pc+4+(Ext_imm32 << 2);
		   end
		3'd2: nnpc = {pc[31:28],inster,2'b00};
		3'd3: nnpc = busa;
		3'd4: nnpc = {pc[31:28],inster,2'b00};
		default : nnpc = pc+4;
	  endcase
	end
endmodule