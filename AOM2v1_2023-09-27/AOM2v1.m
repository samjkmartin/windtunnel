% clc;
clear all;
close all;

% Information about the disc
D = 50; % diameter in mm
R = D/2; % Disc radius
S = 10; % span in mm

stations = [4,4,4]; 

crankHeight = 3; % mm per crank
% to set position of r=0 for each disc: 
crankOffsets = [33.25,33.25,36.25]; % outer edges aligned
% crankOffsets = ones(3,1)*33.25;

FDnorm = zeros(length(stations),1); % placeholder for drag force normalized by Uinf and D
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc

figure
for i=1:length(stations)
    data = readmatrix(strcat('AOM2v1S',num2str(stations(i)),'_',num2str(i-1),'shims.csv'));
    cranks = data(:,2); % number of cranks up from starting probe position
    pressure = data(:,4); % dynamic pressure in inches of water

    r = crankHeight*(cranks-crankOffsets(i)); % vertical position in mm relative to the center of the disc
    rNorm = r/D; % r normalized by diameter

    pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
    uNorm = sqrt(pressure/pInfty); % U/Uinfty

    % subplot(1,length(stations),i)
    hold on
    plot(uNorm, rNorm)
    title(strcat('Disc AOM2v1, x/D=',num2str(stations(i))))
    xlabel('U/U_{infty}')
    ylabel('r/D')
    xlim([0.6 inf])
    ylim([-1.5 1.5])

    % axval = axis;
    % axis([axval(1:3) -axval(3)])
    % plot(axval(1:2), [0 0], ':k') % centerline
    % plot(uNorm, -rNorm, ':b'); % flipped profile

    % Drag Force calculations
    for j=1:length(uNorm)
        if uNorm(j) < uMax
            FDnorm(i) = FDnorm(i) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
        end
    end

end
legend('0','1','2')

% Calculating drag coefficients from drag force
FDnorm = 0.5*FDnorm; % because we integrated from -R to R instead of 0 to R, so we double-counted

A = pi*(R^2 - (R-S)^2); % disc area, mm^2
Anorm = A/D^2; % normalized disc area

CD = 2*FDnorm/Anorm; % Drag coefficient

figure
plot(stations, CD, 'k*')
title('Calculated drag coefficient of disc AOM2v1')
xlabel('x/D')
ylabel('C_D')

figure
data = readmatrix('AOM2v1S4v4_reverseTilt.csv');
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-33); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

hold on
plot(uNorm, rNorm)
title(strcat('Disc AOM2v1, x/D=',num2str(stations(i))))
xlabel('U/U_{infty}')
ylabel('r/D')
xlim([0.6 inf])
ylim([-1.5 1.5])