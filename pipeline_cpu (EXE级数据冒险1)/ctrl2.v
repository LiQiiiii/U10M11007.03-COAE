module ctrl2(
    input [4:0] dddrw,
    input [4:0] ddrw,
	input [4:0] nrt,
	input [4:0] nrd,
	output reg [1:0] s_forwardA,
	output reg [1:0] s_forwardB
	);  
	
	always@(*)
	begin
	    if(nrt == ddrw)
			s_forwardA = 2'b00;
		else if(nrt == dddrw)
			s_forwardA = 2'b01;
		else
			s_forwardA = 2'b10;
    end
	  
	always@(*)
	begin
		if(nrd == ddrw)
			s_forwardB = 2'b00;
		else if(nrd == dddrw)
			s_forwardB = 2'b01;
		else
			s_forwardB = 2'b10;
   end
endmodule
	
	

       	   