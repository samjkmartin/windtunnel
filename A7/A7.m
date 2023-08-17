clc;
clear all;
close all;

% Information about the disc
D = 50; % diameter in mm
R = D/2; % Disc radius
S = 20; % span in mm

data = readmatrix("A7S2.csv");
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water
figure 
plot(pressure, cranks);
title('Pressure vs Cranks')
xlabel('Pressure (in. H_2O)')
ylabel('Vertical position (cranks)')

crankHeight = 3; % mm per crank
crankOffset = 31; % crank location of the center of the wake
r = crankHeight*(cranks-crankOffset); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

figure
plot(uNorm, rNorm); 
title('Disc A7, x/D=2')
xlabel('U/U_{infty}')
ylabel('r/D')

FDnorm = 0; 
i = 1; % this is here as a placeholder for later, when drag will be calculated for many stations at once
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc
for j=1:length(uNorm)
    if uNorm(j) < uMax
        FDnorm(i) = FDnorm(i) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end
FDnorm = 0.5*FDnorm; % because we integrated from -R to R instead of 0 to R, so we double-counted

A = pi*(R^2 - (R-S)^2); % disc area, mm^2
Anorm = A/D^2; % normalized disc area

CD = 2*FDnorm/Anorm % Drag coefficient
