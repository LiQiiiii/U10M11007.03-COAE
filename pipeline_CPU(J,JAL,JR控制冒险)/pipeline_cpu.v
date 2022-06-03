
module pipeline_cpu(clock,reset);
	 input clock;
     input reset;
	 
	 wire [31:0] pc;
	 wire [31:0] npc;
	 wire [31:0] if_ins;
     wire [4:0] rs;
     wire [4:0] rt;
     wire [4:0] rd;
     wire  [31:0] ex_alu_result;
     wire [31:0]  busa, alu_result_b;
	 wire [4:0] aluop;
	 wire [31:0]id_reg1Data;
	 
	 wire id_reg_write;
	 wire exSer ;
	 wire [31:0]Ext_imm32;
	 wire id_s_b;
	 wire [1:0]s_num_write;
	 wire [4:0]num_write ;
	 wire [31:0] id_reg2Data;
	 wire id_mem_write;
	 wire [1:0]s_data_write;
	 wire [31:0]data_write;
	 wire [2:0]npc_op;
	 wire zero;

	 wire [31:0] mem_reg2Data;
	wire  [31:0] id_ext_num;
	wire  [31:0] exe_pc;
	wire  [31:0] id_ins;
	wire  [31:0] ex_reg1Data;
    wire  [31:0] ex_reg2Data;
    wire  [31:0] exe_ext_imm;
    wire  [4:0]  exe_rw;
	wire  [31:0] mem_alu_result;
	wire  [31:0] mem_mem_data;
	wire  [4:0] mem_rw;
	wire  [31:0] wb_pc;
	wire  [31:0] mem_pc;
	wire  [31:0] wb_alu_result;
	wire  [31:0] wb_mem_data;
	wire  [4:0] wb_rw;
    wire  [4:0] exe_aluop;
	wire  exe_reg_write;
	wire  mem_reg_write;
	wire  wb_reg_write;
	wire  exe_s_b;
	
	wire  exe_mem_write;
	wire  mem_mem_write;
	wire  [1:0]exe_s_data_write;
	wire  [1:0]mem_s_data_write;
	wire  [1:0]wb_s_data_write;
	wire [31:0]s_wb_pc;
	wire [4:0]exe_rs;
	wire [4:0]exe_rt;
	wire [1:0]s_forwardA;
	wire [1:0]s_forwardB;
	wire [31:0] for_ex_reg1Data;
	wire [31:0] for_ex_reg2Data;
	wire pc_write;
	wire mem_pc_write;
	assign mem_pc_write = 1'b1;
	wire id_mem_to_reg;
	wire exe_mtor;
	wire mem_mtor;
	wire s_forwardA2;
	wire s_forwardB2;
	wire [31:0] for_id_reg1data;
	wire [31:0] for_id_reg2data;
	wire IF_ID_flush;
	wire EXE_flush;
	wire mem_flush;

     assign rs = id_ins[25:21];  
     assign rt = id_ins[20:16]; 
     assign rd = id_ins[15:11]; 

    assign s_wb_pc = wb_pc+4;


	 pc PC(pc,clock,reset,pc_write,npc);//ok
	 npc NPC(pc,id_ext_num,Ext_imm32,id_ins[25:0],for_id_reg1data,npc_op,zero,npc);//ok
	 im IM(if_ins,pc);//ok
	 if_id IF_ID(pc,if_ins,clock,reset,IF_ID_flush,pc_write,EXE_flush,id_ext_num,id_ins);//ok
	 ctrl CTRL(id_ins[31:26],id_ins[5:0],aluop,id_reg_write,exSer,id_s_b,s_num_write,id_mem_write,s_data_write,npc_op,id_mem_to_reg);//ok
	 ext EXT(id_ins[15:0],exSer,Ext_imm32);//ok
	 gpr GPR(for_id_reg1data,for_id_reg2data,clock,wb_reg_write,id_ins,wb_rw,data_write); //ok
     id_exe ID_EXE(clock,reset,id_ext_num,id_reg1Data,id_reg2Data,Ext_imm32,num_write,aluop,id_s_b,id_reg_write,id_mem_write,s_data_write,rs,rt,id_mem_to_reg,pc_write,EXE_flush,
	 exe_pc,ex_reg1Data,ex_reg2Data,exe_ext_imm,exe_rw,exe_aluop,exe_s_b,exe_reg_write,exe_mem_write,exe_s_data_write,exe_rs,exe_rt,exe_mtor,mem_flush);
	 pipe_ctrl2 CTRL2(wb_rw,mem_rw,exe_rw,exe_rs,exe_rt,rs,rt,exe_reg_write,mem_reg_write,wb_reg_write,exe_mtor,mem_mtor,npc_op,EXE_flush,mem_flush,
	 s_forwardA,s_forwardB,s_forwardA2,s_forwardB2,IF_ID_flush,pc_write);
	 alu ALU(ex_alu_result,zero,for_ex_reg1Data,alu_result_b,exe_aluop);//ok
	 exe_mem EXE_MEM(clock,reset,exe_pc,ex_alu_result,for_ex_reg2Data,exe_rw,exe_reg_write,exe_mem_write,exe_s_data_write,exe_mtor,mem_pc_write,
	              mem_pc,mem_alu_result,mem_mem_data,mem_rw,mem_reg_write,mem_mem_write,mem_s_data_write,mem_mtor);
	 dm DM(mem_reg2Data,clock,mem_mem_write,mem_alu_result,mem_mem_data);//ok
	 mem_wb MEM_WB(clock,reset,mem_pc,mem_alu_result,mem_reg2Data,mem_rw,mem_reg_write,mem_s_data_write,mem_pc_write,
	              wb_pc,wb_alu_result,wb_mem_data,wb_rw,wb_reg_write,wb_s_data_write);//ok
	 mux3 #(32) MUX3(wb_alu_result,wb_mem_data,s_wb_pc,wb_s_data_write,data_write);//ok
	 mux3 #(5)  MUX1(rt,rd,32'b1111_1111_1111_1111_1111_1111_1111_1111,s_num_write,num_write);//ok
	 mux3 #(32) MUX4(mem_alu_result,data_write,ex_reg1Data,s_forwardA,for_ex_reg1Data);//ok
	 mux3 #(32) MUX5(mem_alu_result,data_write,ex_reg2Data,s_forwardB,for_ex_reg2Data);//ok
	 mux2  MUX2(for_ex_reg2Data,exe_ext_imm,exe_s_b,alu_result_b);//ok
	
	mux2  MUX6 (data_write,for_id_reg1data,s_forwardA2,id_reg1Data);//ok
	 mux2  MUX7(data_write,for_id_reg2data,s_forwardB2,id_reg2Data);//ok
	  
endmodule



module pipe_ctrl2(
        input [4:0] hai,
		input [4:0] ha,
		input [4:0] h,
		input [4:0] nrs,
		input [4:0] nrt,
		input [4:0] rs,
		input [4:0] rt,
		input nreg_write,
		input nnreg_write,
		input wb_reg_write,
		input ememtor,
		input mmemtor,
		input [2:0] npc_op,
		input eflu,
		input flu,
		output reg [1:0] s_forwardA,
		output reg [1:0] s_forwardB,
		output reg s_forwardA2,
		output reg s_forwardB2,
		output reg IF_ID_flush,
		output pc_write
	   );
	  
	assign  pc_write = ~(ememtor & nreg_write & (h!=0) & ( (rs==h) | (rt == h))); 
	always@(*)
	  begin
	    if((nrs == ha)&&(!mmemtor)&&(!flu))
		  s_forwardA = 2'b00;
		else if(nrs == hai)
		  s_forwardA = 2'b01;
		else
		  s_forwardA = 2'b10;
      end
	  
	always@(*)
	   begin
	    if((nrt == ha)&&(!mmemtor)&&(!flu)&&(!eflu))
		  s_forwardB = 2'b00;
		else if(nrt == hai)
		  s_forwardB = 2'b01;
		else
		  s_forwardB = 2'b10;
	   end

	always@(*)
	  begin
		  if(rs == hai && wb_reg_write)
		   s_forwardA2 = 1'b0;
		  else
           s_forwardA2 = 1'b1;
	  end
	
	always @(*)
	 begin
		 if(rt == hai && wb_reg_write)
		   s_forwardB2 = 1'b0;
		  else
           s_forwardB2 = 1'b1;
	 end

	always @(*)
	begin
		if(npc_op != 3'd0)
		  IF_ID_flush = 1'b1;
		else
		  IF_ID_flush = 1'b0;

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

module gpr(a,b,clock,reg_write,abc,num_write,data_write);
  
  output [31:0] a,b;
  input clock,reg_write;
  input [31:0] abc,data_write;
  input [4:0] num_write;

  wire [4:0]rs,rt;
  assign rs = abc[25:21];
  assign rt = abc[20:16];
  
  reg [31:0] gp_registers[31:0];
  
  always @(posedge clock)begin
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
 
 module if_id(pc4, ins, clock, reset,IF_ID_f, pc_write,EXE_f,id_ext_num, nst);

	input [31:0] pc4,ins; 
    input clock,reset,IF_ID_f,pc_write;
	output reg  EXE_f;
	output reg [31:0] id_ext_num,nst; 

	always @(posedge clock,negedge reset) begin
		if(!reset|| IF_ID_f) {id_ext_num,nst,EXE_f}<={32'h0000_0000,32'h0000_0000,1'b1};
		else if(pc_write) {id_ext_num,nst,EXE_f}<={pc4,ins,1'b0};
	end
	

endmodule
 


`define addi 5'b00001
`define addiu 5'b00010
`define subiu 5'b00011
`define andi 5'b00100
`define ori 5'b00101
`define slt 5'b00110
`define LU 5'b00111
`define zero 5'b01000

module alu(c,zero,a,b,aluop);
    output  reg [31:0] c,zero; 
	input [31:0] a,b;
    input [4:0] aluop;
	wire [31:0]as,bs;
	assign as = $signed(a);
	assign bs = $signed(b);


   always @*
   begin

    case (aluop)
	    `addi: c = as+bs;  
		`addiu: c = a+b;    
		`subiu: c = a-b;    
		`andi: c = a&b;  
 		`ori: c = a|b;    
		`slt: c = (as < bs) ? 32'd1 : 32'd10; 
		`LU: c = {b[15:0],16'b0000000000000000};
		`zero:zero = (a==b)?1'b1:1'b0;
		default: c= 32'b0000_0000;
    endcase
   end
   
    
endmodule

    module ctrl(opcode,func,aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs);
      input [5:0] opcode,func;
	  output  reg [4:0] aluop;
      output  reg reg_write,Extop,s_b,mem_write,exs;
	  output  reg [1:0]s_num_write,s_data_write;
	  output  reg [2:0]npc_op;
	  


always@(*)
  begin
    if(opcode==6'b000000)begin
	     case (func)
		     6'b100000:{aluop,npc_op,reg_write}={5'b00001,3'd0,1'b1};
			 6'b100001:{aluop,npc_op,reg_write}={5'b00010,3'd0,1'b1};
			 6'b100011:{aluop,npc_op,reg_write}={5'b00011,3'd0,1'b1};
			 6'b100100:{aluop,npc_op,reg_write}={5'b00100,3'd0,1'b1};
			 6'b100101:{aluop,npc_op,reg_write}={5'b00101,3'd0,1'b1};
			 6'b101010:{aluop,npc_op,reg_write}={5'b00110,3'd0,1'b1};
			 6'b001000:{aluop,npc_op,reg_write}={5'bxxxxx,3'd3,1'b0};
		     default:{aluop,npc_op,reg_write}={5'bxxxxx,3'd0,1'b1};
		endcase
			{Extop,s_b,s_num_write,mem_write,s_data_write,exs}={1'bx,1'b0,2'b01,1'b0,2'b00,1'b0};
		end
	else case(opcode)
	    6'b001000:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00010,1'b1,1'b1,1'b1,2'b00,1'b0,2'b00,3'd0,1'b0};
		6'b001001:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00010,1'b1,1'b1,1'b1,2'b00,1'b0,2'b0,3'd0,1'b0};
		6'b001100:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00100,1'b1,1'b0,1'b1,2'b00,1'b0,2'b00,3'd0,1'b0};
        6'b001101:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00101,1'b1,1'b0,1'b1,2'b00,1'b0,2'b00,3'd0,1'b0};
		6'b001111:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00111,1'b1,1'b1,1'b1,2'b00,1'b0,2'b00,3'd0,1'b0};
	    6'b101011:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00010,1'b0,1'b1,1'b1,2'b11,1'b1,2'bxx,3'd0,1'b0};
		6'b100011:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00010,1'b1,1'b1,1'b1,2'b00,1'b0,2'b01,3'd0,1'b1};
		6'b000100:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b01000,1'b0,1'b1,1'b0,2'b01,1'b0,2'b00,3'd1,1'b0};
		6'b000010:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00000,1'b0,1'b1,1'b0,2'b01,1'b0,2'b01,3'd2,1'b0};
		6'b000011:{aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,npc_op,exs}={5'b00000,1'b1,1'b1,1'b0,2'b10,1'b0,2'b10,3'd4,1'b0};
		default:{aluop,reg_write,Extop,s_num_write,mem_write,s_b,s_data_write,npc_op,exs}={5'bxxxxxx,1'b0,1'bx,2'bxx,1'b0,1'bx,2'bxx,3'dx,1'bx};
	endcase
end

endmodule 

module dm(data_out, clock, mem_write, address, data_in); 

	output reg [31:0] data_out; 
	input clock;
	input mem_write;
	input [31:0] address;
	input [31:0] data_in;
	reg [31:0] data_memory[1023:0]; //4K数据存储器
	always @(posedge clock) begin
   	  if (mem_write) begin
		data_memory[address[11:2]] <= data_in;
	  end
	end
   
	always @(negedge clock)	begin
		data_out = data_memory[address[11:2]];
	end
    
endmodule    

module  exe_mem(clock,reset,dpc4,busw,data2,rw,nreg_write,nmem_write,ns_data_write,ememtoreg,mem_r,ddpc4,dbusw,ddata2,drw,nnreg_write,nnmem_write,nns_data_write,mmemtoreg);
    input clock,reset;
    input [31:0] dpc4,busw,data2;
	input [4:0] rw;
	input nreg_write,nmem_write,ememtoreg,mem_r;
	input [1:0] ns_data_write;
	output reg [31:0] ddpc4,dbusw,ddata2;
	output reg [4:0] drw;
	output reg  nnreg_write,nnmem_write,mmemtoreg;
	output reg [1:0]nns_data_write;
	
	always @(posedge clock,negedge reset)
	begin
		if(~reset) {ddpc4,dbusw,ddata2,drw,nnreg_write,nnmem_write,nns_data_write,mmemtoreg}={32'h0000_0000,32'h0000_0000,32'h0000_0000,5'b00000,1'b0,1'b0,2'b00,1'b0};
		else if(mem_r) {ddpc4,dbusw,ddata2,drw,nnreg_write,nnmem_write,nns_data_write,mmemtoreg}={dpc4,busw,data2,rw,nreg_write,nmem_write,ns_data_write,ememtoreg};
	end
	
endmodule 
    
	
	module ext(imm16,Extop,Ext_imm32);
   input [15:0] imm16;
   input Extop;
   output reg [31:0]Ext_imm32;



always @(*)
begin
if(Extop)
	if($signed(imm16) >= 0)
	   Ext_imm32 =  {16'h0000,imm16};
	 else 
	   Ext_imm32 =  {16'h1111,imm16};
else
     Ext_imm32 = {16'h0000,imm16};

end


	  
endmodule



module mux2(a,b,select,r);
input [31:0] a,b;
input select;
output reg [31:0] r;

    always @*
    begin
      case(select)
        0:r=a;
        1:r=b;
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
        0:r=a;
        1:r=b;
		2:r=c;
      endcase
    end
endmodule

module mux4x32#(parameter WIDTH=32)(
input [WIDTH-1:0] a,
input [WIDTH-1:0] b,
input [WIDTH-1:0] c,
input [WIDTH-1:0] d,
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
		2'd3:
		r=d;
      endcase
    end
endmodule

module npc(pc,id_ext_num,Ext_imm32,tcn,busa,npc_op,zero,npc);
  input [31:0]pc,id_ext_num,Ext_imm32,busa;
  input [25:0]tcn;
  input [2:0]npc_op;
  input zero;
  output  [31:0]npc;
  
  reg [31:0]nnpc;
  
  assign npc = nnpc;

	always@(*)
	begin
	  case(npc_op)
	    0: nnpc = pc+4;
		1: nnpc=(zero)?pc+4+(Ext_imm32 << 2):pc+4;
		2: nnpc = {id_ext_num[31:28],tcn,2'b00};
		3: nnpc = busa;
		4: nnpc = {id_ext_num[31:28],tcn,2'b00};
		default : nnpc = pc+4;
	  endcase
	end
	    
	
	
	


endmodule

module id_exe(
    input clock,
	input reset,
    input [31:0]dpc4,
	input [31:0]data1,
	input [31:0]data2,
	input [31:0]ext_imm,
	input [4:0] rw,
	input [4:0] aluop,
	input s_b,
	input reg_write,
	input mem_write,
	input [1:0] s_data_write,
	input [4:0] rs,
	input [4:0] rt,
	input  memtoreg,
	input  pc_write,
	input flush,
	output  reg [31:0] ddpc4,
    output  reg [31:0] ddata1,
    output  reg [31:0] ddata2,
    output  reg [31:0] dext_imm,
    output  reg [4:0]  drw,
	output  reg [4:0] naluop,
	output reg ns_b,
	output reg nreg_write,
	output reg nmem_write,
	output reg [1:0]ns_data_write,
	output reg [4:0] nrs,
	output reg [4:0] nrt,
	output reg ememtoreg,
	output reg mem_flush
	
);
always@(posedge clock , negedge reset)
 begin
  if((~pc_write)||(~reset)) {ddpc4,ddata1,ddata2,dext_imm,drw,naluop,ns_b,nreg_write,nmem_write,ns_data_write,nrs,nrt,ememtoreg}={32'd0,32'd0,32'd0,32'd0,5'd0,5'd0,1'd0,1'd0,1'd0,2'd0,5'd0,5'd0,1'd0};
  else {ddpc4,ddata1,ddata2,dext_imm,drw,naluop,ns_b,nreg_write,nmem_write,ns_data_write,nrs,nrt,ememtoreg,mem_flush}={dpc4,data1,data2,ext_imm,rw,aluop,s_b,reg_write,mem_write,s_data_write,rs,rt,memtoreg,flush};
  end

endmodule	


module im(instruction,pc);
	output [31:0] instruction;
	input [31:0] pc;
	reg [31:0] ins_memory[1023:0]; //4k?????
        assign instruction[31:0] = ins_memory[pc[11:0]/4];//pc=00003000=>0000 0000 0000 0000 0011 0000 0000 0000
endmodule


module  mem_wb(clock,reset,dpc4,busw,data,rw,nnreg_write,nns_data_write,mem_r,ddpc4,dbusw,ddata,drw,nnnreg_write,nnns_data_write);
    input clock,reset;
    input [31:0] dpc4,busw,data;
	input [4:0] rw;
	input nnreg_write,mem_r;
	input [1:0]nns_data_write;
	output reg [31:0] ddpc4,dbusw,ddata;
	output reg [4:0] drw;
	output reg nnnreg_write;
	output reg [1:0]nnns_data_write;
	

	always @(posedge clock,negedge reset)
	begin
		if(~reset) {ddpc4,dbusw,ddata,drw,nnnreg_write,nnns_data_write}={32'h0000_0000,32'h0000_0000,32'h0000_0000,5'b00000,1'b0,2'b00};
		else if(mem_r) {ddpc4,dbusw,ddata,drw,nnnreg_write,nnns_data_write}={dpc4,busw,data,rw,nnreg_write,nns_data_write};
	end
	
endmodule 