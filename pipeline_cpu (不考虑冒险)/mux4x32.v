module mux4x32#(parameter WIDTH=32)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [WIDTH-1:0] d,
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
		2'd3:
		r=d;
      endcase
    end
endmodule
