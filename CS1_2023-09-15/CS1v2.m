clc;
clear all;
close all;

%% load carmody's data
load("xD1.mat")
load("xD2.mat")
load("xD3.mat")
load("xD4.mat")
load("xD6.mat")
load("xD9.mat")
load("xD12.mat")

U1 = Data001(:,1);
U2 = Data002(:,1);
U3 = Data003(:,1);
U4 = Data004(:,1);
U6 = Data005(:,1);
U9 = Data006(:,1);
U12 = Data007(:,1);

% U = [U1 U2 U3 U4 U6 U9 U12]; 

R1 = Data001(:,2)/2; % dividing by 2 because Carmody uses r/R but we want r/D
R2 = Data002(:,2)/2;
R3 = Data003(:,2)/2;
R4 = Data004(:,2)/2;
R6 = Data005(:,2)/2;
R9 = Data006(:,2)/2;
R12 = Data007(:,2)/2;

%% Our data, plotting

% Information about the disc
D = 50; % diameter in mm
R = D/2; % Disc radius
S = 25; % span in mm

stations = [3:9];

crankHeight = 3; % mm per crank
crankOffsets = [36, 36, 36, 36.5, 36, 36, 36]; % to set position of r=0 for each disc

FDnorm = zeros(length(stations),1); % placeholder for drag force normalized by Uinf and D
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc

Drag4 = zeros(6,1); % drag force from different measurements at Station 4

figure
for i=1:length(stations)
    data = readmatrix(strcat('CS1S',num2str(stations(i)),'.csv'));
    cranks = data(:,2); % number of cranks up from starting probe position
    pressure = data(:,4); % dynamic pressure in inches of water

    r = crankHeight*(cranks-crankOffsets(i)); % vertical position in mm relative to the center of the disc
    rNorm = r/D; % r normalized by diameter

    pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
    uNorm = sqrt(pressure/pInfty); % U/Uinfty

    subplot(1,length(stations),i)
    hold on
    plot(uNorm, rNorm)
    if stations(i) == (3||4||6||9)
        disp('hi');
        plot(eval(strcat('U',num2str(stations(i)))),eval(strcat('R',num2str(stations(i)))))
    end
    title(strcat('Disc CS2, x/D=',num2str(stations(i))))
    xlabel('U/U_{infty}')
    ylabel('r/D')
    xlim([0.3 inf])
    ylim([-2.25 2.25])

    axval = axis;
    axis([axval(1:3) -axval(3)])
    plot(axval(1:2), [0 0], 'k:') % centerline
    plot(uNorm, -rNorm, ':b'); % flipped profile

    % Drag Force calculations
    for j=1:length(uNorm)
        if uNorm(j) < uMax
            FDnorm(i) = FDnorm(i) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
        end
    end

end

% Calculating drag coefficients from drag force
FDnorm = 0.5*FDnorm; % because we integrated from -R to R instead of 0 to R, so we double-counted

A = pi*(R^2 - (R-S)^2); % disc area, mm^2
Anorm = A/D^2; % normalized disc area

CD = 2*FDnorm/Anorm; % Drag coefficient

figure
plot(stations, CD, 'k*')
title('Calculated drag coefficient of disc CS2')
xlabel('x/D')
ylabel('C_D')