module gpr(a,b,clock,reg_write,instr,num_write,/*rs,rt,*/data_write);
	output [31:0] a;
	output [31:0] b;
	input clock;
	input reg_write;
	input [31:0] instr;
	input [4:0] num_write;//写寄存器
	input [31:0] data_write; // 写数据
	wire [4:0]rs;
	wire [4:0]rt;
	
	assign rs = instr[25:21];
	assign rt = instr[20:16];
	reg [31:0] gp_registers[31:0];  //32个寄存器
  
	always @(posedge clock)
	begin
		if(reg_write) 
			if(!num_write)
				gp_registers[num_write] <= gp_registers[num_write];
			else 
				gp_registers[num_write] <=data_write;
		else
			gp_registers[num_write] <= gp_registers[num_write];
	end
 
	assign a=(rs==0)?32'h0:gp_registers[rs];
	assign b=(rt==0)?32'h0:gp_registers[rt];
endmodule