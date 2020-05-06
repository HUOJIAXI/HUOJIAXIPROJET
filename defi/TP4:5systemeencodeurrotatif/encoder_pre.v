module Encoder
(
	input					clk_in,			
	input					rst_n_in,		
	input					key_a,	
	input 					key_b,
	input					key_d,
	output		reg			Left_pulse,						
	output		reg 	    Right_pulse,
	output 					d_pulse
	);

localparam				NUM_500US	=	6_000;	

reg [12:0] cnt;

always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) cnt <= 0;
	else if(cnt >= NUM_500US-1) cnt <= 1'b0;
	else cnt <= cnt + 1'b1;
end
 
reg				[5:0]	cnt_20ms;
reg						key_a_r,key_a_r1;
reg						key_b_r,key_b_r1;
reg						key_d_r;

always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin
		key_a_r		<=	1'b1;
		key_a_r1	<=	1'b1;
		key_b_r		<=	1'b1;
		key_b_r1	<=	1'b1;
		cnt_20ms	<=	1'b1;
	end else if(cnt == NUM_500US-1) begin
		key_a_r		<=	key_a;
		key_a_r1	<=	key_a_r;
		key_b_r		<=	key_b;
		key_b_r1	<=	key_b_r;
	if(cnt_20ms >=6'd10) begin
		cnt_20ms <= 6'd0;
		key_d_r <= key_d;
		end
		else begin
			cnt_20ms <= cnt_20ms + 1'b1;
			key_d_r <= key_d_r;
			end
	end
end
 
 
wire	A_state		= key_a_r1 && key_a_r && key_a;	
wire	B_state		= key_b_r1 && key_b_r && key_b;	assign 	d_pulse = key_d_r && (!key_d);

 
reg						A_state_reg;

always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) A_state_reg <= 1'b1;
	else A_state_reg <= A_state;
end
 

wire	A_pos	= (!A_state_reg) && A_state;
wire	A_neg	= A_state_reg && (!A_state);
 

always@(posedge clk_in or negedge rst_n_in)begin
	if(!rst_n_in)begin
		Right_pulse <= 1'b0;
		Left_pulse <= 1'b0;
	end else begin
		if(A_pos && B_state) Left_pulse <= 1'b1;	
		else if(A_neg && B_state) Right_pulse <= 1'b1;
		else begin
			Right_pulse <= 1'b0;
			Left_pulse <= 1'b0;
		end
	end
end

endmodule