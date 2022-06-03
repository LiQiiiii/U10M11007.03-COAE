module ctrl2(
    input [4:0] dddrw,
	input [4:0] ddrw,
	input [4:0] drw,
	input [4:0] nrs,
	input [4:0] nrt,
	input [4:0] rs,
	input [4:0] rt,
	input nreg_write,
	input nnreg_write,
	input ememtoreg,
	input mmemtoreg,
	output reg [1:0] s_forwardA,
	output reg [1:0] s_forwardB,
	output wrn
	);
	  
	assign  wrn = ~(ememtoreg & nreg_write & (drw!=0) & ( (rs==drw) | (rt == drw))); 

	always@(*)
	begin
	    if((nrs == ddrw)&&(!mmemtoreg))
			s_forwardA = 2'b00;
		else if(nrs == dddrw)
			s_forwardA = 2'b01;
		else
			s_forwardA = 2'b10;
    end
  
	always@(*)
	begin
	    if((nrt == ddrw)&&(!mmemtoreg))
			s_forwardB = 2'b00;
		else if(nrt == dddrw)
			s_forwardB = 2'b01;
		else
			s_forwardB = 2'b10;
	end
endmodule
	
	
	

       	   