module Array_KeyBoard #
(
	parameter			NUM_FOR_200HZ = 60000	
)
(
	input					clk_in,			
	input					rst_n_in,		
	input			[3:0]	col,
	output 			reg		clk_200hz,
	output	reg		[15:0]  key_out,	
	output	reg		[3:0]	row					
);

	localparam			STATE0 = 2'b00;
	localparam			STATE1 = 2'b01;
	localparam			STATE2 = 2'b10;
	localparam			STATE3 = 2'b11;
 

	reg		[15:0]		cnt;
	always@(posedge clk_in or negedge rst_n_in) begin
		if(!rst_n_in) begin		
			cnt <= 16'd0;
			clk_200hz <= 1'b0;
		end else begin
			if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin	
				cnt <= 16'd0;
				clk_200hz <= ~clk_200hz;	
			end else begin
				cnt <= cnt + 1'b1;
				clk_200hz <= clk_200hz;
			end
		end
	end
 
	reg		[1:0]		c_state;
	
	always@(posedge clk_200hz or negedge rst_n_in) begin
		if(!rst_n_in) begin
			c_state <= STATE0;
			row <= 4'b1110;
		end else begin
			case(c_state)
				STATE0: begin c_state <= STATE1; row <= 4'b1101; end	
				STATE1: begin c_state <= STATE2; row <= 4'b1011; end
				STATE2: begin c_state <= STATE3; row <= 4'b0111; end
				STATE3: begin c_state <= STATE0; row <= 4'b1110; end
				default:begin c_state <= STATE0; row <= 4'b1110; end
			endcase
		end
	end
	
 
	always@(negedge clk_200hz or negedge rst_n_in) begin
		if(!rst_n_in) begin
			key_out <= 16'hffff;
		end else begin
			case(c_state)
				STATE0:key_out[3:0] <= col;		
				STATE1:key_out[7:4] <= col;
				STATE2:key_out[11:8] <= col;
				STATE3:key_out[15:12] <= col;
				default:key_out <= 16'hffff;
			endcase
		end
	end  


 
endmodule