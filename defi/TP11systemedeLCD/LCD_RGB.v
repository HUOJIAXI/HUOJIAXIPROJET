module LCD_RGB #
(
	parameter LCD_W = 8'd132,			//La dimension du LCD
	parameter LCD_H = 8'd162			
)
(
	input				clk_in,			//12MHz Fréquence d'horloge
	input				rst_n_in,		//Initialisation
	
	output	reg			ram_lcd_clk_en,	//Activer le RAM avec le signal d'horloge
	output	reg	[7:0]	ram_lcd_addr,	//Signal de l'addresse du RAM
	input		[131:0]	ram_lcd_data,	//Signal des données du RAM
	
	output	reg			lcd_rst_n_out,	//Initialisation du LCD
	output	reg			lcd_bl_out,		//Contrôle de l'affichage du LCD
	output	reg			lcd_dc_out,		//Contrôle de données du LCD
	output	reg			lcd_clk_out,	//Signal de l'horloge du LCD
	output	reg			lcd_data_out	//Signal des données de sortie du LCD
);
	
	localparam			INIT_DEPTH = 16'd73; //LCD: Nombre de commandes et de données pour configurer le LCD, on a 73 commandes et données à transmettre
	
	localparam			RED		=	16'hf800;	//Rouge
	localparam			GREEN	=	16'h07e0;	//Vert
	localparam			BLUE	=	16'h001f;	//Bleu
	localparam			BLACK	=	16'h0000;	//Noir
	localparam			WHITE	=	16'hffff;	//Blanc
	localparam			YELLOW	=	16'hffe0;	//Jeune
	
	localparam			IDLE	=	3'd0;
	localparam			MAIN	=	3'd1;
	localparam			INIT	=	3'd2;
	localparam			SCAN	=	3'd3;
	localparam			WRITE	=	3'd4;
	localparam			DELAY	=	3'd5;
	
	localparam			LOW		=	1'b0;
	localparam			HIGH	=	1'b1;
	
	wire		[15:0]	color_t	=	YELLOW;		//Le couleur du haut: jeune
	wire		[15:0]	color_b	=	BLACK;		//La couleur du fond: noire
	
	reg			[7:0]	x_cnt;
	reg			[7:0]	y_cnt;
	reg			[131:0]	ram_data_r;
	
	reg			[8:0]	data_reg;				
	reg			[8:0]	reg_setxy	[10:0];
	reg			[8:0]	reg_init	[72:0];
	reg			[2:0]	cnt_main;
	reg			[2:0]	cnt_init;
	reg			[2:0]	cnt_scan;
	reg			[5:0]	cnt_write;
	reg			[15:0]	cnt_delay;
	reg			[15:0]	num_delay;
	reg			[15:0]	cnt;
	reg					high_word;
	reg			[2:0] 	state = IDLE;
	reg			[2:0] 	state_back = IDLE;
	always@(posedge clk_in or negedge rst_n_in) begin
		if(!rst_n_in) begin
			x_cnt <= 8'd0;
			y_cnt <= 8'd0;
			ram_lcd_clk_en <= 1'b0;
			ram_lcd_addr <= 8'd0;
			cnt_main <= 3'd0;
			cnt_init <= 3'd0;
			cnt_scan <= 3'd0;
			cnt_write <= 6'd0;
			cnt_delay <= 16'd0;
			num_delay <= 16'd50;
			cnt <= 16'd0;
			high_word <= 1'b1; // Pour indiguer le niveau du couleur, on a 2 niveaux du couleur à afficher
			lcd_bl_out <= LOW;
			state <= IDLE;
			state_back <= IDLE;
		end else begin
			case(state)
				IDLE:begin
						x_cnt <= 8'd0;
						y_cnt <= 8'd0;// on utilise y_cnt pour positionner les données de chaque ligne dans le RAM
						ram_lcd_clk_en <= 1'b0;
						ram_lcd_addr <= 8'd0;
						cnt_main <= 3'd0;
						cnt_init <= 3'd0;
						cnt_scan <= 3'd0;
						cnt_write <= 6'd0;
						cnt_delay <= 16'd0;
						num_delay <= 16'd50;
						cnt <= 16'd0;
						high_word <= 1'b1;
						state <= MAIN;
						state_back <= MAIN;
					end
				MAIN:begin
						case(cnt_main)	//MAIN état
							3'd0:	begin state <= INIT; cnt_main <= cnt_main + 1'b1; end
							3'd1:	begin state <= SCAN; cnt_main <= cnt_main + 1'b1; end
							3'd2:	begin cnt_main <= 1'b1; end // Actualisez l'écran de manière cyclique
							default: state <= IDLE;
						endcase
					end
				INIT:begin	//Initialisation
						case(cnt_init)
							3'd0:	begin lcd_rst_n_out <= 1'b0; cnt_init <= cnt_init + 1'b1; end	//Initialisation
							3'd1:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//Temp d'attente
							3'd2:	begin lcd_rst_n_out <= 1'b1; cnt_init <= cnt_init + 1'b1; end	//Récupération
							3'd3:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//Temp d'attente
							3'd4:	begin 
										if(cnt>=INIT_DEPTH) begin	//Après la transmission des 73 commandes et données, on finit la configuration
											cnt <= 16'd0;
											cnt_init <= cnt_init + 1'b1;
										end else begin
											data_reg <= reg_init[cnt];	
											if(cnt==16'd0) num_delay <= 16'd50000; //La première commande nécessite un long délai
											else num_delay <= 16'd50;
											cnt <= cnt + 16'd1;
											state <= WRITE;
											state_back <= INIT;
										end
									end
							3'd5:	begin cnt_init <= 1'b0; state <= MAIN; end	//Après l'initialisation, on retourne à l'état MAIN.
							default: state <= IDLE;
						endcase
					end
				SCAN:begin	//On affiche l'image par le scan d'écran LCD
						case(cnt_scan)
							3'd0:	begin //Déterminez les coordonnées de la zone de l'écran, voici le plein écran
										if(cnt >= 11) begin	//
											cnt <= 16'd0;
											cnt_scan <= cnt_scan + 1'b1;
										end else begin
											data_reg <= reg_setxy[cnt];
											cnt <= cnt + 16'd1;
											num_delay <= 16'd50;
											state <= WRITE;
											state_back <= SCAN;
										end
									end
							3'd1:	begin ram_lcd_clk_en <= HIGH; ram_lcd_addr <= y_cnt; cnt_scan <= cnt_scan + 1'b1; end	//Activer le RAM
							3'd2:	begin cnt_scan <= cnt_scan + 1'b1; end	//Délai pour une période d'horloge
							3'd3:	begin ram_lcd_clk_en <= LOW; ram_data_r <= ram_lcd_data; cnt_scan <= cnt_scan + 1'b1; end	//Récupérer les données du RAM, on désactive le RAM
							3'd4:	begin //Chaque pixel nécessite 16 bits de données, SPI transmet 8 bits à chaque fois, et transmet deux fois 8 bits hauts et 8 bits bas
										if(x_cnt>=LCD_W) begin	//Lorsqu'une donnée (une ligne d'écran) est écrite
											x_cnt <= 8'd0;	
											if(y_cnt>=LCD_H) begin y_cnt <= 8'd0; cnt_scan <= cnt_scan + 1'b1; end	//Si c'est la dernière ligne, sautez hors de la boucle
											else begin y_cnt <= y_cnt + 1'b1; cnt_scan <= 3'd1; end		//Sinon, passez à l'activation du RAM et actualisez l'écran de manière cyclique
										end else begin
											if(high_word) data_reg <= {1'b1,(ram_data_r[x_cnt]? color_t[15:8]:color_b[15:8])};	
											/*
											Selon l'état du bit correspondant, determine que la couleur du haut ou la couleur du fond sera affichée, 
											et selon l'état de high_word, détermine que les 8 bits supérieurs ou les 8 bits inférieurs seront écrits.
											*/
											else begin data_reg <= {1'b1,(ram_data_r[x_cnt]? color_t[7:0]:color_b[7:0])}; x_cnt <= x_cnt + 1'b1; end	// Passe au prochain bit
											high_word <= ~high_word;	//Changer le niveau de couleur
											num_delay <= 16'd50;	//Définir le temp d'attente
											state <= WRITE;	//Revenir à l'état WRITE
											state_back <= SCAN;	//Retour à l'état SCAN après avoir effectué les opérations WRITE et DELAY
										end
									end
							3'd5:	begin cnt_scan <= 1'b0; lcd_bl_out <= HIGH; state <= MAIN; end
							default: state <= IDLE;
						endcase
					end
				WRITE:begin	//L'état WRITE. Envoyer des données à l'écran en fonction du SPI
						if(cnt_write >= 6'd17) cnt_write <= 1'b0;
						else cnt_write <= cnt_write + 1'b1;
						case(cnt_write)
							6'd0:	begin lcd_dc_out <= data_reg[8]; end	//Le bit le plus élevé des données 9 bits est le bit de contrôle des données de commande
							6'd1:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[7]; end	//D'abord envoyer les données en high case
							6'd2:	begin lcd_clk_out <= HIGH; end
							6'd3:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[6]; end
							6'd4:	begin lcd_clk_out <= HIGH; end
							6'd5:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[5]; end
							6'd6:	begin lcd_clk_out <= HIGH; end
							6'd7:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[4]; end
							6'd8:	begin lcd_clk_out <= HIGH; end
							6'd9:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[3]; end
							6'd10:	begin lcd_clk_out <= HIGH; end
							6'd11:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[2]; end
							6'd12:	begin lcd_clk_out <= HIGH; end
							6'd13:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[1]; end
							6'd14:	begin lcd_clk_out <= HIGH; end
							6'd15:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[0]; end	//Envoyer les données en low case après
							6'd16:	begin lcd_clk_out <= HIGH; end
							6'd17:	begin lcd_clk_out <= LOW; state <= DELAY; end	
							default: state <= IDLE;
						endcase
					end
				DELAY:begin	//Délai
						if(cnt_delay >= num_delay) begin
							cnt_delay <= 16'd0;
							state <= state_back; 
						end else cnt_delay <= cnt_delay + 1'b1;
					end
				default:state <= IDLE;
			endcase
		end
	end
	
	initial	//Commandes et données pour définir la zone d'affichage
		begin
			reg_setxy[0]	=	{1'b0,8'h2a};
			reg_setxy[1]	=	{1'b1,8'h00};
			reg_setxy[2]	=	{1'b1,8'h00};
			reg_setxy[3]	=	{1'b1,8'h00};
			reg_setxy[4]	=	{1'b1,LCD_W-1};
			reg_setxy[5]	=	{1'b0,8'h2b};
			reg_setxy[6]	=	{1'b1,8'h00};
			reg_setxy[7]	=	{1'b1,8'h00};
			reg_setxy[8]	=	{1'b1,8'h00};
			reg_setxy[9]	=	{1'b1,LCD_H-1};
			reg_setxy[10]	=	{1'b0,8'h2c};
		end
	
	initial	//Commandes et données d'initialisation LCD
		begin
			reg_init[0]		=	{1'b0,8'h11}; 
			reg_init[1]		=	{1'b0,8'hb1}; 
			reg_init[2]		=	{1'b1,8'h05}; 
			reg_init[3]		=	{1'b1,8'h3c}; 
			reg_init[4]		=	{1'b1,8'h3c}; 
			reg_init[5]		=	{1'b0,8'hb2}; 
			reg_init[6]		=	{1'b1,8'h05}; 
			reg_init[7]		=	{1'b1,8'h3c}; 
			reg_init[8]		=	{1'b1,8'h3c}; 
			reg_init[9]		=	{1'b0,8'hb3}; 
			reg_init[10]	=	{1'b1,8'h05}; 
			reg_init[11]	=	{1'b1,8'h3c}; 
			reg_init[12]	=	{1'b1,8'h3c}; 
			reg_init[13]	=	{1'b1,8'h05}; 
			reg_init[14]	=	{1'b1,8'h3c}; 
			reg_init[15]	=	{1'b1,8'h3c}; 
			reg_init[16]	=	{1'b0,8'hb4}; 
			reg_init[17]	=	{1'b1,8'h03}; 
			reg_init[18]	=	{1'b0,8'hc0}; 
			reg_init[19]	=	{1'b1,8'h28}; 
			reg_init[20]	=	{1'b1,8'h08}; 
			reg_init[21]	=	{1'b1,8'h04}; 
			reg_init[22]	=	{1'b0,8'hc1}; 
			reg_init[23]	=	{1'b1,8'hc0}; 
			reg_init[24]	=	{1'b0,8'hc2}; 
			reg_init[25]	=	{1'b1,8'h0d}; 
			reg_init[26]	=	{1'b1,8'h00}; 
			reg_init[27]	=	{1'b0,8'hc3}; 
			reg_init[28]	=	{1'b1,8'h8d}; 
			reg_init[29]	=	{1'b1,8'h2a}; 
			reg_init[30]	=	{1'b0,8'hc4}; 
			reg_init[31]	=	{1'b1,8'h8d}; 
			reg_init[32]	=	{1'b1,8'hee}; 
			reg_init[32]	=	{1'b0,8'hc5}; 
			reg_init[33]	=	{1'b1,8'h1a}; 
			reg_init[34]	=	{1'b0,8'h36}; 
			reg_init[35]	=	{1'b1,8'hc0}; 
			reg_init[36]	=	{1'b0,8'he0}; 
			reg_init[37]	=	{1'b1,8'h04}; 
			reg_init[38]	=	{1'b1,8'h22}; 
			reg_init[39]	=	{1'b1,8'h07}; 
			reg_init[40]	=	{1'b1,8'h0a}; 
			reg_init[41]	=	{1'b1,8'h2e}; 
			reg_init[42]	=	{1'b1,8'h30}; 
			reg_init[43]	=	{1'b1,8'h25}; 
			reg_init[44]	=	{1'b1,8'h2a}; 
			reg_init[45]	=	{1'b1,8'h28}; 
			reg_init[46]	=	{1'b1,8'h26}; 
			reg_init[47]	=	{1'b1,8'h2e}; 
			reg_init[48]	=	{1'b1,8'h3a}; 
			reg_init[49]	=	{1'b1,8'h00}; 
			reg_init[50]	=	{1'b1,8'h01}; 
			reg_init[51]	=	{1'b1,8'h03}; 
			reg_init[52]	=	{1'b1,8'h13}; 
			reg_init[53]	=	{1'b0,8'he1}; 
			reg_init[54]	=	{1'b1,8'h04}; 
			reg_init[55]	=	{1'b1,8'h16}; 
			reg_init[56]	=	{1'b1,8'h06}; 
			reg_init[57]	=	{1'b1,8'h0d}; 
			reg_init[58]	=	{1'b1,8'h2d}; 
			reg_init[59]	=	{1'b1,8'h26}; 
			reg_init[60]	=	{1'b1,8'h23}; 
			reg_init[61]	=	{1'b1,8'h27}; 
			reg_init[62]	=	{1'b1,8'h27}; 
			reg_init[63]	=	{1'b1,8'h25}; 
			reg_init[64]	=	{1'b1,8'h2d}; 
			reg_init[65]	=	{1'b1,8'h3b}; 
			reg_init[66]	=	{1'b1,8'h00}; 
			reg_init[67]	=	{1'b1,8'h01}; 
			reg_init[68]	=	{1'b1,8'h04}; 
			reg_init[69]	=	{1'b1,8'h13}; 
			reg_init[70]	=	{1'b0,8'h3a}; 
			reg_init[71]	=	{1'b1,8'h05}; 
			reg_init[72]	=	{1'b0,8'h29}; 
			
		end
	
endmodule
