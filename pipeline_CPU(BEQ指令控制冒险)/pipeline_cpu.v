module pipeline_cpu(clock,reset);
    input clock;
    input reset;

	wire [31:0] pc,npc,id_pc,ex_pc,id_ins,if_ins,ex_alu_result,alu_result_a, alu_result_b,for_id_reg1Data,for_id_reg2Data,id_ext_num,mem_mem_data,ex_reg1Data,ex_reg2Data,exe_ext_imm;
	wire [31:0] mem_alu_result,mem_reg2Data,wb_pc,mem_pc,wb_alu_result,wb_mem_data,for_ex_reg1Data,for_ex_reg2Data,id_reg1Data,id_reg2Data,data_write;
	wire [31:0] s_wb_pc;
	wire [5:0] op_code,func;
	wire [4:0] rs,rt,rd,rw,aluop,num_write,ex_rw,mem_rw,wb_rw,exe_alu_op,exe_rs,exe_rt;
	wire [2:0] npc_op;
	wire [1:0]s_num_write,s_data_write,ex_s_data_write,mem_s_data_write,wb_s_data_write,s_forwardA,s_forwardB;
	wire id_reg_write,exSer,id_s_b,id_mem_write,zero_flag,ex_reg_write,mem_reg_write,wb_reg_write,exe_s_b,ex_mem_write,mem_mem_write,pc_write;
	wire id_mem_to_reg,ex_mem_to_reg,mem_mem_to_reg,s_forwardA2,s_forwardB2,IF_ID_flush,EXE_flush,mem_flush,zero_2;

	assign mem_pc_write = 1'b1;
	assign rs = id_ins[25:21];  
	assign rt = id_ins[20:16];  
	assign rd = id_ins[15:11]; 
	assign s_wb_pc = wb_pc+4;

	pc PC(pc,clock,reset,pc_write,npc);
	npc NPC(pc,id_pc,id_ext_num,id_ins[25:0] ,for_id_reg1Data,npc_op,zero_flag_2,npc);
	im IM(if_ins,pc);
	ctrl CTRL(id_ins[31:26],id_ins[5:0],exSer,id_reg_write,id_s_b,id_mem_write,aluop,s_num_write,s_data_write,npc_op,id_mem_to_reg);
	extender EXTENDER(id_ins[15:0],exSer,id_ext_num);
	gpr GPR(clock,wb_reg_write,id_ins,wb_rw,data_write,id_reg1Data,id_reg2Data); 
	mux3 #(32) Hazard1_forward1 (mem_alu_result,data_write,ex_reg1Data,s_forwardA,for_ex_reg1Data);
	mux3 #(32) Hazard1_forward2 (mem_alu_result,data_write,ex_reg2Data,s_forwardB,for_ex_reg2Data);
	mux2 #(32) Hazard2_forward1 (data_write,id_reg1Data,s_forwardA2,for_id_reg1Data);
	mux2 #(32) Hazard2_forward2 (data_write,id_reg2Data,s_forwardB2,for_id_reg2Data);
	forward CONTROL(
		wb_rw,mem_rw,ex_rw,exe_rs,exe_rt,rs,rt,ex_reg_write,mem_reg_write,wb_reg_write,ex_mem_to_reg,mem_mem_to_reg,npc_op,EXE_flush,mem_flush,id_reg1Data,id_reg2Data,
		pc_write,s_forwardA,s_forwardB,s_forwardA2,s_forwardB2,IF_ID_flush,zero_flag_2);
	alu ALU(ex_alu_result,for_ex_reg1Data,alu_result_b,exe_alu_op,zero_flag);
	dm DM(clock,mem_mem_write,mem_alu_result,mem_reg2Data,mem_mem_data);
	if_id IF_ID(
		clock,reset,pc_write,
		pc,if_ins,IF_ID_flush,
		id_pc,id_ins,EXE_flush
		);
	id_exe ID_EXE(
		clock,reset,pc_write,
		id_pc,for_id_reg1Data,for_id_reg2Data,id_ext_num, num_write,aluop,     id_s_b, id_reg_write,id_mem_write,s_data_write,   rs,   rt,     id_mem_to_reg,EXE_flush,
		ex_pc,ex_reg1Data,    ex_reg2Data,    exe_ext_imm,ex_rw,    exe_alu_op,exe_s_b,ex_reg_write,ex_mem_write,ex_s_data_write,exe_rs,exe_rt,ex_mem_to_reg,mem_flush
		);
		
	mux3 #(5)  RegToWrite(rt,rd, 32'b1111_1111_1111_1111_1111_1111_1111_1111,s_num_write,num_write);
	mux2 #(32) ALUToInput(for_ex_reg2Data,exe_ext_imm,exe_s_b,alu_result_b);//选第二个运算数据，注意是用传的数据选择，这意味着选择信号也要传
	
	exe_mem EXE_MEM(
		clock,reset,mem_pc_write,
		ex_pc, ex_alu_result, for_ex_reg2Data, ex_rw, ex_reg_write, ex_mem_write, ex_s_data_write, ex_mem_to_reg, 
	    mem_pc,mem_alu_result,mem_reg2Data,    mem_rw,mem_reg_write,mem_mem_write,mem_s_data_write,mem_mem_to_reg
		);
	mem_wb MEM_WB(
		clock,reset,mem_pc_write,
		mem_pc,mem_alu_result,mem_mem_data,mem_rw,mem_reg_write,mem_s_data_write,
	    wb_pc, wb_alu_result, wb_mem_data, wb_rw, wb_reg_write, wb_s_data_write
		);
	
	mux3 #(32) MemToWrite(wb_alu_result,wb_mem_data,s_wb_pc,wb_s_data_write,data_write);
	
endmodule




module alu(c,a,b,aluop,zero_flag);
	input [31:0] a;
    input [31:0] b;
    input [4:0] aluop;
	output  reg [31:0] c;
	output  reg zero_flag; 
	
	wire [31:0] signedA;
	wire [31:0] signedB;
	assign signedA = $signed(a);
	assign signedB = $signed(b);

	always @(*)
	begin
		if(aluop == 5'b00000) 
			c = 32'h0000_0000;
		else if	(aluop == 5'b00001) 
			c = signedA + signedB;  //add
		else if	(aluop == 5'b00010) 
			c = a+b;    //addu
		else if	(aluop == 5'b00011) 
			c = a-b;    //subu
		else if	(aluop == 5'b00100) 
			c = a&b;    //and
		else if	(aluop == 5'b00101) 
		 	c = a|b;    //or
		else if	(aluop == 5'b00110) 
			c = (signedA < signedB) ? 32'd1 : 32'd10; 
		else if	(aluop == 5'b00111) 
			c = {b[15:0],16'b0000000000000000};
		else if	(aluop == 5'b01000)
			begin
				if(a == b)
					zero_flag = 1'b1;
				else
					zero_flag = 1'b0;
				c = a - b;
			end
		else c =  a;
	end

endmodule
    


module ctrl(op_code,func,exSer,id_reg_write,id_s_b,id_mem_write,aluop,s_num_write,s_data_write,npc_op,id_mem_to_reg);
    input [5:0] op_code;
    input [5:0] func;

	output reg exSer;
    output reg id_reg_write;
	output reg id_s_b;
	output reg id_mem_to_reg;
	output reg id_mem_write;
	output reg [1:0] s_num_write;
	output reg [1:0] s_data_write;
	output reg [2:0] npc_op;
	output reg [4:0] aluop;

	always@(*)
	begin
	if(op_code == 6'b000000)//R
		begin
		if (func == 6'b100000)
				begin
				aluop = 5'b00001;
				npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100001)
				begin 
				aluop = 5'b00010;
		        npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100011)
				begin 
				aluop = 5'b00011;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end   
		else if (func == 6'b100100)
				begin 
				aluop = 5'b00100;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100101)
				begin 
				aluop = 5'b00101;
                npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b101010)
				begin 
				aluop = 5'b00110;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b001000)
				begin 
				aluop = 5'bxxxxx;
			    npc_op = 3'd3;
				id_reg_write = 1'b0;
				end
		else
			begin
			aluop = 5'bxxxxx;
			npc_op = 3'd0;
			id_reg_write = 1'b1;
			end
		exSer = 1'bx;
		id_s_b = 1'b0;   //选立即数
		s_num_write = 2'b01;
		id_mem_write = 1'b0;
		s_data_write = 2'b00;
		id_mem_to_reg = 1'b0;
		end
	// I型指令
	else if(op_code == 6'b001000)  //addi
		begin
		    aluop = 5'b00010;  //用add
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001001) //addiu
		begin
		    aluop = 5'b00010;  //用addu
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;   //选立即数
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b0;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001100) // andi
		begin
		    aluop = 5'b00100;  //and
			id_reg_write = 1'b1;
			exSer = 1'b0;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
    else if(op_code == 6'b001101)// ori
		begin
		    aluop = 5'b00101;  //or
			id_reg_write = 1'b1;
			exSer = 1'b0;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001111)  // lui
		begin
			aluop = 5'b00111;  
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b101011)  //sw
		begin 
			aluop = 5'b00010;  //add
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b11;
			id_mem_write = 1'b1;
			s_data_write = 2'bxx;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b100011)  //lw
		begin
			aluop = 5'b00010;  //add
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b01;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b1;
		end
	else if(op_code == 6'b000100)   //beq
		begin
			aluop = 5'b01000;
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b01;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd1;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b000010)  //j
		begin
			aluop = 5'b00000;
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b01;
			id_mem_write = 1'b0;
			s_data_write = 2'b01;
			npc_op = 3'd2;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b000011)  //jal
		begin
			aluop = 5'b00000;
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b10;
			id_mem_write = 1'b0;
			s_data_write = 2'b10;
			npc_op = 3'd4;
			id_mem_to_reg = 1'b0;
		end
	else
		begin
			aluop = 5'bxxxxxx;
			id_reg_write = 1'b0;
			exSer = 1'bx;
			s_num_write = 2'bxx;
			id_mem_write = 1'b0;
			id_s_b = 1'bx;
			s_data_write = 2'bxx;
			npc_op = 3'dx;
			id_mem_to_reg = 1'bx;
		end
end

endmodule 

module ctrl(op_code,func,exSer,id_reg_write,id_s_b,id_mem_write,aluop,s_num_write,s_data_write,npc_op,id_mem_to_reg);
    input [5:0] op_code;
    input [5:0] func;

	output reg exSer;
    output reg id_reg_write;
	output reg id_s_b;
	output reg id_mem_to_reg;
	output reg id_mem_write;
	output reg [1:0] s_num_write;
	output reg [1:0] s_data_write;
	output reg [2:0] npc_op;
	output reg [4:0] aluop;

	always@(*)
	begin
	if(op_code == 6'b000000)//R
		begin
		if (func == 6'b100000)
				begin
				aluop = 5'b00001;
				npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100001)
				begin 
				aluop = 5'b00010;
		        npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100011)
				begin 
				aluop = 5'b00011;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end   
		else if (func == 6'b100100)
				begin 
				aluop = 5'b00100;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b100101)
				begin 
				aluop = 5'b00101;
                npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b101010)
				begin 
				aluop = 5'b00110;
			    npc_op = 3'd0;
				id_reg_write = 1'b1;
				end
		else if (func == 6'b001000)
				begin 
				aluop = 5'bxxxxx;
			    npc_op = 3'd3;
				id_reg_write = 1'b0;
				end
		else
			begin
			aluop = 5'bxxxxx;
			npc_op = 3'd0;
			id_reg_write = 1'b1;
			end
		exSer = 1'bx;
		id_s_b = 1'b0;   
		s_num_write = 2'b01;
		id_mem_write = 1'b0;
		s_data_write = 2'b00;
		id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001000) 
		begin
		    aluop = 5'b00010;  
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001001) 
		begin
		    aluop = 5'b00010;  
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;   
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b0;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001100) 
		begin
		    aluop = 5'b00100;  
			id_reg_write = 1'b1;
			exSer = 1'b0;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
    else if(op_code == 6'b001101)
		begin
		    aluop = 5'b00101;  
			id_reg_write = 1'b1;
			exSer = 1'b0;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b001111)  
		begin
			aluop = 5'b00111;  
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b101011)  
		begin 
			aluop = 5'b00010;  
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b11;
			id_mem_write = 1'b1;
			s_data_write = 2'bxx;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b100011)  
		begin
			aluop = 5'b00010;  
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b1;
			s_num_write = 2'b00;
			id_mem_write = 1'b0;
			s_data_write = 2'b01;
			npc_op = 3'd0;
			id_mem_to_reg = 1'b1;
		end
	else if(op_code == 6'b000100)   
		begin
			aluop = 5'b01000;
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b01;
			id_mem_write = 1'b0;
			s_data_write = 2'b00;
			npc_op = 3'd1;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b000010) 
		begin
			aluop = 5'b00000;
			id_reg_write = 1'b0;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b01;
			id_mem_write = 1'b0;
			s_data_write = 2'b01;
			npc_op = 3'd2;
			id_mem_to_reg = 1'b0;
		end
	else if(op_code == 6'b000011)  
		begin
			aluop = 5'b00000;
			id_reg_write = 1'b1;
			exSer = 1'b1;
			id_s_b = 1'b0;
			s_num_write = 2'b10;
			id_mem_write = 1'b0;
			s_data_write = 2'b10;
			npc_op = 3'd4;
			id_mem_to_reg = 1'b0;
		end
	else
		begin
			aluop = 5'bxxxxxx;
			id_reg_write = 1'b0;
			exSer = 1'bx;
			s_num_write = 2'bxx;
			id_mem_write = 1'b0;
			id_s_b = 1'bx;
			s_data_write = 2'bxx;
			npc_op = 3'dx;
			id_mem_to_reg = 1'bx;
		end
end

endmodule 

module extender(imm,exSer,id_ext_num);
   input [15:0] imm;
   input exSer;
   output reg [31:0]id_ext_num;


always @(*)
begin
  if(exSer == 0)
     id_ext_num = {16'b0000000000000000,imm};
  else if(exSer == 1)
     if($signed(imm) >= 0)
	   id_ext_num =  {16'b0000000000000000,imm};
	 else 
	   id_ext_num =  {16'b1111111111111111,imm};
  else
       id_ext_num = 32'bxxxxxxxxxxxxxxxx;
end

endmodule

module gpr(clock,reg_write,instruction,num_write,data_write,a,b);
  output [31:0] a;
  output [31:0] b;
  input clock;
  input reg_write;
  input [31:0] instruction;
  input [4:0] num_write;   //写寄存器
  input [31:0] data_write; // 写数据
  wire [4:0]rs;
  wire [4:0]rt;
  assign rs = instruction[25:21];
  assign rt = instruction[20:16];
  reg [31:0] gp_registers[31:0];

always @(posedge clock)
begin
    if(reg_write && num_write)  
        gp_registers[num_write] <=data_write;
    else
		gp_registers[num_write] <= gp_registers[num_write];
end

assign a=(rs==0)?32'h0:gp_registers[rs];
assign b=(rt==0)?32'h0:gp_registers[rt];

endmodule



module id_exe(clock,reset,pc_write, 
		id_pc,data1,data2,ext_imm, rw,aluop,id_s_b, id_reg_write,id_mem_write,s_data_write,rs,rt,id_mem_to_reg,flush,
		ex_pc,ddata1,ddata2,dext_imm,drw,naluop,ns_b,nreg_write,nmem_write,ns_data_write,nrs,nrt,ex_mem_to_reg,mem_flush);
    input clock;
	input reset;
	input pc_write;
    input [31:0]id_pc;
	input [31:0]data1;
	input [31:0]data2;
	input [31:0]ext_imm;
	input [4:0] rw;
	input [4:0] aluop;
	input id_s_b;
	input id_reg_write;
	input id_mem_write;
	input [1:0] s_data_write;
	input [4:0] rs;
	input [4:0] rt;
	input  id_mem_to_reg;
	input flush;
	output  reg [31:0] ex_pc;
    output  reg [31:0] ddata1;
    output  reg [31:0] ddata2;
    output  reg [31:0] dext_imm;
    output  reg [4:0]  drw;
	output  reg [4:0] naluop;
	output reg ns_b;
	output reg nreg_write;
	output reg nmem_write;
	output reg [1:0]ns_data_write;
	output reg [4:0] nrs;
	output reg [4:0] nrt;
	output reg ex_mem_to_reg;
	output reg mem_flush;
always@(posedge clock , negedge reset)
begin
	if((!pc_write)||(!reset))
    begin
		ex_pc = 32'd0;
		ddata1 = 32'd0 ;
		ddata2 =32'd0 ;
		dext_imm = 32'd0;
		drw = 5'd0;
		naluop = 5'd0;
		ns_b =1'd0;
		nreg_write = 1'd0;
		nmem_write = 1'd0;
		ns_data_write = 2'd0;
		nrs = 5'd0;
		nrt = 5'd0;
		ex_mem_to_reg = 1'd0;
	end
	else
	begin
		ex_pc = id_pc;
		ddata1 = data1 ;
		ddata2 = data2 ;
		dext_imm = ext_imm;
		drw = rw;
		naluop = aluop;
		ns_b = id_s_b;
		nreg_write = id_reg_write;
		nmem_write = id_mem_write;
		ns_data_write = s_data_write;
		nrs = rs;
		nrt = rt;
		ex_mem_to_reg = id_mem_to_reg;
		mem_flush = flush;
	end
end
endmodule 


module if_id(clock, reset, pc_write, pc4, inst,IF_ID_flush, id_pc, dinst,EXE_flush);
	input 	clock;
    input 	reset;
	input   pc_write;
	input [31:0] pc4; 
    input [31:0] inst;   //输入要保存的信号 pc4和inst
	input IF_ID_flush;
	output reg [31:0] id_pc; 
	output reg [31:0] dinst;  //pc4转为dpc4, inst转为dinst
	output reg  EXE_flush;
	always @(posedge clock,negedge reset) begin
		if(!reset || IF_ID_flush)
		begin
			id_pc <= 32'h0000_0000;
			dinst <= 32'h0000_0000;
			EXE_flush <= 1'b1;
		end
		else if(pc_write)
		begin
			id_pc <= pc4;
			dinst <= inst;
			EXE_flush <= 1'b0;
		end
	end
	

endmodule


module im(instruction,pc);
  
  output [31:0] instruction;
  input [31:0] pc;
  
  reg [31:0] ins_memory[1023:0];

  wire [9:0] temp;
  
  assign temp = pc[11:2];
  
  assign  instruction = ins_memory[temp];  
  
  

endmodule


module  mem_wb(clock,reset,pc_write,
		mem_pc,mem_alu_result,data,rw,reg_write,s_data_write,
	    wb_pc, wb_alu_result, ddata, drw, out_reg_write, out_s_data_write);
    input clock;
	input reset;
	input pc_write;
    input [31:0] mem_pc;
	input [31:0] mem_alu_result;
	input [31:0] data;
	input [4:0] rw;
	input reg_write;
	input [1:0]s_data_write;
	
	output reg [31:0] wb_pc;
	output reg [31:0] wb_alu_result;
	output reg [31:0] ddata;
	output reg [4:0] drw;
	output reg out_reg_write;
	output reg [1:0]out_s_data_write;

	always @(posedge clock,negedge reset)
	begin
		if(!reset)
		begin
			wb_pc = 32'h0000_0000;
			wb_alu_result = 32'h0000_0000;
			ddata = 32'h0000_0000;
			drw = 5'b00000;
			out_reg_write = 1'b0;
			out_s_data_write = 2'b00;
		end
		else if(pc_write)
		begin
			wb_pc = mem_pc;
			wb_alu_result = mem_alu_result;
			ddata = data;
			drw = rw;
			out_reg_write = reg_write;
			out_s_data_write = s_data_write;
		end

	end
	
endmodule 



module mux2#(parameter WIDTH=32)(
input [WIDTH-1:0] a,
input [WIDTH-1:0] b,
input select,
output reg [WIDTH-1:0] r
    );
    always @*
    begin
      case(select)
        1'b0:
        r=a;
        1'b1:
        r=b;
      endcase
    end
endmodule


module mux3#(parameter WIDTH=32)(
input [WIDTH-1:0] a,
input [WIDTH-1:0] b,
input [WIDTH-1:0] c,
input [1:0]select,
output reg [WIDTH-1:0] r
    );
    always @*
    begin
      case(select)
        2'd0:
        r=a;
        2'd1:
        r=b;
		2'd2:
		r=c;
      endcase
    end
endmodule



module npc(pc,id_pc,id_ext_num,inster,busa,npc_op,zero_flag,npc);
  input [31:0]pc;
  input [31:0]id_pc;
  input [31:0]id_ext_num;
  input [25:0]inster;
  input [31:0]busa;
  input [2:0]npc_op;
  input zero_flag;
  output  [31:0]npc;
  
  reg [31:0]out_npc;
  
  assign npc = out_npc;

	always@(*)
	begin
	case(npc_op)
	    3'd0: out_npc = pc+4;
		3'd1: 
		    begin
		    if(!zero_flag)
			    out_npc = pc +4;
			else
			    out_npc = id_pc+4+(id_ext_num << 2);
		    end
		3'd2: out_npc = {id_pc[31:28],inster,2'b00};
		3'd3: out_npc = busa;
		3'd4: out_npc = {id_pc[31:28],inster,2'b00};
		default : out_npc = pc+4;
	endcase
	end

endmodule


module pc(pc,clock,reset,pc_write,npc);
    output reg [31:0] pc;
	input clock;
	input reset;
	input pc_write;
	input [31:0]npc;

	always @(posedge clock,negedge reset)
	    begin
		if(!reset)
		    begin
		        pc <= 32'h00003000;
			end
		else 
		    begin
				if(pc_write)
				pc <= npc;
			end
	    end
endmodule


module forward(
	wb_rw,mem_rw,ex_rw,exe_rs,exe_rt,rs,rt,nreg_write,mem_reg_write,wb_reg_write,ex_mem_to_reg,mem_mem_to_reg,Npcop,eflush,flush,reg1Data,reg2Data,
	pc_write,s_forwardA,s_forwardB,s_forwardA2,s_forwardB2,IF_ID_flush,zero_flag_2);
        input [4:0] wb_rw;
		input [4:0] mem_rw;
		input [4:0] ex_rw;
		input [4:0] exe_rs;
		input [4:0] exe_rt;
		input [4:0] rs;
		input [4:0] rt;
		input [31:0] reg1Data;
		input [31:0] reg2Data;
		input nreg_write;
		input mem_reg_write;
		input wb_reg_write;
		input ex_mem_to_reg;
		input mem_mem_to_reg;
		input [2:0] Npcop;
		input eflush;
		input flush;
		output reg [1:0] s_forwardA;
		output reg [1:0] s_forwardB;
		output reg s_forwardA2;
		output reg s_forwardB2;
		output reg IF_ID_flush;
		output pc_write;
		output zero_flag_2;


	assign  pc_write = ~(ex_mem_to_reg & nreg_write & (ex_rw!=0) & ( (rs==ex_rw) | (rt == ex_rw))); 
	always@(*)
	begin
	    if((exe_rs == mem_rw)&&(!mem_mem_to_reg)&&(!flush))
		    s_forwardA = 2'b00;
		else if(exe_rs == wb_rw)
		    s_forwardA = 2'b01;
		else
		    s_forwardA = 2'b10;
    end

	always@(*)
	begin
	    if((exe_rt == mem_rw)&&(!mem_mem_to_reg))
		    s_forwardB = 2'b00;
		else if(exe_rt == wb_rw)
		    s_forwardB = 2'b01;
		else
		    s_forwardB = 2'b10;
	end

	always@(*)
	begin
		if(rs == wb_rw && wb_reg_write)
		    s_forwardA2 = 1'b0;
		else
            s_forwardA2 = 1'b1;
	end
	
	always @(*)
	begin
		if(rt == wb_rw && wb_reg_write)
			s_forwardB2 = 1'b0;
		else
            s_forwardB2 = 1'b1;
	end
	
	always @(*)
	begin
		if(Npcop > 3'd1)
			IF_ID_flush = 1'b1;
		else if(Npcop == 3'd1&&(reg1Data==reg2Data))
			IF_ID_flush = 1'b1;
		else
			IF_ID_flush = 1'b0;

	end

	assign zero_flag_2 = ((reg1Data == reg2Data)&&(Npcop == 3'd1)) ? 1'b1 : 1'b0;
endmodule


module dm(clock,mem_write,address,data_in,mem_mem_data);
input clock;
input mem_write;
input [31:0] address;
input [31:0] data_in;
output reg [31:0] mem_mem_data;

reg [31:0] data_memory[1023:0];
wire[9:0] addr;

assign addr = address[11:2];

always @(posedge clock)
begin
    if(mem_write)
        begin
        data_memory[addr] <= data_in;
        end
	else
        begin
        data_memory[addr] <= data_memory[addr];
        end
end

always @(negedge clock)
begin
    mem_mem_data = data_memory[addr] ;
end

endmodule


module  exe_mem(clock,reset,pc_write,
				pc,ex_alu_result,data2,rw,reg_write,mem_write,s_data_write,ememtoreg,
				pc_out,alu_result_out,data2_out,rw_out,reg_write_out,mem_write_out,s_data_write_out,mmemtoreg);
    input clock;
	input reset;
	input pc_write;
    input [31:0] pc;
	input [31:0] ex_alu_result;
	input [31:0] data2;
	input [4:0] rw;
	input reg_write;
	input mem_write;
	input [1:0] s_data_write;
	input ememtoreg;
	output reg [31:0] pc_out;
	output reg [31:0] alu_result_out;
	output reg [31:0] data2_out;
	output reg [4:0] rw_out;
	output reg  reg_write_out;
	output reg mem_write_out;
	output reg [1:0]s_data_write_out;
	output reg mmemtoreg;
	
	
	always @(posedge clock,negedge reset)
	begin
		if(!reset)
		begin
			pc_out = 32'h0000_0000;
			alu_result_out = 32'h0000_0000;
			data2_out = 32'h0000_0000;
			rw_out = 5'b00000;
			reg_write_out = 1'b0;
			mem_write_out = 1'b0;
			s_data_write_out = 2'b00;
			mmemtoreg = 1'b0;
	    end
		else if(pc_write)
		begin
			pc_out = pc;
			alu_result_out = ex_alu_result;
			data2_out = data2;
			rw_out =rw;
			reg_write_out = reg_write;
			mem_write_out = mem_write;
			s_data_write_out = s_data_write;
			mmemtoreg = ememtoreg;
		end
	end
	
endmodule 