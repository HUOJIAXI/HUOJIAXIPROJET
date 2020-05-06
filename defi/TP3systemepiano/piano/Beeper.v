module Beeper #
(
parameter	WIDTH = 16	//ensure that 2**WIDTH > cycle
)

(
input					clk_in,
input					rst_n_in,
input		[15:0] 		key_in,	
output					pwm_out
);
 
 wire [15:0] cycle_in;
 wire [15:0] duty_in;
 
tone u1
(
	.key_in  	(key_in),
	.cycle		(cycle_in)
	);
	
	assign duty_in = cycle_in >>1;

PWM u2
(
	.clk_in		(clk_in),
	.rst_n_in	(rst_n_in),
	.cycle		(cycle_in),
	.duty 		(duty_in ),
	.pwm_out	(pwm_out)
	);

endmodule