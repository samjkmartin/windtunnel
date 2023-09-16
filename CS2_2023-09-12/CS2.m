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

stations = [3,4,6,9];

crankHeight = 3; % mm per crank
crankOffsets = [33.5,33.5,33.5,33.5]; % to set position of r=0 for each disc

FDnorm = zeros(length(stations),1); % placeholder for drag force normalized by Uinf and D
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc

figure
for i=1:length(stations)
    data = readmatrix(strcat('CS2S',num2str(stations(i)),'.csv'));
    cranks = data(:,2); % number of cranks up from starting probe position
    pressure = data(:,4); % dynamic pressure in inches of water
    % figure
    % plot(pressure, cranks);
    % title('Pressure vs Cranks')
    % xlabel('Pressure (in. H_2O)')
    % ylabel('Vertical position (cranks)')

    r = crankHeight*(cranks-crankOffsets(i)); % vertical position in mm relative to the center of the disc
    rNorm = r/D; % r normalized by diameter

    pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
    uNorm = sqrt(pressure/pInfty); % U/Uinfty

    subplot(1,length(stations),i)
    hold on
    plot(uNorm, rNorm)
    plot(eval(strcat('U',num2str(stations(i)))),eval(strcat('R',num2str(stations(i)))))
    title(strcat('Disc CS2, x/D=',num2str(stations(i))))
    xlabel('U/U_{infty}')
    ylabel('r/D')
    xlim([0.25 inf])
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

%% Station 4 repeats 

Drag4 = zeros(6,1); 

data = readmatrix(strcat('CS2S4.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-33.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

figure
plot(uNorm, rNorm)
hold on

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(1) = Drag4(1) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

data = readmatrix(strcat('CS2S4v2.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

plot(uNorm, rNorm)

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(2) = Drag4(2) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

data = readmatrix(strcat('CS2S4-9-13.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

plot(uNorm, rNorm)
hold on

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(3) = Drag4(3) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

data = readmatrix(strcat('CS2S4-9-13v2.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

plot(uNorm, rNorm)

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(4) = Drag4(4) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

data = readmatrix(strcat('CS2S4-9-13v3_fullDoubleCrank.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(5) = Drag4(5) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

plot(uNorm, rNorm)

data = readmatrix(strcat('CS2S4-9-13v4.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag4(6) = Drag4(6) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

plot(uNorm, rNorm)
legend('9/12 data', '9/12 Tweaked probe', '9/13 v1', 'againV2', 'againV3 2cranks', 'againV4')
title('Disc CS2, x/D=4')
xlabel('U/U_{infty}')
ylabel('r/D')
ylim([-1.75 1.75])

axval = axis;
axis([axval(1:3) -axval(3)])
plot(axval(1:2), [0 0], 'k:') % centerline

Drag4 = 0.5*Drag4;
CD4 = 2*Drag4/Anorm;

figure
plot(CD4, 'k*')
title('C_D of disc CS2 at Station 4 measured multiple times')
xlabel('measurement number')
ylabel('C_D')

data = readmatrix(strcat('CS2S6-9-13.csv'));
cranks = data(:,2); % number of cranks up from starting probe position
pressure = data(:,4); % dynamic pressure in inches of water

r = crankHeight*(cranks-35.5); % vertical position in mm relative to the center of the disc
rNorm = r/D; % r normalized by diameter

pInfty = max(pressure); %pressure(1); %max(pressure); % dynamic pressure far away from disc
uNorm = sqrt(pressure/pInfty); % U/Uinfty

Drag6 = [0;0];
for j=1:length(uNorm)
    if uNorm(j) < uMax
        Drag6(2) = Drag6(2) + pi*abs(rNorm(j)-rNorm(j-1))*(abs(rNorm(j))*uNorm(j)*(1-uNorm(j))+abs(rNorm(j-1))*uNorm(j-1)*(1-uNorm(j-1)));
    end
end

Drag6 = Drag6/2;
Drag6(1) = FDnorm(3);
CD6 = 2*Drag6/Anorm
