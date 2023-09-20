% function makePlot(readFile,firstStation,crankOffset)
% data = readmatrix(readFile);

clc; clear; close all;

data = readmatrix("A6.csv");

widthData   = width(data);
% Number of stations
numStations = widthData/2;

firstStation = 2; 
% crank location of the center of the wake per station
crankOffset = [55.5 57.5 57 57 58 58 60 56]/2;

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

pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    % vertical position in mm relative to the center of the disc
    r = crankHeight*(data(:,2*j-1)-crankOffset(j)); 
    rNorm(:,j)    = r/D;
    pressure(:,j) = data(:,2*j);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,j)); % REARRANGE CODE TO GET CLEAN DATA FIRST SO THAT WE CAN USE maxPress = pressure(1,j). Right now, there are NaNs in the 1 position. 

    uNorm(:,j) = sqrt(pressure(:,j)/maxPress); 
    
    plotData = [uNorm(:,j),rNorm(:,j)];
    plotData(any(isnan(plotData),2),:) = []; 
    station = j + firstStation - 1;
    cleanData{j,1} = plotData(:,1);
    cleanData{j,2} = plotData(:,2); % cleanData now contains alternating vectors of (uNorm, rNorm) with NaNs removed. Each pair corresponds to a station. 
   
    % Create figure
    subplot(1,numStations,j);
    % scatter(plotData(:,1),plotData(:,2),50,[30 39 73]/255,"filled")
    plot(plotData(:,1),plotData(:,2))
    xlim([0.4 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i',station))
    xlabel('U/U_{\infty}')
    ylabel('r/D')

    hold on
    axval = axis;
    axis([axval(1:3) -axval(3)])
    plot(axval(1:2), [0 0], 'k:') % centerline
    plot(plotData(:,1),-plotData(:,2), ':b'); % flipped profile
end
sgtitle(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)))

% allfig = figure;
pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    plot(cleanData{j,1}, cleanData{j,2})
    hold on
end
axval = axis;
axis([axval(1:3) -axval(3)])
plot(axval(1:2), [0 0], 'k:') % centerline
xlim([0.4 1])
ylim([-1.5 1.5])
title(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)))
xlabel('U/U_{\infty}')
ylabel('r/D')
legends = cell(numStations,1); 
for j = 1:numStations
    legends{j} = strcat('x/D=', num2str(firstStation+j-1));
end
legend(legends)

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
