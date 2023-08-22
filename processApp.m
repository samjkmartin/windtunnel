function processApp(firstStation)

% WARNING: AUTO RENAME WILL NOT WORK FOR SOME VARIABLES

file = uigetfile('*.csv',...
    'Select an data file','DiscStation.png');

data = readmatrix(file);
lastStation = width(data)/2;

[ncolumns{1:lastStation}] = deal('1x');

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

% Create uifigure
appWindow = uifigure('WindowState','maximized', ...
    'Name','Data Processing App by Raaghav');

% Application grid for layout of app elements
grid = uigridlayout(appWindow,[6 lastStation], ...
    'BackgroundColor',[220 200 230]/255);
grid.RowHeight   = {'1x','2x','2x','2x','2x','1x'};
grid.ColumnWidth = ncolumns;

for a = 1:lastStation
    stationNumber = firstStation+a-1;
    eval(sprintf('axis%d               = uiaxes(grid);',a))
    eval(sprintf('axis%d.Layout.Row    = [2 5];',a))
    eval(sprintf('axis%d.Layout.Column = a;',a))
    eval(sprintf('axis%d.Title.String  = "Station %d";',a,stationNumber))
    eval(sprintf('axis%d.XLabel.String = "Normalized Velocity";',a))
    eval(sprintf('axis%d.YLabel.String = "r/D";',a))
    eval(sprintf('axis%d.XLim          = [0.25 1];',a))
    eval(sprintf('axis%d.YLim          = [-3 3];',a))
end

for b = 1:lastStation
    crankOffset = 28; % crank location of the center of the wake
    r = crankHeight*(data(:,2*b-1)-crankOffset); % vertical position in mm relative to the center of the disc
    rNorm(:,b)    = r/diameter;
    pressure(:,b) = data(:,2*b);
    
    pressure(pressure==0) = nan;
    
    maxPress = max(pressure(:,b));

    uNorm(:,b) = sqrt(pressure(:,b)/maxPress); 

    % Create figure
    eval(sprintf('scatter(axis%d,uNorm(:,b),rNorm(:,b),50,[30 39 73]/255,"filled")',b))
end

for c = 1:lastStation
    eval(sprintf(['centerPanel%d = uipanel(grid,' ...
        '"Title","Center Panel%d",' ...
        '"BackgroundColor",[247 111 142]/255);'],c))
    eval(sprintf('centerPanel%d.Layout.Row = 6;',c))
    eval(sprintf('centerPanel%d.Layout.Column = c;',c))
    eval(sprintf(['offsetVal%d = uieditfield(centerPanel%d, "numeric",' ...
        '"Value", crankOffset,' ...
        '"ValueChangedFcn",@(offsetVal%d,event) crankOffset%d(),' ...
        '"BackgroundColor",[247 111 142]/255);'],c))
end

    function crankOffset1()
        crankOffset = offsetVal1.Value;
        r = crankHeight*(data(:,2*1-1)-crankOffset); % vertical position in mm relative to the center of the disc
        rNorm(:,1)    = r/diameter;
        pressure(:,1) = data(:,2*1);

        pressure(pressure==0) = nan;

        maxPress = max(pressure(:,1));

        uNorm(:,1) = sqrt(pressure(:,1)/maxPress);

        scatter(axis1,uNorm(:,1),rNorm(:,1),50,[30 39 73]/255,"filled")
    end


end