clc; clear all; close all;


%%Passo 1: Ler e mostrar a imagem

i = imread('velo.jpg');

%figure;
imshow(i); 
title('Imagem original');

%%Passo 2: Detectar regiões de texto



imagemCinza = rgb2gray(i);
rBordas =    detectMSERFeatures(imagemCinza, 'RegionAreaRange', [150 50000]);
rPixels = vertcat(cell2mat(rBordas.PixelList));                             %Converte a tabela em uma matriz USAR VERTCAT

%figure;
imshow(i);
hold on
plot(rBordas, 'showPixelList', true, 'showEllipses', false);                %mostra os objetos detectados
title('Bordas');


%%Passo 3: Melhorar a detecção de possíveis objetos

mascaraMSER = false(size(imagemCinza));                                     %Criando uma máscara com o tamanho da imagem
ind = sub2ind(size(mascaraMSER), rPixels(:,2), rPixels(:,1));
mascaraMSER(ind) = true;                                                            

mascaraBorda = edge(imagemCinza, 'Canny');                                  %Colocando 1 nas bordas

intersecao = mascaraBorda & mascaraMSER;
%figure;
imshowpair(mascaraBorda, intersecao, 'montage');                            %Plota a imagem com bordas Canny e a interseção
title('Interseção entre Canny e MSER');

%%Passo 4: Destacar bordas 

% [~, gDir] = imgradient(imagemCinza);
% mascaraGradiente = helperGrowEdges(intersecao, gDir, 'DarkTextOnLight');
% figure;
% imshow(mascaraGradiente);
% title('Máscara com gradiente');


bw = bwperim(intersecao,8);
bw3 = imdilate(bw, strel('disk',1));
%figure;
imshow(bw3);
title('Bordas destacadas???');

%Passo 5: Retirar o que não faz parte do texto

mascara = ~bw3 & mascaraMSER;
%figure;
imshowpair(mascaraMSER, mascara, 'montage');
title('MSER original e segmentada');


%Passo 6:  Filtrar os candidatos a caracteres usando análise de componentes
%conectados

componentes = bwconncomp(mascara);
stats = regionprops(componentes,  'Area', 'Eccentricity', 'Solidity');

filtroTexto = mascara;

filtroTexto(vertcat(componentes.PixelIdxList{[stats.Eccentricity] > .85})) = 0;
filtroTexto(vertcat(componentes.PixelIdxList{[stats.Area] < 1000 | [stats.Area] > 100000})) = 0;
filtroTexto(vertcat(componentes.PixelIdxList{[stats.Solidity] < .55})) = 0;

%figure;
imshowpair(mascara, filtroTexto, 'montage');
title('Possíveis textos');

distancia = bwdist(~filtroTexto);                                           %Transformada da distância - mínima distância entre pixels não pretos
largura = bwmorph(filtroTexto, 'thin', inf);

larguraStroke = distancia;
larguraStroke(~largura) = 0;

imshow(larguraStroke);

% larguraValores = distancia(largura);
% larguraMetrica = std(larguraValores)/mean(larguraValores);                 %Coeficiente de variação
%             

aposStroke = filtroTexto;

for k = 1:componentes.NumObjects
    Strokelargura = largura(componentes.PixelIdxList{k});
    
    if  std(Strokelargura)/mean(Strokelargura) > 5.05
        aposStroke(componentes.PixelIdxList{k}) = 0;
    end
end

imshow(~aposStroke);

se1 = strel('disk',25);
se2 = strel('disk',7);

mascaraMorfologica = imclose(aposStroke,se1);
mascaraMorfologica = imopen(mascaraMorfologica, se2);

displayImage = i;
displayImage (~repmat(mascaraMorfologica,1,1,3)) = 0;                       %Agrupar a matriz com texto
imshow(displayImage)

areaLimite =  5000;
componentes = bwconncomp(mascaraMorfologica);
stats = regionprops(componentes, 'BoundingBox','Area');
caixas =  round(vertcat(stats(vertcat(stats.Area)> areaLimite).BoundingBox));

for e = 1:size(caixas,1)
    figure;
    imshow(imcrop(i, caixas(e,:)));
    title('Região de texto');
end

%Passo 7: Reconhecimento de caracateres


ocrtext = ocr(aposStroke,caixas);
[ocrtext.Text]
