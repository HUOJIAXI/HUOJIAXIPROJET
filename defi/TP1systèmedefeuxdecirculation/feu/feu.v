module feu
(
	clk1h,    
	rst_n,  
	out		     
);
 
	input clk1h;
	input rst_n;     
	output	reg[5:0]	out;
 
	parameter      	S1 = 4'b00,   
			S2 = 4'b01,
			S3 = 4'b10,
			S4 = 4'b11;
 
	parameter	time_s1 = 4'd15, 
			time_s2 = 4'd3,
			time_s3 = 4'd10,
			time_s4 = 4'd3;

	//controler le feu
	parameter	led_s1 = 6'b101011, 
				led_s2 = 6'b110011, 
				led_s3 = 6'b011101, 
				led_s4 = 6'b011110; //L'adresse des LEDs pour indiquer les feux
 
	reg 	[3:0] 	timecont;
	reg 	[1:0] 	cur_state,next_state;  
 
	wire			clk1h;  //1Hz
 

	//previous state to current state. Juger le status
	always @ (posedge clk1h or negedge rst_n)
	begin
		if(!rst_n) 
			cur_state <= S1; //current state to next state
        else 
			cur_state <= next_state;
	end

	//judgemnt of the translate of states 
	always @ (cur_state or rst_n or timecont)
	begin
		if(!rst_n) begin
		        next_state = S1;
			end
		else begin
			case(cur_state)
				S1:begin
					if(timecont==1) 
						next_state = S2;
					else 
						next_state = S1;
				end
 
                S2:begin
					if(timecont==1) 
						next_state = S3;
					else 
						next_state = S2;
				end
 
                S3:begin
					if(timecont==1) 
						next_state = S4;
					else 
						next_state = S3;
				end
 
                S4:begin
					if(timecont==1) 
						next_state = S1;
					else 
						next_state = S4;
				end
 
				default: next_state = S1;
			endcase
		end
	end

	//output of previous state
	always @ (posedge clk1h or negedge rst_n)
	begin
		if(!rst_n==1) begin
			out <= led_s1;
			timecont <= time_s1;
			end 
		else begin
			case(next_state)
				S1:begin
					out <= led_s1;
					if(timecont == 1) 
						timecont <= time_s1;
					else 
						timecont <= timecont - 1;
				end
 
				S2:begin
					out <= led_s2;
					if(timecont == 1) 
						timecont <= time_s2;
					else 
						timecont <= timecont - 1;
				end
 
				S3:begin
					out <= led_s3;
					if(timecont == 1) 
						timecont <= time_s3;
					else 
						timecont <= timecont - 1;
				end
 
				S4:begin
					out <= led_s4;
					if(timecont == 1) 
						timecont <= time_s4;
					else 
						timecont <= timecont - 1;
				end
 
				default:begin
					out <= led_s1;
					end
			endcase
		end
	end
endmodule