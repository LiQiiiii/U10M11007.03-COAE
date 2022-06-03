module ext(imm16,Extop,Ext_imm32);
	input [15:0] imm16;
	input Extop;
	output reg [31:0]Ext_imm32;

	always @(*)
	begin
		if(Extop == 0)
			Ext_imm32 = {16'b0000000000000000,imm16};
		else if(Extop == 1)
			if($signed(imm16) >= 0)
				Ext_imm32 =  {16'b0000000000000000,imm16};
			else 
				Ext_imm32 =  {16'b1111111111111111,imm16};
		else
			Ext_imm32 = 32'bxxxxxxxxxxxxxxxx;
	end
endmodule