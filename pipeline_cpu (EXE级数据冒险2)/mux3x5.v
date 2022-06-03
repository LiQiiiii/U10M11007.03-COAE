module mux3x5#(parameter WIDTH=5)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [1:0]select,
	output reg [WIDTH-1:0] r
    );
    always @*
    begin
		case(select)
			2'd0:
			r=a;
			2'd1:
			r=b;
			2'd2:
			r=c;
		endcase
    end
endmodule