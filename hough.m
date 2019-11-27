clc; clear all; close all;

i = imread('/home/alysson/Projeto PDS/placas.jpg');

imshow(i);

Rmin = 100;
Rmax = 500;

[centersDark1, radiiDark1] = imfindcircles(i, [Rmin Rmax],'ObjectPolarity', 'bright', 'Sensitivity', 0.98);

viscircles(centersDark1, radiiDark1, 'Color', 'blue','LineStyle', '-');