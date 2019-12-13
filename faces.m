clc; clear all; close all;

%Ler imagem

A = imread('ras.jpeg');

%A =imrotate(J,-90);
%Objeto detector de face

FaceDetector = vision.CascadeObjectDetector();

%Usar facedetector na imagem

BBOX = step(FaceDetector, A);

%Anotar faces



B = insertObjectAnnotation(A, 'rectangle', BBOX, 'Face');
imshow(B), title('Detected Faces');

%Mostrar o numero de faces
n = size(BBOX,1);
str_n = num2str(n);

str = strcat('numero de faces prevists =', str_n);
disp(str);