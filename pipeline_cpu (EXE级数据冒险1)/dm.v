module dm(data_out,clock,mem_write,address,data_in);
	output reg [31:0] data_out;
	input clock;
	input mem_write;
	input [31:0] address;
	input [31:0] data_in;
	reg [31:0] data_memory[1023:0];
	wire [9:0]taddre;
	
	assign taddre = address[11:2];

	always @(posedge clock)
	begin
		if(mem_write)
		begin
			data_memory[taddre] <= data_in;
		end
		else
		begin
			data_memory[taddre] <= data_memory[taddre];
		end
	end

	always @(negedge clock)
	begin
		data_out = data_memory[taddre] ;
	end
endmodule