 
Compte rendu TP2_Défi 
Conception du système d'affichage à clavier matriciel 4*4  






HUO JIAXI


Enseignant : DELEMOTTE Emmanuel
                            



                                        23/10/2019





Table de matières
1.    TRAVAIL A REALISER    3
1.1    INTRODUCTION    3
1.2    THEORIE DE CONTROLE    4
1.3    MACHINE D’ETAT    5
1.4    DIVISION D’HORLOGE    6
1.5    MACHINE D’ÉTAT    6
1.6    CODE D'AFFICHAGE    8
2.    MODULE PRINCIPAL    9
3.    RESULTAT FINAL    13
4.    BILAN    14






 

1.    Travail à réaliser
1.1    Introduction
Suite à mon dernier TP, j’ai déjà effectué la machine d’état (automate) sur la conception de feux de circulation. Notamment la machine d’état est la base de majorité de systèmes basés sur FPGA. Elle permet de la transmission entre états selon la séquence. 
Dans ce TP, j’applique la technologie de machine d’état sur la conception du système d'affichage à clavier matriciel 4*4. (Figure 1) Le clavier matriciel est commun dans la vie, par exemple, le clavier de téléphone est matriciel. Le clavier matriciel peut être appliqué sur plusieurs domaines de télécom. 
Afin de contrôler le clavier matriciel, il faut appliquer la machine d’état pour réaliser la détection de boutons sur le clavier. 
Généralement, je choisi le clavier matriciel avec 16 boutons. Dans le clavier plus de boutons, afin de réduire l'utilisation du port I / O, généralement organiser les boutons dans une forme de matrice, en utilisant des lignes de lignes et des lignes de colonne pour se connecter à l'interrupteur de clé aux deux extrémités, de sorte que nous pouvons connecter 16 boutons à travers 4 lignes et 4 colonnes (un total de 8 ports I / O) (Figure 2), et plus les boutons de l'avantage est évident. J’applique la machine d’état pour scanner tous les bouchons.
  
Figure 1                                    Figure 2

1.2     Théorie de contrôle
Dans le Figure 2, il est clair qu’il y a 4 rangs et 4 colonnes, Le VCC est 3,3V et connecte à tous les boutons.
1.    4 rangs sont les signaux d’entrée qui sont contrôlés par FPGA
2.    4 colonnes sont les signaux de sortie qui sont reçus par FPGA.
Lorsque l’état de rangs est : 
ROW1 = 0, ROW2 = 1, ROW3 = 1, ROW4 = 1 ; Les deux conditions actuelles :
1.    Pour les boutons K1, K2, K3, K4 dans le ROW1 : 
Si K1 est appuyé, FPGA peut recevoir : COL1 = 0, COL2 (3, 4) =1 ;
Si K2 est appuyé, FPGA peut recevoir : COL2 = 0, COL1 (3, 4) =1 ;
…
2.    Pour les autres boutons :
Que le bouton soit appuyé ou non, COL1=1、COL2=1、COL3=1、COL4= 1 ;
Donc, on peut trouver que dans ce moment, seulement K1, K2, K3, bouton K4 est appuyé, c’est possible que les 4 colonnes : COL1=0、COL2=0、COL3=0、COL4=0, si K4 n’est pas appuyé, COL1=1、COL2=1、COL3=1、COL4=1.
Notamment, on peut trouver le bouton qui est appuyé par détecter tous les rangs afin de trouver la seule colonne, celle qui est 0.
Au niveau de détection, la détection est divisée par 4 états, correspondant à l'une des 4 lignes, 4 états cycle à tour de rôle, complétant ainsi toute la détection d'analyse des boutons de matrice.
Pour empêcher la vibration de boutons, ainsi, la période d'échantillonnage du même bouton est supérieure à 10ms, je défini la période d’échantillonnage comme 20 ms.
1.3     Machine d’état
 
1.4     Division d’horloge
La fréquence de sortie de FPGA est 12MHz, afin d’obtenir la fréquence de 200Hz, il faut appliquer la division d’horloge sur le module. 
La méthode qui est le plus simple est d’effectuer le compteur dans la division pour compter le temps. 
1.    module Division #  
2.    (  
3.        parameter           NUM_FOR_200HZ = 60000     
4.    )  
5.      
6.    (  
7.        input                   clk_in,           
8.        input                   rst_n_in,                     
9.        output                  clk_200hz;            
10.    );  
11.      
12.        reg     [15:0]      cnt;  
13.        reg                 clk_200hz;  
14.        always@(posedge clk_in or negedge rst_n_in) begin  
15.            if(!rst_n_in) begin       
16.                cnt <= 16'd0;  
17.                clk_200hz <= 1'b0;  
18.            end else begin  
19.                if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin    
20.                    cnt <= 16'd0;  
21.                    clk_200hz <= ~clk_200hz;   
22.                end else begin  
23.                    cnt <= cnt + 1'b1;  
24.                    clk_200hz <= clk_200hz;  
25.                end  
26.            end  
27.        end  
28.      
29.    endmodule   
Ainsi, la fréquence de 200Hz est effectuée.
1.5     Machine d’état
L’algorithme est réalisé pout permettre la transmission d’états. Notamment, il faut définir les indices pour les états afin de réaliser les références entre eux.
1.    module MachineDetat #  
2.    (  
3.        input                   clk_200hz,            
4.        input                   rst_n_in,         
5.        input           [3:0]   col,              
6.        output  reg     [3:0]   row,              
7.        output  reg     [15:0]  key_out;              
8.    );  
9.      
10.        localparam          STATE0 = 2'b00;  
11.        localparam          STATE1 = 2'b01;  
12.        localparam          STATE2 = 2'b10;  
13.        localparam          STATE3 = 2'b11; // Les indices d'états  
14.      
15.      
16.        reg     [1:0]       c_state; // Le régistre d'indice d'état  
17.          
18.        always@(posedge clk_200hz or negedge rst_n_in) begin  
19.            if(!rst_n_in) begin  
20.                c_state <= STATE0;  
21.                row <= 4'b1110;  
22.            end else begin  
23.                case(c_state)  
24.                    STATE0: begin c_state <= STATE1; row <= 4'b1101; end    
25.                    STATE1: begin c_state <= STATE2; row <= 4'b1011; end  
26.                    STATE2: begin c_state <= STATE3; row <= 4'b0111; end  
27.                    STATE3: begin c_state <= STATE0; row <= 4'b1110; end  
28.                    default:begin c_state <= STATE0; row <= 4'b1110; end  
29.                endcase  
30.            end  
31.        end  
32.       
33.        always@(negedge clk_200hz or negedge rst_n_in) begin  
34.            if(!rst_n_in) begin  
35.                key_out <= 16'hffff;  
36.            end else begin  
37.                case(c_state)  
38.                    STATE0:key_out[3:0] <= col;        
39.                    STATE1:key_out[7:4] <= col;  
40.                    STATE2:key_out[11:8] <= col;  
41.                    STATE3:key_out[15:12] <= col;  
42.                    default:key_out <= 16'hffff;  
43.                endcase  
44.            end  
45.        end    
46.      
47.    endmodule  

1.6     Code d'affichage
Afin d’afficher l’indice de bouton qui est appuyé, il faut mettre en œuvre de code d’affichage.
Pour bien afficher l’indice, le tube numérique est utile. Afin d’utiliser le tube, il faut effectuer un déchiffreur dans le module.
L’indice de bouton est affiché directement lorsqu’il soit appuyé. 
1.    module Dechiffreur #  
2.    (  
3.        input                   clk_200hz,            
4.        input                   rst_n_in,  
5.        input           [15:0]  key_out                   
6.        output  reg     [15:0]  seg_led;              
7.    );  
8.      
9.    reg     [4:0] seg_data;  
10.          
11.        always@( posedge clk_200hz or negedge rst_n_in)  
12.            begin  
13.            case(key_out)                                                     
14.                16'b1111_1111_1111_1110:    seg_data=5'b00001;   //K1                  
15.                16'b1111_1111_1111_1101:    seg_data=5'b00010;   //K2                     
16.                16'b1111_1111_1111_1011:    seg_data=5'b00011;   //K3    
17.                16'b1111_1111_1111_0111:    seg_data=5'b00100;   //K4   
18.                16'b1111_1111_1110_1111:    seg_data=5'b00101;   //K5  
19.                16'b1111_1111_1101_1111:    seg_data=5'b00110;   //K6  
20.                16'b1111_1111_1011_1111:    seg_data=5'b00111;   //K7  
21.                16'b1111_1111_0111_1111:    seg_data=5'b01000;   //K8  
22.                16'b1111_1110_1111_1111:    seg_data=5'b01001;   //K9  
23.                16'b1111_1101_1111_1111:    seg_data=5'b01010;   //K10  
24.                16'b1111_1011_1111_1111:    seg_data=5'b01011;   //K11  
25.                16'b1111_0111_1111_1111:    seg_data=5'b01100;   //K12  
26.                16'b1110_1111_1111_1111:    seg_data=5'b01101;   //K13  
27.                16'b1101_1111_1111_1111:    seg_data=5'b01110;   //K14  
28.                16'b1011_1111_1111_1111:    seg_data=5'b01111;   //K15  
29.                16'b0111_1111_1111_1111:    seg_data=5'b00000;   //K16  
30.                16'b1111_1111_1111_1111:    seg_data=5'b11111;   //Aucun bonton est appuyé  
31.                default: seg_data=5'b11111;  
32.            endcase  
33.        end  
34.                                                                                                    
35.      
36.        always@(key_out) // Le déchiffreur est activé lorsque key_out change.   
37.            begin           
38.            case(seg_data)            
39.          5'b00001:     seg_led= 9'h06;   //1  
40.          5'b00010:     seg_led = 9'h5b;  //2                                           
41.          5'b00011:     seg_led = 9'h4f;  //3                                           
42.          5'b00100:     seg_led = 9'h66;  //4                                           
43.          5'b00101:     seg_led = 9'h6d;  //5                                         
44.          5'b00110:     seg_led = 9'h7d;  //6                                           
45.          5'b00111:     seg_led = 9'h07;  //7                                           
46.          5'b01000:     seg_led = 9'h7f;  //8                                           
47.          5'b01001:     seg_led = 9'h6f;  //9  
48.          5'b01010:     seg_led = 9'h77;  //A  
49.          5'b01011:     seg_led = 9'h7c;  //B  
50.          5'b01100:     seg_led=  9'h39;  //C  
51.          5'b01101:     seg_led = 9'h5e;  //D  
52.          5'b01110:     seg_led=  9'h79;  //E  
53.          5'b01111:     seg_led = 9'h71;  //F  
54.          5'b00000:     seg_led = 9'h76;  //*  
55.          5'b11111:     seg_led = 9'h3f;  //Aucun bonton est appuyé  
56.            default:    seg_led = 9'h3f;  
57.              endcase  
58.                end                         
59.            
60.       
61.    endmodule  
2.    Module Principal
Pour réaliser la fonctionnalité finale, le module principal est écrit, celui qui sera téléchargé dans le FPGA.
1.    module Array_KeyBoard #  
2.    (  
3.        parameter           NUM_FOR_200HZ = 60000     
4.    )  
5.    (  
6.        input                   clk_in,           
7.        input                   rst_n_in,         
8.        input           [3:0]   col,      
9.        output  reg     [8:0]   seg_led,      
10.        output  reg     [3:0]   row                   
11.    );  
12.      
13.        localparam          STATE0 = 2'b00;  
14.        localparam          STATE1 = 2'b01;  
15.        localparam          STATE2 = 2'b10;  
16.        localparam          STATE3 = 2'b11;  
17.       
18.      
19.        reg     [15:0]      cnt;  
20.        reg                 clk_200hz;  
21.        always@(posedge clk_in or negedge rst_n_in) begin  
22.            if(!rst_n_in) begin       
23.                cnt <= 16'd0;  
24.                clk_200hz <= 1'b0;  
25.            end else begin  
26.                if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin    
27.                    cnt <= 16'd0;  
28.                    clk_200hz <= ~clk_200hz;   
29.                end else begin  
30.                    cnt <= cnt + 1'b1;  
31.                    clk_200hz <= clk_200hz;  
32.                end  
33.            end  
34.        end  
35.       
36.        reg     [1:0]       c_state;  
37.          
38.        always@(posedge clk_200hz or negedge rst_n_in) begin  
39.            if(!rst_n_in) begin  
40.                c_state <= STATE0;  
41.                row <= 4'b1110;  
42.            end else begin  
43.                case(c_state)  
44.                    STATE0: begin c_state <= STATE1; row <= 4'b1101; end    
45.                    STATE1: begin c_state <= STATE2; row <= 4'b1011; end  
46.                    STATE2: begin c_state <= STATE3; row <= 4'b0111; end  
47.                    STATE3: begin c_state <= STATE0; row <= 4'b1110; end  
48.                    default:begin c_state <= STATE0; row <= 4'b1110; end  
49.                endcase  
50.            end  
51.        end  
52.          
53.        reg [15:0] key_out;  
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
69.        reg     [4:0] seg_data;  
70.          
71.        always@( posedge clk_200hz or negedge rst_n_in)  
72.            begin  
73.            case(key_out)                                                     
74.                16'b1111_1111_1111_1110:    seg_data=5'b00001;                     
75.                16'b1111_1111_1111_1101:    seg_data=5'b00010;                        
76.                16'b1111_1111_1111_1011:    seg_data=5'b00011;       
77.                16'b1111_1111_1111_0111:    seg_data=5'b00100;      
78.                16'b1111_1111_1110_1111:    seg_data=5'b00101;  
79.                16'b1111_1111_1101_1111:    seg_data=5'b00110;  
80.                16'b1111_1111_1011_1111:    seg_data=5'b00111;  
81.                16'b1111_1111_0111_1111:    seg_data=5'b01000;  
82.                16'b1111_1110_1111_1111:    seg_data=5'b01001;  
83.                16'b1111_1101_1111_1111:    seg_data=5'b01010;  
84.                16'b1111_1011_1111_1111:    seg_data=5'b01011;  
85.                16'b1111_0111_1111_1111:    seg_data=5'b01100;  
86.                16'b1110_1111_1111_1111:    seg_data=5'b01101;  
87.                16'b1101_1111_1111_1111:    seg_data=5'b01110;  
88.                16'b1011_1111_1111_1111:    seg_data=5'b01111;  
89.                16'b0111_1111_1111_1111:    seg_data=5'b00000;  
90.                16'b1111_1111_1111_1111:    seg_data=5'b11111;  
91.                default: seg_data=5'b11111;  
92.            endcase  
93.        end  
94.                                                                                                    
95.      
96.        always@(key_out) // Le déchiffreur est activé lorsque key_out change.   
97.            begin           
98.            case(seg_data)            
99.           5'b00001:     seg_led= 9'h06;  
100.          5'b00010:     seg_led = 9'h5b;                                             
101.          5'b00011:     seg_led = 9'h4f;                                             
102.          5'b00100:     seg_led = 9'h66;                                             
103.          5'b00101:     seg_led = 9'h6d;                                            
104.          5'b00110:     seg_led = 9'h7d;                                             
105.          5'b00111:     seg_led = 9'h07;                                             
106.          5'b01000:     seg_led = 9'h7f;                                             
107.          5'b01001:     seg_led = 9'h6f;    
108.          5'b01010:     seg_led = 9'h77;  
109.          5'b01011:     seg_led = 9'h7c;  
110.          5'b01100:     seg_led=  9'h39;  
111.          5'b01101:     seg_led = 9'h5e;  
112.          5'b01110:     seg_led=  9'h79;  
113.          5'b01111:     seg_led = 9'h71;  
114.          5'b00000:     seg_led = 9'h76;     
115.          5'b11111:     seg_led = 9'h3f;  
116.            default:    seg_led = 9'h3f;  
117.              endcase  
118.                end                         
119.            
120.       
121.    endmodule
  
3.    Résultat final
Une fois que j'appuie sur un bouton, le tube numérique affichera l’indice de ce bouton et si je libère le bouton, le tube numérique affichera la valeur par défaut de 0. (Figure 3 et Figure 4)
Lorsque j’appuie sur le bouton rst_n_in, celui qui est le bouton réinitialisation, puis j’appuie sur un bouton, le tube numérique n’affiche pas l’indice de ce bouton. De même, lorsque j’appuie sur un bouton continûment, puis j’appuie sur le bouton réinitialisation, le numéro qui est affiché dans le tube numérique reviendra à 0 (Figure 5).
  
Figure 3                                        Figure 4
 
Figure 5
4.    Bilan
Grâce à cette expérience, j'ai une compréhension plus profonde de l'application de la machine d'état, ainsi que la machine de statut dans la conception du système FPGA important.
Dans le TP prochain, je fixe le thème sur le contrôle du codeur rotatif basé sur le système FPGA, celui qui peut être appliqué sur un véhicule pour détecter ce vitesse.  


