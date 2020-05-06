module Decoder
(
	input					clk_in,			
	input					rst_n_in,		
	input					Right_pulse,			
	input					Left_pulse,
	input 					d_pulse,
	output		reg [7:0]	seg_data,
	output 		 reg		seg_data_d
	);

always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin
		seg_data <= 8'h50;
	end else begin
		if(Left_pulse) begin
			if(seg_data[3:0]==4'd0) begin
				seg_data[3:0] <= 4'd9;
				if(seg_data[7:4]==4'd0) seg_data[7:4] <= 4'd9;
				else seg_data[7:4] <= seg_data[7:4] - 1'b1;
			end else seg_data[3:0] <= seg_data[3:0] - 1'b1;
		end else if(Right_pulse) begin
			if(seg_data[3:0]==4'd9) begin
				seg_data[3:0] <= 4'd0;
				if(seg_data[7:4]==4'd9) seg_data[7:4] <= 4'd0;
				else seg_data[7:4] <= seg_data[7:4] + 1'b1;
			end else seg_data[3:0] <= seg_data[3:0] + 1'b1;
		end else begin
			seg_data <= seg_data;
		end
	end
	
	end
	
always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin
		seg_data_d <= 8'h50;
	end 
	else 
		begin
		if(d_pulse) begin
			seg_data_d <= 1'b0;
			end
			else begin
				seg_data_d <= 1'b1;
				end
		end
	
	end
	
endmodule