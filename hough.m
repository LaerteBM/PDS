clc; clear all; close all;

i = imread('100.jpeg');

imshow(i);

Rmin = 55;
Rmax = 75;

[centersDark1, radiiDark1] = imfindcircles(i, [Rmin Rmax],'ObjectPolarity', 'bright', 'Sensitivity', 0.98);

viscircles(centersDark1, radiiDark1, 'Color', 'blue','LineStyle', '-');