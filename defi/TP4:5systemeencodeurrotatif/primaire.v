module primaire
(
	input					clk_in,			
	input					rst_n_in,		
	input					key_a,			
	input					key_b,	
	input 					key_d,
	output		[8:0]			seg_led_1,
	output		[8:0]        	seg_led_2,
	output						seg_data_d
	);

wire[7:0] seg_data_out;

wire Left_pulse_out;
wire Right_pulse_out;
wire d_pulse;

Encoder u1
(
.clk_in(clk_in),
.rst_n_in(rst_n_in),
.key_a(key_a),
.key_b(key_b),
.key_d(key_d),
.Left_pulse(Left_pulse_out),
.Right_pulse(Right_pulse_out),
.d_pulse(d_pulse)
);


Decoder u2
(
.clk_in(clk_in),
.rst_n_in(rst_n_in),
.Left_pulse(Left_pulse_out),
.Right_pulse(Right_pulse_out),
.d_pulse(d_pulse),
.seg_data(seg_data_out),
.seg_data_d(seg_data_d)
);


display u3
(
.seg_data_out(seg_data_out[7:4]),
.seg_led(seg_led_1)
);

display u4
(
.seg_data_out(seg_data_out[3:0]),
.seg_led(seg_led_2)
);

endmodule