module APDS_9901_Driver
(
	input				clk,		//L'horloge
	input				rst_n,		//Initialisation
	
	output				i2c_scl,	//I2C fil principal
	inout				i2c_sda,	//I2C fil principal
	
	output	reg			dat_valid,	//Donnée de validation
	output	reg	[15:0]	ch0_dat,	//Données de ALS On a 3 types de données à récupérer par APDS9901: ch0_dat\ch1_dat\prox_dat
	output	reg	[15:0]	ch1_dat,	//Données de IR
	output	reg	[15:0]	prox_dat 	//Données de Proximité
);
	
	parameter	CNT_NUM	=	15;
	
	localparam	IDLE	=	4'd0;
	localparam	MAIN	=	4'd1;
	localparam	MODE1	=	4'd2;
	localparam	MODE2	=	4'd3;
	localparam	START	=	4'd4;
	localparam	WRITE	=	4'd5;
	localparam	READ	=	4'd6;
	localparam	STOP	=	4'd7;
	localparam	DELAY	=	4'd8;
	
	localparam	ACK		=	1'b0;
	localparam	NACK	=	1'b1;
	
	//On utlise la méthode de division pour obtenir le signal d'horloge avec fréquence 400Hz
	reg					clk_400khz;
	reg		[9:0]		cnt_400khz;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt_400khz <= 10'd0;
			clk_400khz <= 1'b0;
		end else if(cnt_400khz >= CNT_NUM-1) begin
			cnt_400khz <= 10'd0;
			clk_400khz <= ~clk_400khz;
		end else begin
			cnt_400khz <= cnt_400khz + 1'b1;
		end
	end
	
	reg scl,sda,ack,ack_flag;
	reg [3:0] cnt, cnt_main, cnt_mode1, cnt_mode2, cnt_start, cnt_write, cnt_read, cnt_stop;
	reg [7:0] data_wr, dev_addr, reg_addr, reg_data, data_r, dat_l, dat_h;
	reg [23:0] cnt_delay, num_delay;
	reg [3:0]  state, state_back;

	always@(posedge clk_400khz or negedge rst_n) begin
		if(!rst_n) begin	//Initialisation
			scl <= 1'd1; sda <= 1'd1; ack <= ACK; ack_flag <= 1'b0; cnt <= 1'b0;
			cnt_main <= 1'b0; cnt_mode1 <= 1'b0; cnt_mode2 <= 1'b0;
			cnt_start <= 1'b0; cnt_write <= 1'b0; cnt_read <= 1'b0; cnt_stop <= 1'b0;
			cnt_delay <= 1'b0; num_delay <= 24'd4800;
			state <= IDLE; state_back <= IDLE;
		end else begin
			case(state)
				IDLE:begin	//Traitement d'erreur et initialiser le programme
						scl <= 1'd1; sda <= 1'd1; ack <= ACK; ack_flag <= 1'b0; cnt <= 1'b0;
						cnt_main <= 1'b0; cnt_mode1 <= 1'b0; cnt_mode2 <= 1'b0;
						cnt_start <= 1'b0; cnt_write <= 1'b0; cnt_read <= 1'b0; cnt_stop <= 1'b0;
						cnt_delay <= 1'b0; num_delay <= 24'd4800;
						state <= MAIN; state_back <= IDLE;
					end
				MAIN:begin // L'état principal
						if(cnt_main >= 4'd14) cnt_main <= 4'd7;  	//Lire les données en intération
						else cnt_main <= cnt_main + 1'b1;	
						case(cnt_main)
							// Configuration d'écrire des données dans le capteur: dev_addr-l'addresse du capteur dans I2C(datasheet P15) reg_addr-l'addresse du registre
							// Configuration d'écrire des données sur le capteur MODE 1
							4'd0:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h00; reg_data <= 8'h00; state <= MODE1; end	
							// Enable (0000 0000)(Datasheet P14)
							4'd1:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h01; reg_data <= 8'hff; state <= MODE1; end	
							// ALS Timing Register (Datasheet P19) 
							4'd2:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h02; reg_data <= 8'hff; state <= MODE1; end	
							// Proximity Time Control Register (Datasheet P19)
							4'd3:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h03; reg_data <= 8'hff; state <= MODE1; end	
							// Wait Time Register (Datasheet P19)
							4'd4:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h0e; reg_data <= 8'h01; state <= MODE1; end	
							//Proximity Pulse Count Register(Enabled 0000 0001) (Datasheet P21)
							4'd5:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8'h0f; reg_data <= 8'h20; state <= MODE1; end	
							// Control Registre 8bits(0010 0000) (P22)
							4'd6:	begin dev_addr <= 7'h39; reg_addr <= 8'h80|8' h00; reg_data <= 8'h0f; state <= MODE1; end	
							// Enable (0000 1111) P14
							4'd7:	begin state <= DELAY; dat_valid <= 1'b0; end	//12ms temps d'attente (P14)
							// Configuration de lire des données sur le capteur MODE 2
							4'd8:	begin dev_addr <= 7'h39; reg_addr <= 8'ha0|8'h14;  state <= MODE2; end	
							// CDATA ALS Ch0 channel data low byte à lire lire
							4'd9:	begin ch0_dat <= {dat_h,dat_l}; end	
							// Lire des données Connecter le low bite et le high bite
							4'd10:	begin dev_addr <= 7'h39; reg_addr <= 8'ha0|8'h16;  state <= MODE2; end	
							//IRDATA ALS Ch1 channel data low byte à lire							
							4'd11:	begin ch1_dat <= {dat_h,dat_l}; end	
							// Lire des données Connecter le low bite et le high bite
							4'd12:	begin dev_addr <= 7'h39; reg_addr <= 8'ha0|8'h18;  state <= MODE2; end	
							//PDATA Proximity data low byte
							4'd13:	begin prox_dat <= {dat_h,dat_l}; end	
							//Lire des données Connecter le low bite et le high bite
							4'd14:	begin dat_valid <= 1'b1; end	
							//Donnée de validation (Bien lire des données)	
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
					// Pour l'état d'écriture et lecutre, vous pouvez consulter page 16 du data sheet (I2C Write/Read protocol)
				MODE1:begin	//Opération d'écriture de 1 fois
						if(cnt_mode1 >= 4'd5) cnt_mode1 <= 1'b0;	//Controler l'état d'ecriture
						else cnt_mode1 <= cnt_mode1 + 1'b1;
						state_back <= MODE1;
						case(cnt_mode1)
							4'd0:	begin state <= START; end	//I2C Passer à l'état principal
							4'd1:	begin data_wr <= dev_addr<<1; state <= WRITE; end	// On définit l'addresse du capteur(8bit->7bit)
							4'd2:	begin data_wr <= reg_addr; state <= WRITE; end	// On définit l'addresse du registre 
							4'd3:	begin data_wr <= reg_data; state <= WRITE; end	//On écrit les données
							4'd4:	begin state <= STOP; end	//I2C Passer à l'état stop
							4'd5:	begin state <= MAIN; end	//Retourner à l'état principal
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				MODE2:begin	//Opération de lire de 2 fois (Low case et High case)
						if(cnt_mode2 >= 4'd10) cnt_mode2 <= 1'b0;	//Controler l'état de lecture
						else cnt_mode2 <= cnt_mode2 + 1'b1;
						state_back <= MODE2;
						case(cnt_mode2)
							4'd0:	begin state <= START; end	//I2C Passer à l'état principal
							4'd1:	begin data_wr <= dev_addr<<1; state <= WRITE; end	// On définit l'addresse du capteur(8bit->7bit)
							4'd2:	begin data_wr <= reg_addr; state <= WRITE; end	// On définit l'addresse du registre 
							4'd3:	begin state <= START; end	//I2C Passer à l'état principal
							4'd4:	begin data_wr <= (dev_addr<<1)|8'h01; state <= WRITE; end	// On définit l'addresse du capteur(8bit->7bit)
							4'd5:	begin ack <= ACK; state <= READ; end	// Lire les données du registre
							4'd6:	begin dat_l <= data_r; end              // Low case
							4'd7:	begin ack <= NACK; state <= READ; end	//Lire les données du registre
							4'd8:	begin dat_h <= data_r; end              // High case
							4'd9:	begin state <= STOP; end	//I2C Passer à l'état stop
							4'd10:	begin state <= MAIN; end	//Retourner à l'état principal
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				START:begin	//I2C l'état de commence 
						if(cnt_start >= 3'd5) cnt_start <= 1'b0;	//Controler l'état de commence
						else cnt_start <= cnt_start + 1'b1;
						case(cnt_start)
							3'd0:	begin sda <= 1'b1; scl <= 1'b1; end	
							//Pull up SCL et SDA (reste au moins 4.7 us (P6 Characteristics of the SDA and SCL bus lines))
							3'd1:	begin sda <= 1'b1; scl <= 1'b1; end	
							//F=400Hz, T=2.5 us, donc il faut faire 2 fois l'opération de pull up le SCL et SDA
							3'd2:	begin sda <= 1'b0; end	
							//Pull down SDA (reste au moins 4.0 us (P6 Characteristics of the SDA and SCL bus lines))
							3'd3:	begin sda <= 1'b0; end	
							//F=400Hz, T=2.5 us, donc il faut faire 2 fois l'opération de Pull down SDA
							3'd4:	begin scl <= 1'b0; end	
							//Pull down SCL (reste au moins 4.7 us (P6 Characteristics of the SDA and SCL bus lines))
							3'd5:	begin scl <= 1'b0; state <= state_back; end	
							//F=400Hz, T=2.5 us, donc il faut faire 2 fois l'opération de pull down SCL, ensuite on retourne à l'état principal
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				WRITE:begin	//I2C L'état d'écriture pour écrire des données dans le capteur
						if(cnt <= 3'd6) begin	//8bits [(12) 3 4 5 6 7 8] de données à écrire, on controle le fois d'itération
							if(cnt_write >= 3'd3) begin cnt_write <= 1'b0; cnt <= cnt + 1'b1; end
							else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
						end else begin
							if(cnt_write >= 3'd7) begin cnt_write <= 1'b0; cnt <= 1'b0; end	//Initialisation
							else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
						end
						case(cnt_write)
							//Ecrire des données
							3'd0:	begin scl <= 1'b0; sda <= data_wr[7-cnt]; end	//SCL pull down, Ecrire le bit de donnée par SDA 
							3'd1:	begin scl <= 1'b1; end	//SCL pull up
							3'd2:	begin scl <= 1'b1; end	//2 fois d'opération du pull up SCL
							3'd3:	begin scl <= 1'b0; end	//SCL pull down pour écrire le prochain bit
							//Attendre la réponse du capteur
							3'd4:	begin sda <= 1'bz; end	//Free SDA pour recevoir la réponse du capteur
							3'd5:	begin scl <= 1'b1; end	//SCL pull up
							3'd6:	begin ack_flag <= i2c_sda; end	//La réponse du capteur
							3'd7:	begin scl <= 1'b0; if(ack_flag)state <= state; else state <= state_back; end 
							//SCL pull down, ecrire jusqu'à recevoir la réponse du capteur
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				READ:begin	//I2C L'état d'écriture pour lire des données dans le capteur et récupérer des données
						if(cnt <= 3'd6) begin	//8 bit à lire [(12) 3 4 5 6 7 8]
							if(cnt_read >= 3'd3) begin cnt_read <= 1'b0; cnt <= cnt + 1'b1; end
							else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
						end else begin
							if(cnt_read >= 3'd7) begin cnt_read <= 1'b0; cnt <= 1'b0; end	//Initialisation
							else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
						end
						case(cnt_read)
							//Lire des données
							3'd0:	begin scl <= 1'b0; sda <= 1'bz; end	//SCL pull down, Free SDA pour recevoir des données du capteur
							3'd1:	begin scl <= 1'b1; end	//SCL pull up pour 2*T
							3'd2:	begin data_r[7-cnt] <= i2c_sda; end	// Lire des données
							3'd3:	begin scl <= 1'b0; end	//SCL pull down pour lire le prochain bit
							//Envoyer la réponse au capteur
							3'd4:	begin sda <= ack; end	//Envoyer la réponse, stocker des données reçues
							3'd5:	begin scl <= 1'b1; end	//SCL pull up
							3'd6:	begin scl <= 1'b1; end	//2 fois
							3'd7:	begin scl <= 1'b0; state <= state_back; end	//SCL pull down, retourner à l'état principal
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				STOP:begin	//I2C Arreter la transmission
						if(cnt_stop >= 3'd5) cnt_stop <= 1'b0;	//Controler l'état
						else cnt_stop <= cnt_stop + 1'b1;
						case(cnt_stop)
							3'd0:	begin sda <= 1'b0; end	//SDA pull down pour arreter
							3'd1:	begin sda <= 1'b0; end	//2*T
							3'd2:	begin scl <= 1'b1; end	//SCL pull up pour 4.0 us
							3'd3:	begin scl <= 1'b1; end	//SCL pull up pour 4.0 us
							3'd4:	begin sda <= 1'b1; end	//SDA pull up pour 4.0 us
							3'd5:	begin sda <= 1'b1; state <= state_back; end	//Finir l'état STOP, retourner à l'état principal.
							default: state <= IDLE;	//Traitement des erreurs
						endcase
					end
				DELAY:begin	//12ms temp d'attente
						if(cnt_delay >= num_delay) begin
							cnt_delay <= 1'b0;
							state <= MAIN; 
						end else cnt_delay <= cnt_delay + 1'b1;
					end
				default:;
			endcase
		end
	end
	
	assign	i2c_scl = scl;	//Sortie de SCL
	assign	i2c_sda = sda;	//Sortie de SDA

endmodule
