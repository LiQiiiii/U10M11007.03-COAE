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
	input [4:0] rs,
	input [4:0] rt,
	input  memtoreg,
	input  wrn,
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
	output reg ememtoreg
	);

	always@(posedge clock , negedge reset)
	begin
		if((!wrn)||(!reset))
		begin
			ddpc4 = 32'd0;
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
			ememtoreg = 1'd0;
		end
		else
		begin
			ddpc4 = dpc4;
			ddata1 = data1 ;
			ddata2 = data2 ;
			dext_imm = ext_imm;
			drw = rw;
			naluop = aluop;
			ns_b = s_b;
			nreg_write = reg_write;
			nmem_write = mem_write;
			ns_data_write = s_data_write;
			nrs = rs;
			nrt = rt;
			ememtoreg = memtoreg;
		end
	end
endmodule 





	
	
	
	
 