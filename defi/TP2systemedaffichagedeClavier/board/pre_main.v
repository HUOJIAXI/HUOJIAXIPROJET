module main(
		input					clk_in,			
		input					rst_n_in,		
		input			[3:0]	col,	
		output			[8:0]   seg_led,	
		output			[3:0]	row		
		);
		
	wire clk_200hz;
	wire [15:0] key_out;
	
	Array_KeyBoard u1
	(
	.clk_in(clk_in),
	.rst_n_in(rst_n_in),
	.col(col),
	.row(row),
	.clk_200hz(clk_200hz),
	.key_out(key_out)
	);
	
	pre u2
	(
	.clk_200hz(clk_200hz),
	.key_out(key_out),
	.rst_n_in(rst_n_in),
	.seg_led(seg_led)
	);
		
		
		endmodule
	
	