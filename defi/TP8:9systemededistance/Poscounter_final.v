module PosCounter(clk_1m, rst, echo, dis_count);
input clk_1m, rst, echo;
output[31:0] dis_count;

parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10; 
reg[1:0] curr_state, next_state;
reg echo_reg1, echo_reg2;
assign start = echo_reg1&~echo_reg2;  
assign finish = ~echo_reg1&echo_reg2; 
reg[31:0] count, dis_reg;
wire[31:0] dis_count; 

always@(posedge clk_1m, negedge rst)
begin
    if(~rst)
    begin
        echo_reg1 <= 0;
        echo_reg2 <= 0;
        count <= 0;
        dis_reg <= 0;
        curr_state <= S0;
    end
    else
    begin
        echo_reg1 <= echo;          
        echo_reg2 <= echo_reg1;     
        case(curr_state)
        S0:begin
                if (start) 
                    curr_state <= next_state; 
                else
                    count <= 0;
            end
        S1:begin
                if (finish) 
                    curr_state <= next_state; 
                else
                    begin
                        count <= count + 1;
                    end
            end
        S2:begin
                dis_reg <= count; 
                count <= 0;
                curr_state <= next_state; 
            end
        endcase
    end
end

always@(curr_state)
begin
    case(curr_state)
    S0:next_state <= S1;
    S1:next_state <= S2;
    S2:next_state <= S0;
    endcase
end

assign dis_count = dis_reg;

endmodule