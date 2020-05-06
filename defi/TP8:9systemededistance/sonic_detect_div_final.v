module sonic_detect
(
input clk_50m, rst, Echo,
output Trig, Led,
output [3:0] centaine_pre,
output [8:0] seg_led_1,
output [8:0] seg_led_2
);
 
wire clk_1m;
wire[31:0] dis;   
reg [8:0] seg [9:0];

wire [31:0] cons1 = 32'b111010; //58
wire [31:0] cons2 = 32'b1010;   //10
wire [31:0] cons3 = 32'b1100100; //100

Clk_1M u0(.clk_in(clk_50m), .clk_out(clk_1m), .rst(1)); 

TrigSignal u1(.clk_1m(clk_1m), .rst(rst), .trig(Trig));

PosCounter u2(.clk_1m(clk_1m), .rst(rst), .echo(Echo), .dis_count(dis));

wire [31:0] distance;

div u5
(
	.a(dis),
	.b(cons1),
	.yshang(distance) // distance = dis / 58 (cm)
);

wire [3:0] unite;
wire [3:0] dizaine1, dizaine2;
wire [3:0] centaine;

assign centaine_pre = ~ centaine;

div u6
(
	.a(distance),
	.b(cons3),
	.yshang(centaine) // centaine = distance / 100
);


div u7
(
	.a(distance),
	.b(cons2),
	.yshang(dizaine1), // centaine = distance / 10
	.yyushu(unite)	   // unite = distance % 10
);

div u8
(
	.a(dizaine1),
	.b(cons2),
	.yyushu(dizaine2) // dizaine = distance /10 % 10
);

assign Led =((dizaine2 < 4'b0001)&(centaine < 4'b0001)) ? 0 : 1;

pre u3
(
	.dis(dizaine2),
	.seg_led(seg_led_1)
);

pre u4 
(
	.dis(unite),
	.seg_led(seg_led_2)
);


endmodule