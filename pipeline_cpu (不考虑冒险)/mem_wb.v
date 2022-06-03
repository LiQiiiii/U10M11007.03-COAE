`include "pipe_reg.v"
`include "pipe_reg_5.v"
`include "pipe_reg_1.v"
`include "pipe_reg_6.v"
`include "pipe_reg_2.v"

module  mem_wb(
    input clock,
	input reset,
    input [31:0] dpc4,
	input [31:0] busw,
	input [31:0] data,
	input [4:0] rw,
	input nnreg_write,
	input [1:0]nns_data_write,
	output [31:0] ddpc4,
	output [31:0] dbusw,
	output [31:0] ddata,
	output [4:0] drw,
	output nnnreg_write,
	output [1:0]nnns_data_write
	);

    pipe_reg pc_3(dpc4,clock,reset,ddpc4);
	pipe_reg busw_2(busw,clock,reset,dbusw);
	pipe_reg reg_data4(data,clock,reset,ddata);
	pipe_reg_5 rw_3(rw,clock,reset,drw);
	pipe_reg_1 reg_write_3(nnreg_write,clock,reset,nnnreg_write);
	pipe_reg_2 s_data_write_3(nns_data_write,clock,reset,nnns_data_write);	
endmodule 