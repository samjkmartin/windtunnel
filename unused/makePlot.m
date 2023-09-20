% function makePlot(readFile,firstStation,crankOffset)
% data = readmatrix(readFile);

clc; clear; close all;

data = readmatrix("A6/A6.csv");

widthData   = width(data);
% Number of stations
numStations = widthData/2;

firstStation = 2; 
%crankOffset = zeros(1,lastStation);
% crank location of the center of the wake per station
crankOffset = [56 56 57 57 58 57 59 56]/2;

% Information about the disc/setup in mm
D = 50; % disc diameter
R = D/2; % radius
S = 15; % span of annular disc (outer radius minus inner radius)
crankHeight = 3; 



rNorm       = zeros(length(data),numStations);
uNorm       = rNorm;
r           = rNorm; 
pressure    = rNorm;

cleanData   = cell(numStations,2);

pcfig             = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    % vertical position in mm relative to the center of the disc
    r = crankHeight*(data(:,2*j-1)-crankOffset(j)); 
    rNorm(:,j)    = r/D;
    pressure(:,j) = data(:,2*j);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,j));

    uNorm(:,j) = sqrt(pressure(:,j)/maxPress); 
    
    plotData = [uNorm(:,j),rNorm(:,j)];
    plotData(any(isnan(plotData),2),:) = []; 
    station = j + firstStation - 1;
    cleanData{j,1} = plotData(:,1);
    cleanData{j,2} = plotData(:,2); % cleanData now contains alternating vectors of (uNorm, rNorm) with NaNs removed. Each pair corresponds to a station. 
    % Create figure
    subplot(1,numStations,j);
    scatter(plotData(:,1),plotData(:,2),50,[30 39 73]/255,"filled")
    xlim([0.25 1])
    ylim([-inf inf])
    title(sprintf('Station %i',station))
    xlabel('Normalized Velocity')
    ylabel('r/D')
end
sgtitle('Normalized Velocity vs Normalized Distance')

allfig = figure;
for j = 1:numStations
    scatter(uNorm(:,j),rNorm(:,j),50,[130 139 173]/255)
    hold on
end
xlim([0.25 1])
% ylim([0.25 2.75])
title("All Stations")
xlabel('Normalized Velocity')
ylabel('r/D')

% Calculating drag force
FDnorm = zeros(numStations,1); % placeholder for drag force normalized by Uinf and D
uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc
for i=1:numStations
    u = cleanData{i,1};
    rD = cleanData{i,2}; 
    for j=1:length(u)
        if u(j) < uMax
            FDnorm(i) = FDnorm(i) + pi*abs(rD(j)-rD(j-1))*(abs(rD(j))*u(j)*(1-u(j))+abs(rD(j-1))*u(j-1)*(1-u(j-1))); 
        end
    end
end 
FDnorm = 0.5*FDnorm; % because we integrated from -R to R instead of 0 to R, so we double-counted

% Calculating drag coefficients from drag force
A = pi*(R^2 - (R-S)^2); % disc area, mm^2
Anorm = A/D^2; % normalized disc area

CD = 2*FDnorm/Anorm; % Drag coefficient

figure
stations = [firstStation:numStations+firstStation-1]'; 
plot(stations, CD, 'k*')
title('Calculated drag coefficient of disc A7')
xlabel('x/D')
ylabel('C_D')

% end
