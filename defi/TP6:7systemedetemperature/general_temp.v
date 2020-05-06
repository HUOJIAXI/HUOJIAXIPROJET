module general
(
	input clk_in,
	input rst_n_in,
	inout one_wire,
	output  [8:0] seg_led_1,
	output  [8:0] seg_led_2,
	output  [1:0] cent
);

wire [15:0] data_out;

DS18B20Z u1
(
	.clk_in(clk_in),
	.rst_n_in(rst_n_in),
	.one_wire(one_wire),
	.data_out(data_out)
);

wire [3:0] unite;
wire [3:0] dix;
wire [1:0] cent1;

decodeur_bcd u2 // Le module de conversion
(
	.clk(clk_in),
	.rst_n(rst_n_in),
	.bin(data_out[11:4]),
	.unite(unite),
	.dix(dix),
	.cent(cent1)
);
assign cent = ~cent1; // LED s'allume : 1, au contraire: 0

Decodeur u3
(
	.data_out(unite),
	.seg_led(seg_led_2)
);

Decodeur u4
(
	.data_out(dix),
	.seg_led(seg_led_1)
);

endmodule