module divide2 
(
    clk,
	rst_n,
	clk_out
    );
	
	parameter N = 3,
	WIDTH = 5;
	
	input clk,rst_n;
	output reg clk_out;
	
	reg [WIDTH:0]counter;

always @(posedge clk) begin
	if (!rst_n) begin
		// reset
		counter <= 0;
	end
	else if (counter == N-1) begin
		counter <= 0;
	end
	else begin
		counter <= counter + 1;
	end
end

always @(posedge clk) begin
	if (!rst_n) begin
		// reset
		clk_out <= 0;
	end
	else if (counter == N-1) begin
		clk_out <= !clk_out;
	end
end

endmodule
