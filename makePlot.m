function makePlot(readFile,firstStation)
data = readmatrix(readFile);

% Information about the disc/setup in mm
diameter    = 50;
radius      = diameter/2;
span        = 20;
crankHeight = 3; 

% Number of stations
lastStation = width(data)/2;

vdist   = zeros(length(data),lastStation);
pressure = vdist;

c = linspace(1,10,length(data));

pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:lastStation
    vdist(:,j)    = data(:,2*j-1)*crankHeight/diameter;
    pressure(:,j) = data(:,2*j);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,j));

    uNorm(:,j) = sqrt(pressure(:,j)/maxPress); 

    station = j + firstStation - 1;

    % Create figure
    subplot(1,lastStation,j);
    scatter(uNorm(:,j),vdist(:,j),50,[30 39 73]/255,"filled")
    xlim([0.25 1])
    ylim([0.25 2.75])
    title(sprintf('Station %i',station))
    xlabel('Normalized Velocity')
    ylabel('r/D')
end
sgtitle('Normalized Velocity vs Normalized Distance')

allfig = figure;
for j = 1:lastStation
    scatter(uNorm(:,j),vdist(:,j),50,[130 139 173]/255)
    hold on
end
xlim([0.25 1])
ylim([0.25 2.75])
title("All Stations")
xlabel('Normalized Velocity')
ylabel('r/D')

end
