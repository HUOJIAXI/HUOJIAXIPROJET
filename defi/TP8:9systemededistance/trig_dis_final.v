module TrigSignal(clk_1m, rst, trig); 
input clk_1m, rst;
output trig;

reg trig;
reg[19:0] count;

always@(posedge clk_1m, negedge rst)
begin
    if (~rst)
        count <= 0;
    else
    begin
        if (9 == count)
        begin
            trig <= 0;
            count <= count + 1;
        end
        else 
        begin
            if (1000000 == count)
            begin
                trig <= 1;
                count <= 0;
            end
            else
                count <= count + 1;
        end
    end
end
endmodule