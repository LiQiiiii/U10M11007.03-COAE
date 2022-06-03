module pc(pc,clock,reset,wrn,npc);
    output reg [31:0] pc;
	input clock;
	input reset;
	input wrn;
	input [31:0]npc;
	always @(posedge clock,negedge reset)
	    begin
			if(!reset)
			begin
				pc <= 32'h00003000;
			end
			else 
			begin
				if(wrn)
					pc <= npc;
			end
	    end
endmodule