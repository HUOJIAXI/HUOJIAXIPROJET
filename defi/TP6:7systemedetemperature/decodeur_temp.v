module Decodeur
(
	 data_out,
	 seg_led
);
		input [3:0] data_out;
		output reg [8:0] seg_led;
	
	always@(data_out)
		begin
		case(data_out)
			4'b0000: 		seg_led = 9'h3f;
			4'b0001:    	seg_led = 9'h06;
			4'b0010:    	seg_led = 9'h5b;                                           
			4'b0011:    	seg_led = 9'h4f;                                           
			4'b0100:  		seg_led = 9'h66;                                           
			4'b0101:   		seg_led = 9'h6d;                                          
			4'b0110:   		seg_led = 9'h7d;                                           
			4'b0111:    	seg_led = 9'h07;                                           
			4'b1000:    	seg_led = 9'h7f;                                           
			4'b1001:   		seg_led = 9'h6f;  
			4'b1010:    	seg_led = 9'h77;
			4'b1011:   		seg_led = 9'h7c;
			4'b1100:   		seg_led = 9'h39;
			4'b1101:   		seg_led = 9'h5e;
			4'b1110:  		seg_led = 9'h79;
			4'b1111:   		seg_led = 9'h71;
				default:seg_led = 9'h3f ;
			endcase
		end

	endmodule