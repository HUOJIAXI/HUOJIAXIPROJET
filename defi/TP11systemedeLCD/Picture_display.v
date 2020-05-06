module Picture_display
(
input					clk_in,				//12MHz Fréquence d'horloge
input					rst_n_in,			//Initialisation
	
output					lcd_rst_n_out,		//Initialisation du LCD
output					lcd_bl_out,			//Contrôle de l'affichage du LCD
output					lcd_dc_out,			//Contrôle de données du LCD
output					lcd_clk_out,		//Signal de l'horloge du LCD
output					lcd_data_out		//Signal des données du LCD
);

/*
On a utlisé le FPGA pour contrôle le LCD pour afficher une image monochrome. 

On a 2 modules principaux:
1.Module de contrôle d'écran LCD en série, pour configurer des paramètres d'écran et transmettre de données;
2.RAM (132*160) module du noyau IP en FPGA，stocker des données d'image；

On transforme l'image en fichier .mem pour configurer le RAM. En suite on initialise le LCD et récupère des données 
de la RAM à l'écran LCD via la synchronisation SPI

*/

wire			ram_clk_en;
wire	[7:0]	ram_addr;
wire	[131:0]	ram_data;
//Module de contrôle d'écran LCD en série
LCD_RGB LCD_RGB_uut
(
.clk_in					(clk_in			),	//12MHz Fréquence d'horloge
.rst_n_in				(rst_n_in		),	//Initialisation

.ram_lcd_clk_en			(ram_clk_en		),	//Activer le RAM avec le signal d'horloge
.ram_lcd_addr			(ram_addr		),	//Signal de l'addresse du RAM
.ram_lcd_data			(ram_data		),	//Signal des données du RAM

.lcd_rst_n_out			(lcd_rst_n_out	),	//Initialisation du LCD
.lcd_bl_out				(lcd_bl_out		),	//Contrôle de l'affichage du LCD
.lcd_dc_out				(lcd_dc_out		),	//Contrôle de données du LCD
.lcd_clk_out			(lcd_clk_out	),	//Signal de l'horloge du LCD
.lcd_data_out			(lcd_data_out	)	//Signal des données de sortie du LCD
);

//RAM (132*160) module du noyau IP en FPGA，stocker des données d'image；
LCD_RAM LCD_RAM_uut
(
.Clock					(clk_in			),	//Signal de l'horloge
.ClockEn				(ram_clk_en		),	//Activer le RAM avec le signal d'horloge
.Reset					(!rst_n_in		),	//Initialisation du RAM
.WE						(1'b0			),	//Activer de reconfigurer le RAM, on ne reconfigure le RAM pendant l'exécution du programme
.Address				(ram_addr		),	//Signal de l'addresse du RAM
.Data					(132'b0			),	//Le signal de données d'entrée du RAM, on n'a pas de signal d'entrée du RAM
.Q						(ram_data		)	//Le signal de données de sortie du RAM
);

endmodule
