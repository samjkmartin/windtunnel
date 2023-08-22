% function makePlot(readFile,firstStation,crankOffset)
% data = readmatrix(readFile);

clc; clear; close all;

data = readmatrix("A6/A6.csv");

widthData   = width(data);
% Number of stations
lastStation = widthData/2;

firstStation = 2; 
%crankOffset = zeros(1,lastStation);
% crank location of the center of the wake per station
crankOffset = [46 50 52 47 44 47 53 40]/2;

% Information about the disc/setup in mm
diameter    = 50;
radius      = diameter/2;
span        = 20;
crankHeight = 3; 



rNorm       = zeros(length(data),lastStation);
uNorm       = rNorm;
r           = rNorm; 
pressure    = rNorm;

cleanData   = cell(1,widthData);

pcfig             = figure;
pcfig.WindowState = 'maximized';
for j = 1:lastStation
    % vertical position in mm relative to the center of the disc
    r = crankHeight*(data(:,2*j-1)-crankOffset(j)); 
    rNorm(:,j)    = r/diameter;
    pressure(:,j) = data(:,2*j);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,j));

    uNorm(:,j) = sqrt(pressure(:,j)/maxPress); 
    
    plotData = [uNorm(:,j),rNorm(:,j)];
    plotData(any(isnan(plotData),2),:) = []; 
    station = j + firstStation - 1;
    cleanData{:,2*j-1} = plotData(:,1);
    cleanData{:,2*j}   = plotData(:,2);
    % Create figure
    subplot(1,lastStation,j);
    scatter(plotData(:,1),plotData(:,2),50,[30 39 73]/255,"filled")
    xlim([0.25 1])
    ylim([-inf inf])
    title(sprintf('Station %i',station))
    xlabel('Normalized Velocity')
    ylabel('r/D')
end
sgtitle('Normalized Velocity vs Normalized Distance')

allfig = figure;
for j = 1:lastStation
    scatter(uNorm(:,j),rNorm(:,j),50,[130 139 173]/255)
    hold on
end
xlim([0.25 1])
% ylim([0.25 2.75])
title("All Stations")
xlabel('Normalized Velocity')
ylabel('r/D')

% end
