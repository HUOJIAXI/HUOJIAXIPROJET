 
Compte rendu TP3_Défi 
Conception du FPGA système de piano électronique basé sur clavier matriciel 4*4 et bipeur





HUO JIAXI


Enseignant : DELEMOTTE Emmanuel
                            



                                        23/11/2019


Table des matières 
1.    TRAVAIL A REALISER    3
1.    INTRODUCTION    3
1.2    THEORIE DE CONTROLE    5
1.3    MODULE DE CLAVIER MATRICIEL    6
1.4    MODULE DE BIPEUR    8
1.    Module de signal MLI    9
2.    Module de déchiffreur    10
1.5    MODULE GENERAL    11
2.    RESULTAT FINAL :    12
3.    BILAN    14


 
1.    Travail à réaliser
1.    Introduction
Dans le dernier TP, j’ai effectué la conception du système de clavier matriciel 4*4. Le clavier matriciel peut être utilisé dans plusieurs domaines. Dans ce TP, je vais appliquer le clavier matriciel sur le piano électronique, celui qui est naturellement contrôlé par le FPGA système. 
Pour réaliser la fonctionnalité de piano électronique, il faut choisir un dispositif qui peut émettre des sons. Donc le bipeur est le dispositif qui est le plus abordable, celui qui peut émettre des sons selon la fréquence de signaux d’entrée. (Figure 1)
 
Figure 1
En consultant la fiche technique de bipeur, le tableau est présenté ci-dessous, celui qui indiquer la correspondance entre différentes syllabes et fréquence d'oscillation du bipeur :
 
Afin de réaliser cette conception, il faut savoir les travaux en suite :
1.    Pour contrôler le bipeur, la fréquence de signal d’entrée est contrôlée par le système. Donc le système devrait émettre le signal de commande MLI (modulation de largeur d'impulsions) pour contrôler la fréquence et la syllabe qui est émette par le bipeur.
2.    Généralement, la syllabe de bipeur est commandée par le clavier. Le bipeur émet différentes syllabes à l'aide de différents boutons enfoncés par l'utilisateur. Mais le signal de sortie de clavier matriciel n’associe pas avec le signal de commande MLI. Donc entre eux, il faut appliquer un déchiffreur, celui qui permet la transmission entre le 16-bit signal de sortie de clavier et le signal de commande MLI. 
3.    Afin de contrôler l'ensemble du système, je dois écrire un fichier de niveau supérieur afin de lier plusieurs modules (MLI, déchiffreur, clavier).
4.    Enfin je décrire une modélisation de cette conception générale : (Figure 2))
 
Figure 2

1.2    Théorie de contrôle 
1.    Introduction de bipeur
Le bipeur est divisé par 2 types : bipeur active et bipeur passive
Bipeur actif : Le bipeur active n'a besoin que d'ajouter une tension continue nominale à sa borne d'alimentation et son oscillateur interne peut générer un signal de fréquence fixe pour que le bipeur émette un son.
Bipeur passif : Le bipeur passive est nécessaire d’ajouter un signal électrique haut et bas à sa borne d’alimentation pour entraîner le son. 
Dans ce TP, j’utilise le bipeur passive afin de réaliser la conception de piano électronique.
2.    Contrôle de Bipeur
Pour contrôler le bipeur, le FPGA doit entrer des signaux d'impulsion de différentes fréquences dans le module de bipeur. C'est pourquoi j’utilise les signaux MLI. Le module de signal MLI peut contrôler la génération d'un signal d'impulsion (pwm_out) à contrôle de période et à temps contrôlé, basé sur deux signaux d'entrée (cycle, service), qui peuvent être utilisés pour piloter le circuit de bipeur passif.

1.3    Module de clavier matriciel
Généralement, le système de piano électronique est divisé par 2 parties : le module de clavier matriciel et module de bipeur. 
Le module de clavier matriciel a cité le contenu de TP précédent :
1.    module Array_KeyBoard #  
2.    (  
3.        parameter           NUM_FOR_200HZ = 60000     
4.    )  
5.    (  
6.        input                   clk_in,       
7.        input                   rst_n_in,         
8.        input           [3:0]   col,      
9.          
10.        output  reg     [3:0]   row,              
11.        output  reg     [15:0]  key_out       
12.    );  
13.      
14.        localparam          STATE0 = 2'b00;  
15.        localparam          STATE1 = 2'b01;  
16.        localparam          STATE2 = 2'b10;  
17.        localparam          STATE3 = 2'b11;  
18.       
19.          
20.        reg     [15:0]      cnt;  
21.        reg                 clk_200hz;  
22.        always@(posedge clk_in or negedge rst_n_in) begin  
23.            if(!rst_n_in) begin       
24.                cnt <= 16'd0;  
25.                clk_200hz <= 1'b0;  
26.            end else begin  
27.                if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin    
28.                    cnt <= 16'd0;  
29.                    clk_200hz <= ~clk_200hz;   
30.                end else begin  
31.                    cnt <= cnt + 1'b1;  
32.                    clk_200hz <= clk_200hz;  
33.                end  
34.            end  
35.        end  
36.       
37.        reg     [1:0]       c_state;  
38.      
39.        always@(posedge clk_200hz or negedge rst_n_in) begin  
40.            if(!rst_n_in) begin  
41.                c_state <= STATE0;  
42.                row <= 4'b1110;  
43.            end else begin  
44.                case(c_state)  
45.                    STATE0: begin c_state <= STATE1; row <= 4'b1101; end    
46.                    STATE1: begin c_state <= STATE2; row <= 4'b1011; end  
47.                    STATE2: begin c_state <= STATE3; row <= 4'b0111; end  
48.                    STATE3: begin c_state <= STATE0; row <= 4'b1110; end  
49.                    default:begin c_state <= STATE0; row <= 4'b1110; end  
50.                endcase  
51.            end  
52.        end  
53.       
54.      
55.        always@(negedge clk_200hz or negedge rst_n_in) begin  
56.            if(!rst_n_in) begin  
57.                key_out <= 16'hffff;  
58.            end else begin  
59.                case(c_state)  
60.                    STATE0:key_out[3:0] <= col;        
61.                    STATE1:key_out[7:4] <= col;  
62.                    STATE2:key_out[11:8] <= col;  
63.                    STATE3:key_out[15:12] <= col;  
64.                    default:key_out <= 16'hffff;  
65.                endcase  
66.            end  
67.        end  
68.       
69.    endmodule 

1.4    Module de bipeur
Le module de bipeur inclure 2 sous-parties : module de signal MLI et module de déchiffreur. Les 2 sous-parties sont connectées par le module de bipeur, celui qui peut référencer les deux sous-parties :
1.    module Beeper #  
2.    (  
3.    parameter   WIDTH = 16  //ensure that 2**WIDTH > cycle  
4.    )  
5.      
6.    (  
7.    input                   clk_in,  
8.    input                   rst_n_in,  
9.    input       [15:0]      key_in,   
10.    output                  pwm_out  
11.    );  
12.       
13.     wire [15:0] cycle_in;  
14.     wire [15:0] duty_in; // Les lignes entre module tone et module PWM  
15.       
16.    tone u1  
17.    (  
18.        .key_in     (key_in),  
19.        .cycle      (cycle_in)  
20.        );  
21.          
22.        assign duty_in = cycle_in >>1;  
23.      
24.    PWM u2  
25.    (  
26.        .clk_in     (clk_in),  
27.        .rst_n_in   (rst_n_in),  
28.        .cycle      (cycle_in),  
29.        .duty       (duty_in ),  
30.        .pwm_out    (pwm_out)  
31.        );  
32.      
33.    endmodule  
1.    Module de signal MLI
Le module de signal MLI est la base de conception, il entrer des signaux d’impulsion de différentes fréquences afin de contrôler la syllabe de sortie du bipeur.
La conception de signal MLI inclure les signaux d’entrée : cycle et duty.      
1.    Cycle : La valeur du compteur basée sur l'horloge système est liée à la période de génération du signal d'impulsion.
2.    Duty : Le seuil de comparaison dans le mécanisme de génération de signal d'impulsion est lié à la largeur d'impulsion (rapport cyclique) à laquelle le signal d'impulsion est généré.
Le signal d’impulsion qui alimente le bipeur ne nécessite pas trop de rapport cyclique. Donc par défaut, je défini le rapport cyclique comme 50%, c’est-à-dire que duty = cycle / 2.
Au niveau de cycle, la fréquence de signal d’impulsion devrait être défini tout d’abord, par exemple, le bipeur est exigé de générer la syllabe grave 1, donc la fréquence de signal d’impulsion est définie comme 261,6Hz, donc la valeur du compteur (cycle) = 12MHz / 261,6Hz = 45872.
1.    module PWM #  
2.    (  
3.    parameter   WIDTH = 16  
4.    )  
5.    (  
6.    input                   clk_in,  
7.    input                   rst_n_in,  
8.    input       [WIDTH-1:0] cycle,  
9.    input       [WIDTH-1:0] duty,   
10.    output                  pwm_out  
11.    );  
12.      
13.    reg   [WIDTH-1:0] cnt;  
14.      
15.    reg   wave;             
16.      
17.      
18.    always @(posedge clk_in or negedge rst_n_in)  
19.        begin  
20.        if(!rst_n_in)  
21.            cnt <= 0;  
22.        else if(cnt<cycle-1)     
23.            cnt <= cnt + 1;  
24.        else   
25.            cnt <= 0;  
26.        end  
27.          
28.    always @(posedge clk_in or negedge rst_n_in)  
29.        begin  
30.        if(!rst_n_in)   
31.                   
32.        wave <= 0;  
33.        else if(cnt<duty)  
34.            wave <= 1;  
35.        else   
36.        wave <= 0;  
37.          
38.        end  
39.      
40.    assign  pwm_out = wave;     
41.      
42.    endmodule  
2.    Module de déchiffreur
Afin de connecter le module de clavier matriciel et signal MLI, le module de déchiffreur devrait être créé. Le 16-bit signal de sortie de module de clavier matriciel key_out doit être converti en 16-bit cycle. Le 16-bit cycle est celui qui est expliqué dans le module de signal MLI :
1.    module tone   
2.    (  
3.    input       [15:0]      key_in,  
4.    output  reg [15:0]      cycle  
5.    );  
6.      
7.    always@(key_in) begin  
8.        case(key_in)  
9.            16'h0001: cycle = 16'd45872;    //L1,  
10.            16'h0002: cycle = 16'd40858;    //L2,  
11.            16'h0004: cycle = 16'd36408;    //L3,  
12.            16'h0008: cycle = 16'd34364;    //L4,  
13.            16'h0010: cycle = 16'd30612;    //L5,  
14.            16'h0020: cycle = 16'd27273;    //L6,  
15.            16'h0040: cycle = 16'd24296;    //L7,  
16.            16'h0080: cycle = 16'd22931;    //M1,  
17.            16'h0100: cycle = 16'd20432;    //M2,  
18.            16'h0200: cycle = 16'd18201;    //M3,  
19.            16'h0400: cycle = 16'd17180;    //M4,  
20.            16'h0800: cycle = 16'd15306;    //M5,  
21.            16'h1000: cycle = 16'd13636;    //M6,  
22.            16'h2000: cycle = 16'd12148;    //M7,  
23.            16'h4000: cycle = 16'd11478;    //H1,  
24.            16'h8000: cycle = 16'd10215;    //H2  
25.            default:  cycle = 16'd0;          
26.        endcase  
27.    end  
28.      
29.    endmodule  
1.5    Module Général
Le module général est le fichier de premier niveau, celui qui peut référencer tous les sous-modules. Les deux sous-modules sont le module de clavier et le module bipeur.
Grâce au module général, les signaux d’entrée clk_in, rst_n_in et col_in peuvent contrôler finalement les signaux de sortie : row et pwm_out, afin d‘émettre les syllabes.
1.    module general  
2.    (  
3.        input                   clk_in,       
4.        input                   rst_n_in,         
5.        input           [3:0]   col_in,   
6.        output          [3:0]   row,  
7.        output                  pwm_out  
8.          
9.    );  
10.      
11.    wire [15:0] key_in; //Les lignes entre les deux sous-modules  
12.      
13.    Array_KeyBoard u1  
14.    (  
15.    .clk_in                 (clk_in         ),  
16.    .rst_n_in               (rst_n_in       ),  
17.    .col                    (col_in         ),  
18.    .row                    (row            ),  
19.    .key_out                (key_in         )  
20.    );  
21.       
22.       
23.    Beeper u2  
24.    (  
25.    .clk_in                 (clk_in         ),  
26.    .rst_n_in               (rst_n_in       ),  
27.    .key_in                 (~key_in        ),  
28.    .pwm_out                (pwm_out        )  
29.    );  
30.      
31.      
32.    endmodule 

2.    Résultat final :
Les schémas des modules peuven être présentés ci-dessous :

 
                                            Figure 3 
                                        Figure 4
Dans la figure 3, on peut voir que le système général est divisé par 2 sous-modules : clavier matriciel et bipeur. Les signaux d’entrée et sortie sont vus clairement dans la figure 4. 
Enfin, Nous pouvons jouer le morceau en appuyant sur le bouton et l’effet est très bon. Par exemple, la partition de petite étoile est : 
1 1 5 5 6 6 5, 4 4 3 3 2 2 1, 5 5 4 4 3 3 2, 5 5 4 4 3 3 2
3.    Bilan
Ce qui est intéressant avec les systèmes FPGA, c’est que nous pouvons concevoir de nombreux modules intéressants par le biais de la programmation et d’appareils externes.
Dans ce TP, c’est mon premier fois d’utiliser l’instanciation du module, c’est-à-dire de référencer un ou plusieurs sous-modules dans un module, celui qui est le fichier de premier niveau. Par l’instanciation du module, les modules dans un projets peuvent être classifiés en plusieurs niveaux, celui qui rend la logique plus claire.
Tout d’abord, afin de bien fonctionner l’instanciation du module, il faut mettre en œuvre de la modélisation du projet. Il peut rendre la liaison entre les modules plus claire. 

