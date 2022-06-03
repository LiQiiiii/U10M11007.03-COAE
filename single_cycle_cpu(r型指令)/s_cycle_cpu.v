module s_cycle_cpu(clock,reset);

	input clock;
	input reset;
	
	wire [31:0] cpc; 
	reg [31:0] npc; 
	
	wire [31:0] instruction; 
	
	wire [31:0] a; 
	wire [31:0] b; 

	wire reg_write;
	reg [4:0] num_write;
	reg [4:0] rt;
	reg [4:0] rs;
	wire [2:0] aluop;
	wire [5:0] op = instruction[31:26];
	wire [5:0] funct = instruction[5:0];
	
	wire [31:0] data_write;
	
	always @(*)
		begin
			num_write <= instruction[15:11];
			rt <= instruction[20:16];
			rs <= instruction[25:21];
		end
	
	ctrl CTRL(reg_write, aluop, op, funct);
	PC PC(cpc,clock,reset,cpc+4);
	IM IM(instruction,cpc);
	GPR GPR(a,b,clock,reg_write,num_write,rs,rt,data_write);
	ALU ALU(data_write,a,b,aluop);
		
endmodule


module ctrl(reg_write,aluop,op,funct);

	output reg reg_write;
	output [2:0] aluop;
	input [5:0] op;
	input [5:0] funct;
	
	assign aluop = funct[2:0];
	
	always @(op, funct)
		if(op == 6'b000000)
			begin
			reg_write = 1;
			end
			
		// aluop = funct[2:0];

endmodule	


module IM(instruction,pc);

	output [31:0] instruction;
	input [31:0] pc;

	reg [31:0] ins_memory[1023:0]; 
	
	
	assign instruction = ins_memory[pc[11:2]];
	
endmodule


module PC(pc,clock,reset,npc);

	output reg [31:0] pc;
	input clock;
	input reset;
	input [31:0] npc;
	
	
	always @(posedge clock or negedge reset)
		if(!reset)
			pc = 32'h00003000;
		else
			pc = npc;
	
endmodule

module ALU(c,a,b,aluop);

	output reg [31:0] c;
	input [31:0] a;
	input [31:0] b;
	input [2:0] aluop;
	
	always @(*)
	begin
		case(aluop)
			3'b000:
				begin
					c = $signed(a) + $signed(b);
				end
			3'b001:
				begin
					c = a + b;
				end
			3'b010:
				begin
					c = ($signed(a)<$signed(b)) ? 32'h0000_0001:32'h0000_0000;
				end
			3'b011:
				begin
					c = a - b;
				end
			3'b100:
				begin
					c = a & b;
				end
			3'b101:
				begin
					c = a | b;
				end
			default: c = 32'h0000_0000;
		endcase 
	end
endmodule




module GPR(a,b,clock,reg_write,num_write,rs,rt,data_write);

	output [31:0] a;  
	output [31:0] b;
	input clock;
	input reg_write;
	input [4:0] rs; //读寄存器1
	input [4:0] rt; //读寄存器2
	input [4:0] num_write; //写寄存器
	input [31:0] data_write; //写数据

	reg [31:0] gp_registers[31:0];  

	assign a = (rs == 0)? 0 : gp_registers[rs];
	assign b = (rt == 0)? 0 : gp_registers[rt];
	
	always @(posedge clock)
		if(reg_write)
			gp_registers[num_write] = data_write;
		
	
	
endmodule