module general
(
	input					clk_in,		
	input					rst_n_in,		
	input			[3:0]	col_in,	
	output			[3:0]	row,
	output 					pwm_out
	
);

wire [15:0] key_in;

Array_KeyBoard u1
(
.clk_in					(clk_in			),
.rst_n_in				(rst_n_in		),
.col					(col_in			),
.row					(row			),
.key_out				(key_in			)
);
 
 
Beeper u2
(
.clk_in					(clk_in			),
.rst_n_in				(rst_n_in		),
.key_in				    (~key_in		),
.pwm_out				(pwm_out		)
);


endmodule