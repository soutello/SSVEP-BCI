clear all
clc

%parâmetros

fs=256; %frequência de amostragem
e=[12 15]; %vetor de frequências de estímulo
a=[12 15]; %frequência de análise
n_freqs = length(e);
window = 3 ;
Htemp=[];
H =[];
Hteste = [];
treino = [1 2 3 4 5];
teste = [6 7 8];
site = ('C:\Users\lipem\Dropbox\UNICAMP\BCI\Luis\');
%programa
%load('Dados_Luis');
%carrega o arquivo
for ii=1:n_freqs
    freq=int2str(e(ii));
    for jj=1:length(treino)
        st = treino(jj);
        s = int2str(st);
        load(strcat(site,'ssvep_',freq,'_Hz_training_subject_Luis_session_',s,'.mat'));
        x=storageDataAcquirement;
        
        
        
        %filtragem CAR
        x=fcar(x);
        
        inicio = 1;
        fim  = 256*window;
        
        for k = 1:floor(size(x,1)/(256*window))
            seg(:,:,k) = x(inicio:fim,:);
            inicio = inicio + 256*window;
            fim = fim + 256*window;
        end
            
        %extração de características
        for l = 1:floor(size(x,1)/(256*window))
            for k=1:16
                [pxx,f]=pwelch(seg(:,k,l),256*window,[],a,256);
%                 for m=1:n_freqs
%                     [pxx,f]=pwelch(seg(:,k,l),[],[],[e(m)-0.5:0.1:e(m)+0.5],256);
%                     c(m)=sum(pxx);
% 
%                 end
%                 a = c./sum(c);
                Htemp = [Htemp pxx];
            end
         H = [H; Htemp];
         Htemp=[];
        end
    end
end
H = [H ones(size(H,1),1)];
splits = floor(size(x,1)/(256*window))*length(treino);
for ii=1:n_freqs
    freq=int2str(e(ii));
    for jj=1:length(teste)
        st = teste(jj);
        s = int2str(st);
        load(strcat(site,'ssvep_',freq,'_Hz_training_subject_Luis_session_',s,'.mat'));
        x=storageDataAcquirement;
        
        
        
        %filtragem CAR
        x=fcar(x);
        
        inicio = 1;
        fim  = 256*window;
        
        for k = 1:floor(size(x,1)/(256*window))
            seg(:,:,k) = x(inicio:fim,:);
            inicio = inicio + 256*window;
            fim = fim + 256*window;
        end
            
        %extração de características
        for l = 1:floor(size(x,1)/(256*window))
            for k=1:16
                [pxx,f]=pwelch(seg(:,k,l),256*window,[],a,256);
%                 for m=1:n_freqs
%                     [pxx,f]=pwelch(seg(:,k,l),[],[],[e(m)-0.5:0.1:e(m)+0.5],256);
%                     c(m)=sum(pxx);
% 
%                 end
%                 a = c./sum(c);
                Htemp = [Htemp pxx];
            end
         Hteste = [Hteste; Htemp];
         Htemp=[];
        end
    end
end
Hteste = [Hteste ones(size(Hteste,1),1)];

for i = 1:size(H(:,1),1)/2
plot(H(i,1),H(i,2),'xb')
hold on
end
for i = size(H(:,1),1)/2+1:size(H(:,1),1)
plot(H(i,15),H(i,16),'or')
hold on
end


linearlabel1(1:splits,1)= 1;
    
linearlabel2(1:splits,1) = -1;
    
label1 = cat(1,linearlabel1,linearlabel2);
label2 = cat(1,linearlabel2,linearlabel1);
label = cat(2,label1,label2);

W=pinv(H)*label;

F = Hteste*W;