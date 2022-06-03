module alu(c,zero,a,b,aluop);
    output  reg [31:0] c;
	output  reg zero; 
	input [31:0] a;
    input [31:0] b;
    input [4:0] aluop;	
	wire [31:0]as;
	wire  [31:0]bs;
	assign as = $signed(a);
	assign bs = $signed(b);

	always @*
	begin
		case (aluop)
			5'b00001: c = as+bs;  
			5'b00010: c = a+b;    
			5'b00011: c = a-b;    
			5'b00100: c = a&b;    
			5'b00101: c = a|b;   
			5'b00110: c = (as < bs) ? 32'd1 : 32'd10; 
			5'b00111: c = {b[15:0],16'b0000000000000000};
			5'b01000:
			begin
       		  if(a == b)
				zero = 1'b1;
			  else
				zero = 1'b0;
			end
		default: c= 32'b0000_0000;
		endcase
   end    
endmodule
    
