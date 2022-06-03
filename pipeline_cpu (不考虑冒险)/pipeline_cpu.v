`include "alu.v"
`include "im.v"
`include "dm.v"
`include "pc.v"
`include "npc.v"
`include "gpr.v"
`include "ctrl.v"
`include "ext.v"
`include "mux2x32.v"
`include "mux3x5.v"
`include "mux3x32.v"
`include "mux4x32.v"
`include "if_id.v"
`include "id_exe.v"
`include "exe_mem.v"
`include "mem_wb.v"

module pipeline_cpu(clock,reset);
    input clock;
    input reset;	 
	wire [31:0] pc,npc,nextpc;
	assign nextpc = pc+4;
	wire [31:0] instruction;
	wire [5:0] opcode,func;
    wire [4:0] rs,rt,rd;
    wire [15:0] imm16;
    wire [25:0] imm26;
    wire [31:0] imm32,imem_dout;
	wire [4:0]  rw;
    wire [31:0] busw,busa,busb;
	wire [4:0] aluop;
	wire [31:0]a;
	wire reg_write;
	wire Extop;
	wire [31:0]Ext_imm32;
	wire s_b;
	wire [1:0]s_num_write;
	wire [4:0]num_write ;
	wire [31:0] b;
	wire mem_write;
	wire [1:0]s_data_write;
	wire [31:0]data_write;
	wire [2:0]Npcop;
	wire zero;
	parameter [4:0] thirty_one = 32'd31;
	wire [31:0] data_out;
 	wire [31:0] dpc,ddpc,dinst,ddata1,ddata2,dext_imm;
    wire [4:0]  drw;
	wire [31:0] dddpc,dbusw,dddata2;
	wire [4:0] ddrw;
	wire [31:0] ddddpc,ddbusw,ddata;
	wire [4:0] dddrw;
    wire [4:0] naluop;
	wire nreg_write;
	wire nnreg_write;
	wire nnnreg_write;
	wire ns_b;
	wire nmem_write;
	wire nnmem_write;
	wire [1:0]ns_data_write;
	wire [1:0]nns_data_write;
	wire [1:0]nnns_data_write;
	assign opcode = dinst[31:26]; 
    assign func = dinst[5:0];  
    assign rs = dinst[25:21];  
    assign rt = dinst[20:16];  
    assign rd = dinst[15:11];  
    assign imm16 = dinst[15:0]; 
    assign imm26 = dinst[25:0];  
	
	pc PC(pc,clock,reset,npc);
	npc NPC(pc,Ext_imm32,imm26,a,Npcop,zero,npc);
	im IM(instruction,pc);
	if_id IF_ID(pc,instruction,clock,reset,dpc,dinst);
	ctrl CTRL(opcode,func,aluop,reg_write,Extop,s_b,s_num_write,mem_write,s_data_write,Npcop);
	mux3x5  MUX1(rt,rd,thirty_one,s_num_write,num_write);
	ext EXT(imm16,Extop,Ext_imm32);
	gpr GPR(a,b,clock,nnnreg_write,dinst,dddrw,data_write); 
    id_exe ID_EXE(clock,reset,dpc,a,b,Ext_imm32,num_write,aluop,s_b,reg_write,mem_write,s_data_write,
	ddpc,ddata1,ddata2,dext_imm,drw,naluop,ns_b,nreg_write,nmem_write,ns_data_write);
	mux2x32 MUX2(ddata2,dext_imm,ns_b,busb);
	alu ALU(busw,zero,ddata1,busb,naluop);
	exe_mem EXE_MEM(clock,reset,ddpc,busw,ddata2,drw,nreg_write,nmem_write,ns_data_write,dddpc,dbusw,dddata2,ddrw,nnreg_write,nnmem_write,nns_data_write);
	dm DM(data_out,clock,nnmem_write,dbusw,dddata2);
	mem_wb MEM_WB(clock,reset,dddpc,dbusw,data_out,ddrw,nnreg_write,nns_data_write,ddddpc,ddbusw,ddata,dddrw,nnnreg_write,nnns_data_write);
	mux3x32 MUX3(ddbusw,ddata,ddddpc,nnns_data_write,data_write);
endmodule