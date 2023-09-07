clc;
clear all;
close all;

% Information about the disc
D = 50; % diameter in mm
R = D/2; % Disc radius
% S = 20; % span in mm

data = readmatrix("emptytunnelstation2.csv");
cranks = data(1:38,2); % number of cranks up from starting probe position
cranks = cranks - 2; % because we started at 0 but the program recorded it as 2 because of a bug
pressure = data(1:38,4); % dynamic pressure in inches of water
plot(pressure, cranks);
title('Pressure vs Cranks')
xlabel('Pressure (in. H_2O)')
ylabel('Vertical position (cranks)')

crankHeight = 3; % mm per crank
crankOffset = 34; % crank location of the center of the wake
r = crankHeight*(cranks-crankOffset); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = pressure(1); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

figure
plot(uNorm, rNorm); 
title('Empty Tunnel, x/D=2')
xlabel('U/U_{infty}')
ylabel('r/D')
ylim([-2,2])

emptyCranksPressure = [cranks, pressure]; 