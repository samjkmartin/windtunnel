% Gaussian annular wake, empirical fit, test file

clc
clear
close all

rGauss = (-1.5:0.01:1.5)';
Rp = 0.5; 
b = 0.3; 
deltaU = 0.4; 
ufit = 1 - deltaU*(exp(-(rGauss-Rp).^2/b^2)+exp(-(rGauss+Rp).^2/b^2)); 
plot(ufit,rGauss)