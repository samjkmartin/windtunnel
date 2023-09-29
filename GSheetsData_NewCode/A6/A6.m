clc; clear; close all;

data = readmatrix("A6.csv");

widthData   = width(data);
% Number of stations
numStations = widthData/2;

firstStation = 2; 
% crank location of the center of the wake per station
crankOffset = [55.75 57.5 57.25 57.25 58.25 58 60 57]/2;

% Information about the disc/setup in mm
D = 50; % disc diameter
R = D/2; % radius
S = 15; % span of annular disc (outer radius minus inner radius)
crankHeight = 3; 

cranks = cell(numStations,1); 
pressure = cranks; 
rNorm = cranks;
uNorm = cranks; 

pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    pNan = data(:,2*j); % raw pressure data. Rows with zeros are actually empty rows
    pNan(pNan==0) = nan; % empty rows to be removed

    cleanData = [pNan,data(:,2*j-1)]; % pressure, cranks
    cleanData(any(isnan(cleanData),2),:) = [];
    pressure{j} = cleanData(:,1);
    cranks{j} = cleanData(:,2); 

    r = crankHeight*(cranks{j}-crankOffset(j)); % vertical position in mm relative to the center of the disc
    rNorm{j} = r/D;
    
    pInfty = pressure{j}(1); 
    uNorm{j} = sqrt(pressure{j}/pInfty); 
   
    % Create figure
    subplot(1,numStations,j);
    plot(uNorm{j}, rNorm{j})
    xlim([0.4 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i', firstStation + j - 1))
    xlabel('U/U_{\infty}')
    ylabel('r/D')

    hold on
    axval = axis;
    axis([axval(1:3) -axval(3)])
    plot(axval(1:2), [0 0], 'k:') % centerline
    plot(uNorm{j}, -rNorm{j}, ':b'); % flipped profile
end
sgtitle(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)))

% allfig = figure;
pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    plot(uNorm{j}, rNorm{j})
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
for j=1:numStations
    u = uNorm{j};
    rD = rNorm{j}; 
    for i=1:length(u)
        if u(i) < uMax
            FDnorm(j) = FDnorm(j) + pi*abs(rD(i)-rD(i-1))*(abs(rD(i))*u(i)*(1-u(i))+abs(rD(i-1))*u(i-1)*(1-u(i-1))); 
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
title('Calculated drag coefficient of disc A6')
xlabel('x/D')
ylabel('C_D')

% Calculate wake diameter, span, and mean wake velocity
Dw = zeros(numStations,1); 
Sw = Dw;
Vw = Dw; 
for j=1:numStations
    % finding outer wake boundaries
    top = 1; 
    while uNorm{j}(top)>=uMax
        top = top+1; 
    end
    bottom = length(uNorm{j});
    while uNorm{j}(bottom) >= uMax
        bottom = bottom-1; 
    end
    
    % finding wake core boundaries
    coreTop = top; 
    while uNorm{j}(coreTop)<uMax
        coreTop = coreTop+1; 
    end
    coreBottom = bottom;
    while uNorm{j}(coreBottom)<uMax
        coreBottom = coreBottom-1; 
    end

    % because the first set of while loops overshoot the outer edges
    top = top-1; 
    bottom = bottom+1; 
    
    % wake diameter
    Dw(j) = rNorm{j}(bottom)-rNorm{j}(top); 

    % Check to see if the wake is annular or circular
    isRing = 1; 
    if coreTop >= coreBottom
        isRing = 0; 
    end

    % wake span
    if isRing
        Sw(j) = (rNorm{j}(coreTop)-rNorm{j}(top)+ rNorm{j}(bottom)-rNorm{j}(coreBottom))/2; 
    else
        Sw(j) = Dw(j)/2; 
    end

    % calculating Vw to be area-based avg of uNorm inside wake
    % I = 2*pi*integral(uNorm*rNorm*drNorm) from rNorm(coreTop) to
    % rNorm(top) + same integral in bottom region of wake, all /2. Use
    % trapezoid integration. 
    % A = 0.25*pi*(Dw^2-(Dw-Sw)^2); 
    % Vw{j} = I/A; 
end

