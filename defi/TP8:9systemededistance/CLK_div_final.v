module Clk_1M(clk_out, clk_in, rst);

input clk_in, rst;
output clk_out;

parameter WIDTH =12;
parameter N = 12;

reg [WIDTH-1:0] cnt_p, cnt_n;
reg clk_p,clk_n;

always @ (posedge clk_in or negedge rst)
	begin 
		if(!rst)
			cnt_p<=0;
		else if (cnt_p == (N-1))
			cnt_p<=0;
		else cnt_p <=cnt_p + 1;
	end
	
always @ (posedge clk_in or negedge rst)
	begin 
		if(!rst)
			clk_p <= 0;
		else if (cnt_p < (N>>1))
			clk_p <= 0;
		else
			clk_p <= 1;
		end
		
always @ (posedge clk_in or negedge rst)
	begin 
		if(!rst)
			cnt_n <= 0;
		else if (cnt_n == (N-1))
			cnt_n <= 0;
		else
			cnt_n <= cnt_n + 1;
		end			


always @ (posedge clk_in)
	begin 
		if(!rst)
			clk_n <= 0;
		else if (cnt_n < (N>>1))
			clk_n <= 0;
		else
			clk_n <= 1;
		end

assign clk_out = (N==1)?clk_in:(N[0])?(clk_p&clk_n):clk_p;
			

endmodule