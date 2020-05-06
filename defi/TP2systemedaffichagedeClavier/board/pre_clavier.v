module pre(
input 				clk_200hz,
input  [15:0]		key_out,
input rst_n_in,
output reg [8:0] 	seg_led
);

	reg 	[4:0] seg_data;
	
	
	always@( posedge clk_200hz or negedge rst_n_in)
		begin
		case(key_out)                                                   
			16'b1111_1111_1111_1110:	seg_data=5'b00001;                   
			16'b1111_1111_1111_1101:	seg_data=5'b00010;                      
			16'b1111_1111_1111_1011:	seg_data=5'b00011;     
			16'b1111_1111_1111_0111:	seg_data=5'b00100;    
			16'b1111_1111_1110_1111:	seg_data=5'b00101;
			16'b1111_1111_1101_1111:	seg_data=5'b00110;
			16'b1111_1111_1011_1111:	seg_data=5'b00111;
			16'b1111_1111_0111_1111:	seg_data=5'b01000;
			16'b1111_1110_1111_1111:	seg_data=5'b01001;
			16'b1111_1101_1111_1111:	seg_data=5'b01010;
			16'b1111_1011_1111_1111:	seg_data=5'b01011;
			16'b1111_0111_1111_1111:	seg_data=5'b01100;
			16'b1110_1111_1111_1111:	seg_data=5'b01101;
			16'b1101_1111_1111_1111:	seg_data=5'b01110;
			16'b1011_1111_1111_1111:	seg_data=5'b01111;
			16'b0111_1111_1111_1111:	seg_data=5'b00000;
			16'b1111_1111_1111_1111:	seg_data=5'b11111;
			default: seg_data=5'b11111;
		endcase
	end
	                                                                                          

	always@(key_out )
	    begin         
		case(seg_data)			
	  5'b00001:    seg_led= 9'h06;
	  5'b00010:    seg_led = 9'h5b;                                           
	  5'b00011:    seg_led = 9'h4f;                                           
	  5'b00100:  seg_led = 9'h66;                                           
	  5'b00101:   seg_led = 9'h6d;                                          
	  5'b00110:    seg_led = 9'h7d;                                           
	  5'b00111:    seg_led = 9'h07;                                           
	  5'b01000:    seg_led = 9'h7f;                                           
	  5'b01001:   seg_led = 9'h6f;  
	  5'b01010:    seg_led = 9'h77;
	  5'b01011:   seg_led = 9'h7c;
	  5'b01100:   seg_led= 9'h39;
	  5'b01101:   seg_led = 9'h5e;
	  5'b01110:  seg_led= 9'h79;
	  5'b01111:   seg_led = 9'h71;
	  5'b00000: seg_led = 9'h76;   
	  5'b11111: seg_led = 9'h3f;
		default: seg_led = 9'h3f;
		  endcase
            end                       
endmodule			