clc;
clear all;
close all;

if contains(path,'samjkmartin')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/DataFunctions','-end')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/Models','-end')
elseif contains(path, 'riley')
    addpath('C:\Users\riley\OneDrive\Documents\GitHub\windtunnel\DataFunctions','-end')
    addpath('C:\Users\riley\OneDrive\Documents\GitHub\windtunnel\Models','-end')
else
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/DataFunctions','-end')
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/Models','-end')
end

%% Information about the disc (set manually)
discName = 'empty';
D = 50; % diameter in mm
S = 0; % span in mm
R = D/2; % Disc radius

%% Importing the raw data and saving to MATLAB variables
% Set crankOffsets manually

stations = [9];
numStations = length(stations);

crankHeight = 3; % mm per crank
crankOffsets = (16+35)*ones(1,numStations); % to set position of r=0 for each wake station (units: number of cranks from probe's starting position)
% Note: crankOffset for full tunnel is: bottom of frame is 16 cranks below usual 
% starting position (i.e. the usual zero). We then measure 70 cranks up, so
% 35 cranks is the nominal "r=0". 16 + 35 = 51. Usually though, the actual
% crank offsets end up being lower, between 30 and 35. 

cranks = cell(numStations,1); 
r = cranks; 
pressure = cranks; 
stdDevP = cranks; 
pInfty = zeros(numStations,1);
rNorm = cranks;
uNorm = cranks; 
stdDevU = cranks; 

% convert raw data into normalized radial position and velocity
for j=1:numStations
    data = readmatrix(strcat(discName,'S',num2str(stations(j)),'.csv'));
    cranks{j} = data(:,2); % number of cranks up from starting probe position
    pressure{j} = data(:,4); % dynamic pressure in inches of water
    stdDevP{j} = data(:,5); % standard deviation of dynamic pressure snapshots from mean
    
    r = crankHeight*(cranks{j}-crankOffsets(j)); % vertical position in mm relative to the center of the disc
    rNorm{j} = r/D;
    
    pInfty(j) = max(pressure{j}(17:27)); % the equivalent of indices 1:5 when we normally collect data (I added +16, and we're going by 1s here instead of 2s)
    uNorm{j} = sqrt(pressure{j}/pInfty(j)); 
    stdDevU{j} = 0.5*stdDevP{j}./sqrt(pressure{j}*pInfty(j));
end

%% Plotting and analyzing the data

% Plot formatting (set manually)
uAxis = [0.97 1.005]; % U axis values for all velocity profile plots
rAxis = [-inf inf]; % r axis values for all velocity profile plots
sizeFont = 20; % default font size for multi-panel figures
sizeTitle = 24; % default title font size for multi-panel figures

figProfiles = plotUR(stations,D,S,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle); 

figOverlap = plotOverlap(stations,D,S,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle); 
grid on

figStdDev = plotStdDev(stations,D,S,pInfty,pressure,stdDevP,uNorm,stdDevU,rNorm,rAxis,sizeFont,sizeTitle); 
%{
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc
[CD, figCD] = dragCoeff(stations,D,S,uNorm,rNorm,uMax,14,14);

[Vw, Dw, Sw, figMeanWake] = meanWake(stations,D,S,uNorm,rNorm,uMax,14,14);
close

CT = mean(CD(2:8));
EE = 0.27; 
xe = 0; 
xmax = 10;
[xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 

figVw = compareVw(stations,D,S,Vw,Dw,Sw,xD,VwFull,DwFull,SwFull,EE,xe,sizeFont,sizeTitle); 

% figTophat = plotTophat(stations,D,S,uNorm,rNorm,xD,VwFull,DwFull,SwFull,EE,xe,uAxis,rAxis,sizeFont,sizeTitle);

% figGaussFit = plotGaussFit(stations,D,S,uNorm,rNorm,xD,VwFull,DwFull,SwFull,EE,xe,uAxis,rAxis,sizeFont,sizeTitle);
%}

%% Export figures to PDF
% exportgraphics(figProfiles, strcat('SD0,', num2str(100*S/D), '_profiles.pdf'),'ContentType','vector','BackgroundColor','none')
% exportgraphics(figOverlap, strcat('SD0,', num2str(100*S/D), '_overlap.pdf'),'ContentType','vector','BackgroundColor','none')
% exportgraphics(figStdDev, strcat('SD0,', num2str(100*S/D), '_StdDev.pdf'),'ContentType','vector','BackgroundColor','none')
% exportgraphics(figCD, strcat('SD0,', num2str(100*S/D), '_CD.pdf'),'ContentType','vector','BackgroundColor','none')
% exportgraphics(figVw, strcat('SD0,', num2str(100*S/D), '_Vw.pdf'),'ContentType','vector','BackgroundColor','none')

% exportgraphics(figTophat, strcat('SD0,', num2str(100*S/D), '_tophat.pdf'),'ContentType','vector','BackgroundColor','none')
% exportgraphics(figGauss, strcat('SD0,', num2str(100*S/D), '_Gaussian.pdf'),'ContentType','vector','BackgroundColor','none')