`include "pipe_reg.v"
`include "pipe_reg_5.v"
`include "pipe_reg_1.v"
`include "pipe_reg_6.v"
`include "pipe_reg_2.v"
module  exe_mem(
    input clock,
	input reset,
    input [31:0] dpc4,
	input [31:0] busw,
	input [31:0] data2,
	input [4:0] rw,
	input nreg_write,
	input nmem_write,
	input [1:0] ns_data_write,
	output [31:0] ddpc4,
	output [31:0] dbusw,
	output [31:0] ddata2,
	output [4:0] drw,
	output nnreg_write,
	output nnmem_write,
	output [1:0]nns_data_write	
	);
	
	pipe_reg pc_2(dpc4,clock,reset,ddpc4);
	pipe_reg busw_1(busw,clock,reset,dbusw);
	pipe_reg reg_data3(data2,clock,reset,ddata2);
	pipe_reg_5 rw_2(rw,clock,reset,drw);
    pipe_reg_1 reg_write_2(nreg_write,clock,reset,nnreg_write);
    pipe_reg_1 mem_write_2(nmem_write,clock,reset,nnmem_write);
    pipe_reg_2 s_data_write_2(ns_data_write,clock,reset,nns_data_write);
	
endmodule 