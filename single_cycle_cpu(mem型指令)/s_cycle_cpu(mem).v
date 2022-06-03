
module im(instr,pc);
output [31:0] instr;
input [31:0] pc;
reg [31:0] ins_memory[1023:0];
wire[11:0] t;
assign t=pc[11:0];
assign instr=ins_memory[t/4];
endmodule


module gpr(a,b,clock,reg_write,num_write,rs,rt,data_write,op);
output [31:0] a;  
output [31:0] b;
input clock;
input reg_write;
input [5:0] op;
input [4:0] rs; 
input [4:0] rt; 
input [4:0] num_write; 
input [31:0] data_write;
reg [31:0] gp_registers[31:0]; 
always @(posedge clock)
	if(reg_write && num_write)
		gp_registers[num_write] <= data_write;
assign a=gp_registers[rs];
assign b=gp_registers[rt];
endmodule

module dm(data_out,clock,mem_write,address,data_in); 
    input clock;
    input mem_write;
    input [31:0] address;
    input [31:0] data_in;
    output [31:0] data_out; 
    reg [31:0] data_memory[1023:0];

    always @(posedge clock)
        begin
            if(mem_write)
                begin
                    data_memory[address[11:2]] = data_in;
                end
        end
    assign data_out = data_memory[address>>2];
endmodule

module ctrl(reg_write,aluop,extiop,RegDst,ALUSrc,MemtoReg,mem_write,op,funct);
    output reg reg_write;
    output reg [4:0] aluop;
    output reg extiop, RegDst, ALUSrc, MemtoReg, mem_write;
    input [5:0] op;
    input [5:0] funct; 

    always @(*)begin
        if(op == 6'b000000)begin   
            case(funct)
                6'b100000: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00000};
                6'b100001: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00001};
                6'b100011: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00010};
                6'b100100: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00011};
                6'b100101: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00100};
                6'b101010: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 5'b00101};
            endcase
        end
        else begin
            case(op)
                 6'b001000: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 5'b00000};
                 6'b001001: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 5'b00001};
                 6'b001100: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 5'b00011};
                 6'b001101: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 5'b00100};
                 6'b001111: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 5'b01010};
                 6'b101011: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 5'b00000};
                 6'b100011: {reg_write, extiop, RegDst, ALUSrc, MemtoReg, mem_write, aluop} = {1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 5'b00000};
            endcase
        end
    end

endmodule


module alu(c,a,b,aluop);
    output signed [31:0] c;
    input signed [31:0] a;
    input signed [31:0] b;
    input [4:0] aluop;

    reg [31:0] c;
    always @(a or b or aluop) begin
        case(aluop)
            5'b00000: c = a + b;
            5'b00001: c =  $signed(a) + $signed(b);
            5'b00010: c = a - b;
            5'b00011: c = a & b;
            5'b00100: c = a | b;
            5'b00101: c = (a < b) ? 32'd1 : 32'd0;   
            5'b01010: c = b << 16;
           default : c = 0;
        endcase
    end

endmodule


module exti(ime16, ime32, extiop);
    input [15:0] ime16;
    input extiop;
    output [31:0] ime32;

    assign ime32 = (extiop == 0) ? {16'h0000, ime16} : {{16{ime16[15]}}, ime16};
endmodule

module pc(pc,clock,reset,npc);
    output reg [31:0] pc;
    input clock;
    input reset;
    input [31:0] npc;

    always @(posedge clock, negedge reset)
        begin
            if(!reset)
                pc = 32'h00003000;
            else
                pc = npc;
        end
endmodule

module mux2(data0, data1, data_out, op);
     input [31:0] data0, data1;
     input op;
     output [31:0] data_out;
     assign data_out = op ? data1 : data0;
endmodule

module s_cycle_cpu(clock,reset);
    input clock;
    input reset;

    wire [31:0] pc, npc;
    wire [31:0] instr;
    wire [4:0] rs, rt, rd;
    wire [31:0] a, b, ALU_b, c;
    wire [5:0] op, funct;
    wire [15:0] ime16;
    wire [31:0] ime32;
    wire [4:0] num_write;
    wire [31:0] data_in;
    wire [31:0] address;
    wire [31:0] data_out;
    wire [31:0] data_write;

    wire [4:0] aluop;
    wire extiop;
    wire RegDst;
    wire ALUSrc;
    wire reg_write;
    wire mem_write;
    wire MemtoReg;

    pc PC(pc, clock, reset, npc);
    im IM(instr, pc);
    dm DM(data_out, clock, mem_write, c, b);
    alu ALU(c, a, ALU_b, aluop);
    gpr GPR(a, b, clock, reg_write, num_write, rs, rt, data_write, op);
    ctrl CTRL(reg_write, aluop, extiop, RegDst, ALUSrc, MemtoReg, mem_write, op, funct);
    exti EXTI(ime16, ime32, extiop);

    mux2 REG_DST_MUX(rt, rd, num_write, RegDst);
    mux2 ALU_SRC_MUX(b, ime32, ALU_b, ALUSrc);
    mux2 REG_WRITE_MUX(c, data_out, data_write, MemtoReg);


    assign npc = pc + 4;
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign op = instr[31:26];
    assign funct = instr[5:0];
    assign ime16 = instr[15:0];

endmodule