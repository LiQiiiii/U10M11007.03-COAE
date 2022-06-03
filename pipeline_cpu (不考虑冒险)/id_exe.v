`include "pipe_reg.v"
`include "pipe_reg_5.v"
`include "pipe_reg_1.v"
`include "pipe_reg_6.v"
`include "pipe_reg_2.v"
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
	output  [31:0] ddpc4,
    output  [31:0] ddata1,
    output  [31:0] ddata2,
    output  [31:0] dext_imm,
    output  [4:0]  drw,
	output  [4:0] naluop,
	output ns_b,
	output nreg_write,
	output nmem_write,
	output [1:0]ns_data_write
);

	pipe_reg pc_1(dpc4,clock,reset,ddpc4);
	pipe_reg reg_data1(data1,clock,reset,ddata1);
	pipe_reg reg_data2(data2,clock,reset,ddata2);
	pipe_reg ext_1(ext_imm,clock,reset,dext_imm);
	pipe_reg_5 rw_1(rw,clock,reset,drw);
	pipe_reg_5 aluop_1(aluop,clock,reset,naluop);
	pipe_reg_1 s_b_1(s_b,clock,reset,ns_b);
	pipe_reg_1 reg_write_1(reg_write,clock,reset,nreg_write);
	pipe_reg_1 mem_write_1(mem_write,clock,reset,nmem_write);
	pipe_reg_2 s_data_write_1(s_data_write,clock,reset,ns_data_write);
endmodule 





	
	
	
	
 