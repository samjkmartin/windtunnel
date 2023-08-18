% function makePlot(readFile,firstStation)
% data = readmatrix(readFile);

clc
clear all
close all

data = readmatrix("A6/A6.csv");
firstStation = 2; 

% Information about the disc/setup in mm
diameter    = 50;
radius      = diameter/2;
span        = 20;
crankHeight = 3; 

% Number of stations
lastStation = width(data)/2;

rNorm   = zeros(length(data),lastStation);
r = rNorm; 
pressure = rNorm;

c = linspace(1,10,length(data));

pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:lastStation
    crankOffset = 28; % crank location of the center of the wake
    r = crankHeight*(data(:,2*j-1)-crankOffset); % vertical position in mm relative to the center of the disc
    rNorm(:,j)    = r/diameter;
    pressure(:,j) = data(:,2*j);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,j));

    uNorm(:,j) = sqrt(pressure(:,j)/maxPress); 

    station = j + firstStation - 1;

    % Create figure
    subplot(1,lastStation,j);
    scatter(uNorm(:,j),rNorm(:,j),50,[30 39 73]/255,"filled")
    xlim([0.25 1])
    % ylim([-inf inf])
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
