module im(instruction,pc);

    output [31:0] instruction;
    input [31:0] pc; //输入pc为32位

    reg [31:0] ins_memory[1023:0]; //4k指令存储器

    assign instruction = ins_memory[pc[11:0]>>2]; //取指令时只取pc的低12位作为地址

endmodule