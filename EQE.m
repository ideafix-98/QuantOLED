clc;
T= readtable('curva.xlsx');
long_ond = T(:,1);
long_ond = table2array(long_ond);
curv = T(:,2);
format short
curv = table2array(curv);


C= readtable('curva_fotopica.xlsx');
curva_fotopica = C(:,1);
curva_fotopica =table2array(curva_fotopica);
fondo1=zeros(3653,1);
x1= textread('Y 2793.txt');                                                               
waveLength=x1(3:3655);
norm = x1(3656:7308);
norm_pot=x1(7310:10962);
norm_pot=transpose(norm_pot);                                                                       
norm_pot=double(norm_pot);
norm=transpose(norm);                                                                       
norm=double(norm);

waveinterv=[];
waveL=length(waveLength);


for d=1:1:(waveL-1)
    waveinterv(d)= waveLength(d) - waveLength(d+1);
end     
waveinterv(waveL)=0.2;

waveLength=fliplr(waveLength);

curv_fotopica=[];


%ESTÀ EN PROCESO.
