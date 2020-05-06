module Prox_Detect
(
input				clk,
input				rst_n,

output				i2c_scl,	//I2C Fil principal de horloge
inout				i2c_sda,	//I2C Fil principal de données

output		[7:0]	led			//led
);

wire dat_valid;
wire [15:0] ch0_dat, ch1_dat, prox_dat;
APDS_9901_Driver u1
(
.clk			(clk			),	//Horloge
.rst_n			(rst_n			),	//Initialisation
.i2c_scl		(i2c_scl		),	//SCL
.i2c_sda		(i2c_sda		),	//SDA

.dat_valid		(dat_valid		),	//Donnée de validation
.ch0_dat		(ch0_dat		),	//ALS
.ch1_dat		(ch1_dat		),	//IR
.prox_dat		(prox_dat		)	//Proximité
);

Decoder u2
(
.dat_valid		(dat_valid		),
.prox_dat		(prox_dat		),
.Y_out			(led			)
);

endmodule
