module ctrl(
      input [5:0] opcode,
      input [5:0] func,  
	  output reg [4:0] aluop, 
      output reg reg_write,
	  output reg Extop,
	  output reg s_b,
	  output reg [1:0]s_num_write,
	  output reg mem_write,
	  output reg [1:0]s_data_write,
	  output reg [2:0]Npcop	  
);

always@(*)
  begin
    case (opcode)
	   6'b000000:
	   begin
	    case (func)
		    6'b100000:
			begin 
			 aluop = 5'b00001;
			 Npcop = 3'd0;
			end			 
			6'b100001:
			begin 
			 aluop = 5'b00010;
			 Npcop = 3'd0;
			end
			6'b100011:
			begin 
			 aluop = 5'b00011;
			 Npcop = 3'd0;
			end   
			6'b100100:
			begin 
			 aluop = 5'b00100;
			 Npcop = 3'd0;
			end
			6'b100101:
			begin 
			 aluop = 5'b00101;
             Npcop = 3'd0;
			end
			6'b101010:
			begin 
			 aluop = 5'b00110;
			 Npcop = 3'd0;
  		    end
			6'b001000:
			begin 
			 aluop = 5'b00010;
             Npcop = 3'd3;
			end
		    default:
			begin
			 aluop = 5'bxxxxx;
			 Npcop = 3'd0;
			end
		endcase
		    reg_write = 1'b1;
			Extop = 1'bx;
			s_b = 1'b0;   
			s_num_write = 2'b01;
			mem_write = 1'b0;
			s_data_write = 2'b00;
	   end
	   6'b001000:  
		    begin
		     aluop = 5'b00010;  
			 reg_write = 1'b1;
			 Extop = 1'b1;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b00;
			 Npcop = 3'd0;
			end
		6'b001001: 
		    begin
		     aluop = 5'b00010;  
			 reg_write = 1'b1;
			 Extop = 1'b1;
			 s_b = 1'b1;   
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b0;
			 Npcop = 3'd0;
			end
		6'b001100: 
		    begin
		     aluop = 5'b00100;  
			 reg_write = 1'b1;
			 Extop = 1'b0;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b00;
			 Npcop = 3'd0;
			end
        6'b001101:
		    begin
		     aluop = 5'b00101;  
			 reg_write = 1'b1;
			 Extop = 1'b0;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b00;
			 Npcop = 3'd0;
			end
		6'b001111: 
		    begin
			 aluop = 5'b00111;  
			 reg_write = 1'b1;
			 Extop = 1'b1;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b00;
			 Npcop = 3'd0;
			end
	    6'b101011: 
		    begin 
			 aluop = 5'b00010;  
			 reg_write = 1'b0;
			 Extop = 1'b1;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b1;
			 s_data_write = 2'bxx;
			 Npcop = 3'd0;
			end
		6'b100011:  
		    begin
			 aluop = 5'b00010;  
			 reg_write = 1'b1;
			 Extop = 1'b1;
			 s_b = 1'b1;
			 s_num_write = 2'b00;
			 mem_write = 1'b0;
			 s_data_write = 2'b01;
			 Npcop = 3'd0;
			end
		6'b000100: 
		    begin
			 aluop = 5'b01000;
			 reg_write = 1'b0;
			 Extop = 1'b1;
			 s_b = 1'b0;
			 s_num_write = 2'b01;
			 mem_write = 1'b0;
			 s_data_write = 2'b00;
			 Npcop = 3'd1;
		    end
		6'b000010: 
		    begin
			 aluop = 5'b00000;
			 reg_write = 1'b0;
			 Extop = 1'b1;
			 s_b = 1'b0;
			 s_num_write = 2'b01;
			 mem_write = 1'b0;
			 s_data_write = 2'b01;
			 Npcop = 3'd2;
			end
		6'b000011: 
		    begin
			 aluop = 5'b00000;
			 reg_write = 1'b1;
			 Extop = 1'b1;
			 s_b = 1'b0;
			 s_num_write = 2'b10;
			 mem_write = 1'b0;
			 s_data_write = 2'b10;
			 Npcop = 3'd4;
			end			
		default:
		begin
		 aluop = 5'b00010;
	     reg_write = 1'b0;
		 Extop = 1'b1;
		 s_num_write = 2'b00;
		 mem_write = 1'b0;
		 s_b = 1'b0;
		 s_data_write = 2'b00;
		 Npcop = 3'd0;
		end
	endcase
end
endmodule 