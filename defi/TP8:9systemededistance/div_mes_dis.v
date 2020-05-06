/*
Pour la division non signée de 32, le dividende a est divisé par le diviseur b, 
et leur quotient et le reste ne doivent pas dépasser 32 bits. 
Commencez par convertir a en temp_a avec 32 bits supérieurs à 0 et 32 bits inférieurs à a. 
Convertissez b en temp_b avec les 32 bits supérieurs étant b et les 32 bits inférieurs étant 0. 
Au début de chaque cycle, déplacez d'abord temp_a vers la gauche, ajoutez 0 à la fin, puis comparez avec b, 
s'il est supérieur à b, puis temp_a moins temp_b sera ajouté avec 1, sinon continuez à exécuter. 
Le décalage, la comparaison et la soustraction ci-dessus (selon le cas) sont exécutés 32 fois, 
après la fin de l'exécution, les 32 bits supérieurs de temp_a représentent le reste et les 32 bits inférieurs est le quotient.
*/

module div  
(  
input[31:0] a,   
input[31:0] b,  
  
output reg [31:0] yshang,  
output reg [31:0] yyushu  
);  
  
reg[31:0] tempa;  
reg[31:0] tempb;  
reg[63:0] temp_a;  
reg[63:0] temp_b;  
  
integer i;  
  
always @(a or b)  
begin  
    tempa <= a;  
    tempb <= b;  
end  
  
always @(tempa or tempb)  
begin  
    temp_a = {32'h00000000,tempa};  
    temp_b = {tempb,32'h00000000};   
    for(i = 0;i < 32;i = i + 1)  
        begin  
            temp_a = {temp_a[62:0],1'b0};  
            if(temp_a[63:32] >= tempb)  
                temp_a = temp_a - temp_b + 1'b1;  
            else  
                temp_a = temp_a;  
        end  
  
    yshang <= temp_a[31:0];  
    yyushu <= temp_a[63:32];  
end  
  
endmodule  