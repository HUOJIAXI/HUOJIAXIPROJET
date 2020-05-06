module decodeur_bcd
	(
		input clk,
		input rst_n,
		input [7:0] bin,
		output reg [3:0] unite,
		output reg [3:0] dix,
		output reg [1:0] cent
		);

reg [3:0] count;
reg[17:0] shift_reg = 18'b000000000000000000;

always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			count <= 0;
		else if (count == 9 )
			count <= 0;
		else count <= count+1;
	end
 
always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			shift_reg = 0;
		else if (count == 0)
			shift_reg = {10'b0000000000, bin};

		else if (count <= 8)
		begin 
			if(shift_reg[11:8] >= 5)
			begin 
				if(shift_reg[15:12] >= 5)
				begin
					shift_reg[15:12] = shift_reg[15:12] + 2'b11;
					shift_reg[11:8] = shift_reg[11:8] + 2'b11;
					shift_reg = shift_reg << 1;

				end
				else
				begin
					shift_reg[15:12] = shift_reg[15:12];
					shift_reg[11:8] = shift_reg[11:8] + 2'b11;
					shift_reg = shift_reg << 1;
				end
			end
			else
			begin 
				if(shift_reg[15:12] >= 5)
				begin
					shift_reg[15:12] = shift_reg[15:12] + 2'b11;
					shift_reg[11:8] = shift_reg[11:8];
					shift_reg=shift_reg << 1;
					end
				end
			end
		end

		always @(posedge clk or negedge rst_n) 
		begin
			if(!rst_n) begin
				unite <= 0;
				dix <= 0;
				cent <= 0;
			end 
			else if(count == 9) begin
				unite <= shift_reg[11:8];
				dix <= shift_reg[15:12];
				cent <= shift_reg[17:16];

			end
		end
endmodule


 