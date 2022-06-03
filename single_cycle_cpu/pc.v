module pc(pc,clock,reset,npc);

    output [31:0] pc;
    input clock; //时钟信号，上升沿有效
    input reset; //复位信号，下降沿有效
    input [31:0] npc; //npc=pc+4，即下一条指令的pc

    reg [31:0] data; //临时变量

    always @(posedge clock or negedge reset) //异步复位，clock上升沿有效，reset下降沿有效
        begin
            if (reset == 0) //reset信号有效时
                data <= 32'h00003000; //复位为00003000
            else
                data <= npc;
        end

    assign pc = data;

endmodule
