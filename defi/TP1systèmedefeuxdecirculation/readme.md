 
Compte rendu TP1_Défi 
  Conception du système de feux de circulation  






HUO JIAXI


Enseignant : DELEMOTTE Emmanuel
                            

                                        02/09/2019





Table de matières
1.    TRAVAIL A REALISER    3
1.1    INTRODUCTION    3
1.2    LA DIVISION D’HORLOGE    3
Algorithme 1 :    4
Algorithme 2 :    5
1.3    CONCEPTION D’AUTOMATE    8
2.    BILAN :    12

















1.    Travail à réaliser
1.1    Introduction
Le système de feux de circulation est installé au carrefour pour indiquer les chauffeurs que la condition de circulation au carrefour. Le système de feux de circulation est important pour assurer la sécurité de circulation. Le système de feux de circulation est possible d’être réalisé avec la technologie de FPGA. C’est naturellement que je me suis tourné vers la conception du système de feux de circulation comme mon premier TP Défi. J’applique la technologie de FPGA sur ma conception du système de feux de circulation. 
Pour réaliser cette conception, premièrement j’ai conçu l’algorithme pour la division d’horloge afin d’obtenir la période appropriée. Deuxièmement j’ai conçu l’automate pour contrôler les états des feux.

1.2    La division d’horloge
La division d’horloge est la base de cette conception en raison de la différence entre la période de feux et la période de quartz. Pour correspondre la période de feux, il faut concevoir l’algorithme pour augmenter la période de quartz, c’est-à-dire qu’il faut réduire la fréquence de quartz.
J’ai conçu deux l’algorithmes de division d’horloge. D’abord, le premier algorithme est celui qui permet la division de fréquence en pair (N = 2, 4, 6 …), Pour améliorer l’algorithme, je vous propose le deuxième algorithme qui permet la division de toutes les fréquences, n’importe pas la parité de division.
Algorithme 1 :
1.    module divide_al2 #(  
2.    parameter N = 4,  
3.        WIDTH = 2 // Définir le parameter de division: N = (Fout/Fin)/2; WIDTH est la taille de compteur: N < 2^WIDTH - 1  
4.    )  
5.    (  
6.        input clk,  
7.        input rst,  
8.        output reg clk_out  
9.        );  
10.        reg [WIDTH:0]counter;  
11.      
12.    always @(posedge clk or posedge rst) begin   
13.        if (rst) begin  
14.            // reset  
15.            counter <= 0;  
16.        end  
17.        else if (counter == N-1) begin  
18.            counter <= 0;  
19.        end  
20.        else begin  
21.            counter <= counter + 1; //Le compteur est incrémenté par 1 chaque fois qu'un front montant d'horloge est rencontré  
22.        end  
23.    end  
24.      
25.    always @(posedge clk or posedge rst) begin  
26.        if (rst) begin  
27.            // reset  
28.            clk_out <= 0;  
29.        end  
30.        else if (counter == N-1) begin  
31.            clk_out <= !clk_out;// Chaque fois le compteur atteins N-1, l'horloge de sortie inverse.  
32.        end  
33.    end  
J’ai fait la simulation pour prouver l’exactitude de cet algorithme (Je défini les paramètres : N = 4, WIDTH = 2) :
 
Le fait est présenté : Tclk_out/Tclk_in = 16/3 = 8, celui qui correspond au résultat prévu.
Ensuite pour améliorer l’adaptabilité d’algorithme, je vous propose le deuxième algorithme, celui qui permet la division de toutes les fréquences à diviser.
Algorithme 2 :
Tout d'abord, un déclenchement sur front montant est effectué pour effectuer un comptage modulo de N et le comptage est sélectionné à une certaine valeur pour effectuer une inversion d'horloge de sortie, puis inversé à nouveau par (N-1) / 2 pour obtenir l’horloge n divisée qui possède un rapport cyclique non 50%. De plus, le compte N modulo du déclencheur de front descendant est exécuté simultanément. Lorsque l'horloge de sortie est inversée avec la même valeur que l'horloge de sortie du déclencheur de front montant, elle est inversée et lorsque (N-1) / 2 est passé, l'horloge de sortie est inversée. Une horloge n-divisée impaire avec un rapport cyclique non 50% est générée. Deux horloges n-divisées avec un rapport cyclique non 50% sont logiquement exploitées (phases avec plus de périodes positives et plus de phases avec plus de périodes négatives), ce qui donne une horloge n-divisée impaire avec un rapport cyclique 50%.


1.    module divide#  
2.    (  
3.        parameter WIDTH = 3,  
4.        parameter N = 5 //Définir le parameter de division: N = Fout/Fin; WIDTH est la taille de compteur: N < 2^WIDTH - 1  
5.        )  
6.      
7.    (  
8.        clk,  
9.        rst_n,  
10.        clk_out,  
11.        );    
12.      
13.        input  clk, rst_n;  
14.        output clk_out;  
15.        reg     [WIDTH-1:0]     cnt_p,cnt_n;//cnt_p est le compteur qui functionne à partir de front montant, par contre cnt_n est le compteur qui functionne à partir de front descendant.  
16.        reg                     clk_p,clk_n;//clk_p est l'horloge qui est provoqué par le front montant, par contre clk_p est provoqué par le front descendant.  
17.       
18.        assign clk_out = (N==1)?clk:(N[0])?(clk_p&clk_n):clk_p;  
19.        // N=1: clk_out = clk  
20.        // N est pair: N[0]=0: clk_out = clk_p  
21.        // N est impair: N[0]=1: clk_out = clk_p&clk_n  
22.      
23.        always @ (posedge clk)  
24.            begin  
25.                if(!rst_n)  
26.                    cnt_p<=0;  
27.                else if (cnt_p==(N-1))  
28.                    cnt_p<=0;  
29.                else cnt_p<=cnt_p+1;  
30.            end  
31.       
32.        always @ (negedge clk)  
33.            begin  
34.                if(!rst_n)  
35.                    cnt_n<=0;  
36.                else if (cnt_n==(N-1))  
37.                    cnt_n<=0;  
38.                else cnt_n<=cnt_n+1;  
39.            end  
40.       
41.        always @ (posedge clk)  
42.            begin  
43.                if(!rst_n)  
44.                    clk_p<=0;  
45.                else if (cnt_p<(N>>1))    
46.                    clk_p<=0;  
47.                else   
48.                    clk_p<=1;  
49.            end  
50.     //|clk_n-clk_p| = 1/2*clk  
51.        always @ (negedge clk)  
52.            begin  
53.                if(!rst_n)  
54.                    clk_n<=0;  
55.                else if (cnt_n<(N>>1))    
56.                    clk_n<=0;  
57.                else   
58.                    clk_n<=1;  
59.            end  
60.    endmodule
J’ai fait la simulation pour prouver l’exactitude de cet algorithme (Je défini les paramètres : N = 5, WIDTH = 3) :
 
Le fait est présenté : Tclk_out/Tclk_in = 10/2 = 5, celui qui correspond au résultat prévu.



1.3    Conception d’automate
Pour mettre en œuvre la conception de feux, il faut appliquer l’automate sur la conception, celui qui peut réaliser la transmission des états. Je défini les états comme les paramètres : S1, S2, S3, S4. Je vous explique les significations des états :
S1 : rue 1 vert ; rue 2 rouge
S2 : rue 1 jeune ; rue 2 rouge
S3 : rue 1 rouge ; rue 2 vert
S4 : rue 1 rouge ; rue 2 jeune
Ci-dessous est la transmission des états.
 
1.    module feu  
2.    (  
3.        clk ,      
4.        rst_n,    
5.        out            
6.    );  
7.       
8.        input   clk,rst_n;       
9.        output  reg[5:0]    out;  
10.       
11.        parameter       S1 = 4'b00,     
12.                S2 = 4'b01,  
13.                S3 = 4'b10,  
14.                S4 = 4'b11;  
15.       
16.        parameter   time_s1 = 4'd15,   
17.                time_s2 = 4'd3,  
18.                time_s3 = 4'd10,  
19.                time_s4 = 4'd3;  
20.      
21.        //controler le feu  
22.        parameter   led_s1 = 6'b101011,   
23.                    led_s2 = 6'b110011,   
24.                    led_s3 = 6'b011101,   
25.                    led_s4 = 6'b011110; //L'adresse des LEDs pour indiquer les feux  
26.       
27.        reg     [3:0]   timecont;  
28.        reg     [1:0]   cur_state,next_state;    
29.       
30.        wire            clk1h;  //sortie de frequnce 1Hz  
31.       
32.        divide #(.WIDTH(32),.N(6000000)) divide2 (  
33.                        .clk(clk),  
34.                        .rst_n(rst_n),  
35.                        .clkout(clk1h));  
36.      
37.        //état précédent à l'état actuel. Juger l'état  
38.        always @ (posedge clk1h or negedge rst_n)  
39.        begin  
40.            if(!rst_n)   
41.                cur_state <= S1; //état actuel à l'état suivant  
42.            else   
43.                cur_state <= next_state;  
44.        end  
45.      
46.        //Juger des transmissions d'état  
47.        always @ (cur_state or rst_n or timecont)  
48.        begin  
49.            if(!rst_n) begin  
50.                    next_state = S1;  
51.                end  
52.            else begin  
53.                case(cur_state)  
54.                    S1:begin  
55.                        if(timecont==1)   
56.                            next_state = S2;  
57.                        else   
58.                            next_state = S1;  
59.                    end  
60.       
61.                    S2:begin  
62.                        if(timecont==1)   
63.                            next_state = S3;  
64.                        else   
65.                            next_state = S2;  
66.                    end  
67.       
68.                    S3:begin  
69.                        if(timecont==1)   
70.                            next_state = S4;  
71.                        else   
72.                            next_state = S3;  
73.                    end  
74.       
75.                    S4:begin  
76.                        if(timecont==1)   
77.                            next_state = S1;  
78.                        else   
79.                            next_state = S4;  
80.                    end  
81.       
82.                    default: next_state = S1;  
83.                endcase  
84.            end  
85.        end  
86.      
87.        //sortie d'état précédent  
88.        always @ (posedge clk1h or negedge rst_n)  
89.        begin  
90.            if(!rst_n==1) begin  
91.                out <= led_s1;  
92.                timecont <= time_s1;  
93.                end   
94.            else begin  
95.                case(next_state)  
96.                    S1:begin  
97.                        out <= led_s1;  
98.                        if(timecont == 1)   
99.                            timecont <= time_s1;  
100.                        else   
101.                            timecont <= timecont - 1;  
102.                    end  
103.       
104.                    S2:begin  
105.                        out <= led_s2;  
106.                        if(timecont == 1)   
107.                            timecont <= time_s2;  
108.                        else   
109.                            timecont <= timecont - 1;  
110.                    end  
111.       
112.                    S3:begin  
113.                        out <= led_s3;  
114.                        if(timecont == 1)   
115.                            timecont <= time_s3;  
116.                        else   
117.                            timecont <= timecont - 1;  
118.                    end  
119.       
120.                    S4:begin  
121.                        out <= led_s4;  
122.                        if(timecont == 1)   
123.                            timecont <= time_s4;  
124.                        else   
125.                            timecont <= timecont - 1;  
126.                    end  
127.       
128.                    default:begin  
129.                        out <= led_s1;  
130.                        end  
131.                endcase  
132.            end  
133.        end  
134.    endmodule  
J’ai fait la simulation pour prouver l’exactitude de cet algorithme :
 
Le résultat est celui qui correspond au résultat prévu. Les 3 états sont présents clairement ci-dessus. Ensuite, les programmes seront téléchargés dans le FPGA, les résultats prévus peuvent être obtenus automatiquement.

2.    Bilan :
La conception de feux de circulation est réalisée avec la technologie FPGA et le technologie automate. Particulièrement, la division d’horloge est importante pour cette conception. Le langue Verilog est la base de cette conception, tous les programmes sont finis avec Verilog.
Ensuite, je vais travailler sur la conception de thermomètre, celui qui peut mesurer de température sans contact et automatiquement. 

