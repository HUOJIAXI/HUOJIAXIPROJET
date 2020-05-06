module display
(
	input		[3:0]		seg_data_out,									
	output		reg [8:0]	seg_led
	);
	
always@(seg_data_out )
	    begin         
		case(seg_data_out)			
	  4'b0001:    seg_led = 9'h06;
	  4'b0010:    seg_led = 9'h5b;                                           
	  4'b0011:    seg_led = 9'h4f;                                           
	  4'b0100:    seg_led = 9'h66;                                           
	  4'b0101:    seg_led = 9'h6d;                                          
	  4'b0110:    seg_led = 9'h7d;                                           
	  4'b0111:    seg_led = 9'h07;                                           
	  4'b1000:    seg_led = 9'h7f;                                           
	  4'b1001:    seg_led = 9'h6f;  

		default: seg_led = 9'h3f;
		  endcase
            end    
			
endmodule