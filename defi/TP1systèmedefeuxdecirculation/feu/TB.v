`timescale 1ns/100ps

module TB;
	
     reg 		clk;
     reg 		rst_n;
  
     initial 
		begin
         clk = 1'b0;
         rst_n = 1'b0;
		end

     always #1 clk = ~clk;
     always #400 rst_n = ~rst_n;
		 
	 wire[5:0]	out;
 
 
     feu uut
     (
         .clk(clk),
         .rst_n(rst_n),
         .out(out)
     );
 
 
	endmodule
	
 