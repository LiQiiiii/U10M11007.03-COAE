module pc(pc,clock,reset,ipc);
output reg [31:0] pc;
input clock;
input reset;
input [31:0] ipc;

always@(posedge clock,negedge reset)
begin 
  if(!reset)   
      pc<=32'h0000_3000;  
  else  
      pc<=ipc;
end

endmodule


module npc(npc,t,instr_index,offset,a,zero,s);

output reg [31:0] npc;
input [1:0]s;
input [31:0] t;
input [25:0] instr_index;
input [31:0] offset;
input [31:0] a;
input zero;

always@(*)
begin
  case(s)
    2'b00:        
          if(zero==1)
                npc=t+(offset<<2);
          else
                npc=t;
       
    2'b01: npc={t[31:28],instr_index[25:0],2'b00};
    2'b10: npc=a;
    2'b11: npc=t;
  endcase
end
endmodule

module im(instr,pc);

output [31:0] instr;
input [31:0] pc;
reg [31:0] ins_memory[1023:0];
assign instr=ins_memory[pc[11:2]];

endmodule

module gpr(a,b,clock,reg_write,num_write,rs,rt,data_write);
output [31:0] a;  
output [31:0] b;
input clock;
input reg_write;
input [4:0] rs; 
input [4:0] rt; 
input [4:0] num_write; 
input [31:0] data_write; 
reg [31:0] gp_registers[31:0]; 

always@(posedge clock)
begin
  if(reg_write)    
      if(num_write!=0)
          gp_registers[num_write]<=data_write;          
end

assign a = (rs == 0) ? 32'd0 : gp_registers[rs];
assign b = (rt == 0) ? 32'd0 : gp_registers[rt];

endmodule


module dm(data_out,clock,mem_write,address,data_in); 

output [31:0] data_out; 
input clock;
input mem_write;
input [31:0] address;
input [31:0] data_in;
reg [31:0] data_memory[1023:0]; 

assign data_out=data_memory[address[11:2]];

always@(posedge clock)
begin
    if(mem_write)
        data_memory[address[11:2]]<=data_in ;   
end

endmodule


module ctrl(snpc,regdst,aluscr,extiop,mem_write,mem2reg,reg_write,aluop,op,funct);
output reg reg_write;
output reg [1:0] regdst;
output reg aluscr;
output reg [4:0] aluop;
output reg extiop;
output reg mem_write;
output reg [1:0] mem2reg;
output reg [1:0] snpc;
input [5:0] op;
input [5:0] funct; 

always@(*)
begin
{aluop,reg_write,regdst,aluscr,extiop,mem_write,mem2reg,snpc}={5'b00000,1'b1,2'b01,1'b0,1'b0,1'b0,2'b01,2'b11};
  case(op)
    6'b000000:
     begin
        case(funct)
            6'b100001: {aluop,reg_write}= {5'b00000,1'b1};
            6'b100011: {aluop,reg_write}= {5'b00001,1'b1};
            6'b100000: {aluop,reg_write}= {5'b00010,1'b1};
            6'b100100: {aluop,reg_write}= {5'b00011,1'b1};
            6'b100101: {aluop,reg_write}= {5'b00100,1'b1};
            6'b101010: {aluop,reg_write}= {5'b00101,1'b1};
            6'b001000: snpc=2'b10;
        endcase
     end
    6'b001000: {aluop,regdst,aluscr,extiop}={5'b00110,2'b00,1'b1,1'b1};
    6'b001001: {aluop,regdst,aluscr,extiop}={5'b00111,2'b00,1'b1,1'b1};
    6'b001100: {aluop,regdst,aluscr}={5'b01000,2'b00,1'b1};
    6'b001101: {aluop,regdst,aluscr}={5'b01001,2'b00,1'b1};
    6'b001111: {aluop,regdst,aluscr}={5'b01010,2'b00,1'b1};
    6'b101011: {aluop,regdst,reg_write,aluscr,extiop,mem_write}={5'b00110,2'b00,1'b0,1'b1,1'b1,1'b1};
    6'b100011: {aluop,regdst,reg_write,aluscr,extiop,mem2reg}={5'b00110,2'b00,1'b1,1'b1,1'b1,2'b10};
    6'b000100: {aluop,reg_write,aluscr,extiop,snpc}={5'b00001,1'b0,1'b0,1'b1,2'b00};
    6'b000010: {reg_write,snpc}={1'b0,2'b01};
    6'b000011: {mem2reg,snpc,regdst}={2'b00,2'b01,2'b10};
  endcase
end


endmodule

module alu(zero,c,a,b,aluop);



output reg [31:0] c;
output zero;

input [31:0] a;
input [4:0] aluop;
input [31:0] b;


always@(*)
begin
  case(aluop)
    5'b00000: c=a+b;
    5'b00001: c=a-b;
    5'b00010: c=a+b;
    5'b00011: c=a&b;
    5'b00100: c=a|b;
    5'b00101: c=((a^32'h80000000)<(b^32'h80000000))? 1:0; 
    5'b00110: c=a+b;
    5'b00111: c=a+b;
    5'b01000: c=a&b;
    5'b01001: c=a|b;
    5'b01010: c=b<<16;
  endcase
end

assign zero=(c==0)? 1:0;

endmodule

module s_cycle_cpu(clock,reset);

input clock;
input reset;

wire [31:0] pc;
wire [31:0] t;
wire [31:0] n_pc;
wire [31:0] instr;
wire reg_write;
wire [1:0] regdst;
wire aluscr;
wire extiop;
wire [1:0] mem2reg;
wire mem_write;
wire [1:0] snpc;
wire zero;

wire [31:0] a,c;
wire [31:0] b;
wire [31:0] alu_b;
wire [4:0] alu_op;
reg [31:0] data_write;
wire [31:0] mem_out;

wire [4:0] rs;
wire [4:0] rt = instr[20:16];
wire [4:0] rd = instr[15:11];
wire [5:0] opcode=instr[31:26];
wire [5:0] funct=instr[5:0];
reg [4:0] num_write;
wire [15:0] ime16=instr[15:0];
wire [31:0] ime32;
wire [25:0] instr_index=instr[25:0];

assign rs = instr[25:21];
assign t=pc+4;

assign alu_b=(aluscr==1)? ime32:b;
assign ime32=(extiop==1)? {{16{ime16[15]}}, ime16}:{{16{1'b0}},ime16};


always@(*)
begin
  case(regdst)
    2'b00: num_write=rt;
    2'b01: num_write=rd;
    2'b10: num_write=5'b11111;
  endcase
end

always@(*)
begin
  case(mem2reg)
    2'b00: data_write=t;
    2'b01: data_write=c;
    2'b10: data_write=mem_out;
  endcase
end

pc PC(pc,clock,reset,n_pc);
im IM(instr,pc);
gpr GPR(a,b,clock,reg_write,num_write,rs,rt,data_write);
alu ALU(zero,c,a,alu_b,alu_op);
ctrl CTRL(snpc,regdst,aluscr,extiop,mem_write,mem2reg,reg_write,alu_op,opcode,funct);
dm DM(mem_out,clock,mem_write,c,b);
npc NPC(n_pc,t,instr_index,ime32,a,zero,snpc);

endmodule
