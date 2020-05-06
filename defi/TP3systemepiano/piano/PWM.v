module PWM #
(
parameter	WIDTH = 16	//ensure that 2**WIDTH > cycle
)
(
input					clk_in,
input					rst_n_in,
input		[WIDTH-1:0]	cycle,	//cycle > duty
input		[WIDTH-1:0]	duty,	//duty < cycle
output					pwm_out
);

reg   [WIDTH-1:0] cnt;

reg   wave;           


always @(posedge clk_in or negedge rst_n_in)
	begin
	if(!rst_n_in)
		cnt <= 0;
	else if(cnt<cycle-1)   
		cnt <= cnt + 1;
	else 
		cnt <= 0;
	end
	
always @(posedge clk_in or negedge rst_n_in)
	begin
	if(!rst_n_in) 
             
	wave <= 0;
	else if(cnt<duty)
		wave <= 1;
	else 
	wave <= 0;
	
	end

assign  pwm_out = wave;   

endmodule


