module DS18B20Z
(
	 input clk_in,
	 input rst_n_in,
	 inout one_wire,
	 output reg [15:0]data_out
	);

localparam IDLE = 3'd0;
localparam MAIN = 3'd1;
localparam INIT = 3'd2;
localparam WRITE = 3'd3;
localparam READ = 3'd4;
localparam DELAY = 3'd5;

wire clk_1mhz;

divide #(.WIDTH(32),.N(12)) clkin_1mhz (
					.clk(clk_in),
					.rst_n(rst_n_in),
					.clk_out(clk_1mhz));

	reg		[2:0]		cnt; // Compteur generale
	reg					one_wire_buffer; // Le lien entre le FPGA et le capteur
	reg		[3:0]		cnt_main;       // Compteur au sein d'etat MAIN
	reg		[7:0]		data_wr;        // Le registre pour enregistrer les donnees qui sont transmises par le FPGA
	reg		[7:0]		data_wr_buffer; // Le registre pour stocker les donnees du registre data_wr, ensuite le capteur peut lire les donnees dans le data_wr_buffer
	reg		[2:0]		cnt_init;       // Compteur au sein d'etat initial
	reg		[19:0]		cnt_delay;      // Compteur au sein d'etat delai
	reg		[19:0]		num_delay;      // Controler le temps de delai
	reg		[3:0]		cnt_write;      // Compteur au sein d'etat write
	reg		[2:0]		cnt_read;       // Compteur au sein d'etat read
	reg		[15:0]		temperature;    // Les donnees qui sont capturees par le capteur
	reg		[7:0]		temperature_buffer; // Le registre pour stocker les donnees capturees
	reg		[2:0] 		state = IDLE;
	reg		[2:0] 		state_back = IDLE;

always@(posedge clk_1mhz or negedge rst_n_in) begin
	if(!rst_n_in) begin
		state <= IDLE;
		state_back <= IDLE;
		cnt <= 1'b0;
		cnt_main <= 1'b0;
		cnt_init <= 1'b0;
		cnt_write <= 1'b0;
		cnt_read <= 1'b0;
		cnt_delay <= 1'b0;
		one_wire_buffer <= 1'bz;
		temperature <= 16'h0;

	end else begin
			case(state)
				IDLE:begin		// Inialisation
						state <= MAIN;	
						state_back <= MAIN;
						cnt <= 1'b0;
						cnt_main <= 1'b0;
						cnt_init <= 1'b0;
						cnt_write <= 1'b0;
						cnt_read <= 1'b0;
						cnt_delay <= 1'b0;
						one_wire_buffer <= 1'bz;
					end 

				MAIN:begin		// L'etat general
						if(cnt_main >= 4'd11) cnt_main <= 1'b0; // Revenir lorsque le temps passe la limite
						else cnt_main <= cnt_main + 1'b1;  // Compter
						case(cnt_main)
							4'd0: begin state <= INIT; end	 // Inialisatation
							4'd1: begin data_wr <= 8'hcc;state <= WRITE; end	// Transmettre la oommande au capteur pour commencer la test de temperature
							4'd2: begin data_wr <= 8'h44;state <= WRITE; end	// Commencer la test
							4'd3: begin num_delay <= 20'd750000;state <= DELAY;state_back <= MAIN; end // Attendre la reponse du capteur	
 
							4'd4: begin state <= INIT; end // Fin de la test, paase a l'inialisation
							4'd5: begin data_wr <= 8'hcc;state <= WRITE; end //  Transmettre la oommande au capteur pour lire de temperature
							4'd6: begin data_wr <= 8'hbe;state <= WRITE; end// Commencer de lire les donnees
 
							4'd7: begin state <= READ; end	// Passe a l'etat de lire
							4'd8: begin temperature[7:0] <= temperature_buffer; end // Lire les premieres 8 bits donnees	
 
							4'd9: begin state <= READ; end	
							4'd10: begin temperature[15:8] <= temperature_buffer; end	// Lire les derniers 8 bits donnees, au total on a 16 bits de donnees de temperature
 
							4'd11: begin state <= IDLE;data_out <= temperature; end	// Sortir les donnees et recommencer le programme
							default: state <= IDLE; // Traitement des erreurs
						endcase
					end

				INIT:begin		// Initialisation du capteur
						if(cnt_init >= 3'd6) cnt_init <= 1'b0;
						else cnt_init <= cnt_init + 1'b1;
						case(cnt_init)
							3'd0: begin one_wire_buffer <= 1'b0; end	
							3'd1: begin num_delay <= 20'd500;state <= DELAY;state_back <= INIT; end// 500 us	
							3'd2: begin one_wire_buffer <= 1'bz; end	
							3'd3: begin num_delay <= 20'd100;state <= DELAY;state_back <= INIT; end// 100 us
							3'd4: begin if(one_wire) state <= IDLE; else state <= INIT; end	// Attendre la reponse du capteur afin de savoir l'existance du capteur
							3'd5: begin num_delay <= 20'd400;state <= DELAY;state_back <= INIT; end// 400us
							3'd6: begin state <= MAIN; end	// Fin d'initialisation, passe a l'etat general
							default: state <= IDLE;
						endcase
					end

				WRITE:begin		
						if(cnt <= 3'd6) begin	// Controler le loop
							if(cnt_write >= 4'd6) begin cnt_write <= 1'b1; cnt <= cnt + 1'b1; end
							else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
						end else begin
							if(cnt_write >= 4'd8) begin cnt_write <= 1'b0; cnt <= 1'b0; end	
							else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
						end
					
						case(cnt_write)
							//lock data_wr
							4'd0: begin data_wr_buffer <= data_wr; end // Enregistrer les donnees de sortie au capteur								
							4'd1: begin one_wire_buffer <= 1'b0; end	
							4'd2: begin num_delay <= 20'd2;state <= DELAY;state_back <= WRITE; end	// 2us
							4'd3: begin one_wire_buffer <= data_wr_buffer[cnt]; end	// Transmettre les donnees au capteur
							4'd4: begin num_delay <= 20'd80;state <= DELAY;state_back <= WRITE; end	// 80us
							4'd5: begin one_wire_buffer <= 1'bz; end	
							4'd6: begin num_delay <= 20'd2;state <= DELAY;state_back <= WRITE; end	 // 2us
							4'd7: begin num_delay <= 20'd80;state <= DELAY;state_back <= WRITE; end	// 80 us
							4'd8: begin state <= MAIN; end	// Retourer a l'etat general
							default: state <= IDLE;
						endcase
					end

				READ:begin		// Controler le loop
						if(cnt <= 3'd6) begin	
							if(cnt_read >= 3'd5) begin cnt_read <= 1'b0; cnt <= cnt + 1'b1; end
							else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
						end else begin
							if(cnt_read >= 3'd6) begin cnt_read <= 1'b0; cnt <= 1'b0; end	
							else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
						end
						case(cnt_read)
						
							3'd0: begin one_wire_buffer <= 1'b0; end	
							3'd1: begin num_delay <= 20'd2;state <= DELAY;state_back <= READ; end	// 2us
							3'd2: begin one_wire_buffer <= 1'bz; end	
							3'd3: begin num_delay <= 20'd5;state <= DELAY;state_back <= READ; end	// 5us
							3'd4: begin temperature_buffer[cnt] <= one_wire; end	// Lire les donnees qui sont capturees par le capteur
							3'd5: begin num_delay <= 20'd60;state <= DELAY;state_back <= READ; end	 // 60us
							//back to main
							3'd6: begin state <= MAIN; end	
							default: state <= IDLE;
						endcase
					end

				DELAY:begin		
						if(cnt_delay >= num_delay) begin	
							cnt_delay <= 1'b0;
							state <= state_back; 	
						end else cnt_delay <= cnt_delay + 1'b1;
					end
			endcase
		end
	end
 
	assign	one_wire = one_wire_buffer; // Sortie des donnees
 
endmodule
