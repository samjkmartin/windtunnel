clc; clear; close all;

data = readmatrix("A3_2023.csv");

widthData   = width(data);
numStations = widthData/2; % Number of stations
firstStation = 1; 
stations = [firstStation:numStations+firstStation-1]'; 

% crank location of the center of the wake per station
crankOffsets = [27.75 26.75 24.75 26.75 26.5 26.5 26.25 26.5]; 

% Information about the disc/setup in mm
D = 50; % disc diameter
R = D/2; % radius
S = 5; % span of annular disc (outer radius minus inner radius)
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

    r = crankHeight*(cranks{j}-crankOffsets(j)); % vertical position in mm relative to the center of the disc
    rNorm{j} = r/D;
    
    pInfty = pressure{j}(1); 
    uNorm{j} = sqrt(pressure{j}/pInfty); 
   
    % Create figure
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim([0.7 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i', firstStation + j - 1))
    xlabel('U/U_{\infty}')
    ylabel('r/D')

    hold on
    axval = axis;
    axis([axval(1:3) -axval(3)])
    plot(axval(1:2), [0 0], 'k:') % centerline
    plot(uNorm{j}, rNorm{j}, ':b'); % flipped profile
end
sgtitle(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)))

% allfig = figure;
pcfig = figure;
pcfig.WindowState = 'maximized';
for j = 1:numStations
    plot(uNorm{j}, -rNorm{j})
    hold on
end
axval = axis;
axis([axval(1:3) -axval(3)])
plot(axval(1:2), [0 0], 'k:') % centerline
xlim([0.7 1])
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
title(strcat('Calculated drag coefficient of porous annular disc with S/D=',num2str(S/D)))
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

    % calculating Sw (wake span) and Vw (area-based avg of uNorm inside wake) 
    if isRing
        Sw(j) = (rNorm{j}(coreTop)-rNorm{j}(top)+ rNorm{j}(bottom)-rNorm{j}(coreBottom))/2; 
        uTop = uNorm{j}(top:coreTop);
        rTop = rNorm{j}(top:coreTop);
        uBottom = uNorm{j}(coreBottom:bottom);
        rBottom = rNorm{j}(coreBottom:bottom);
        I = pi*(trapz(rTop, uTop.*abs(rTop))+trapz(rBottom, uBottom.*rBottom)); % 2*pi*Integral is double-counting because we're using both positive and "negative" r, so we divide by 2
        Aring = 0.25*pi*(Dw(j)^2-(Dw(j)-2*Sw(j))^2);
        Vw(j) = I/Aring;
    else
        Sw(j) = Dw(j)/2;
        I = pi*(trapz(rNorm{j}(top:bottom),abs(rNorm{j}(top:bottom)).*uNorm{j}(top:bottom)));
        Aring = 0.25*pi*Dw(j)^2; 
        Vw(j) = I/Aring;
    end
end

% Mean wake comparison with 1-D entrainment models
CT = mean(CD(1:8));
EE = 0.25;
xe = 0.5;
xmax = 10;
if contains(path,'sam')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/Models','-end')
else
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/Models','-end')
end
[xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 


pcfig = figure;
pcfig.WindowState = 'maximized';
subplot(2,1,1)
plot(stations,Vw,'k*')
hold on
plot(xD,VwFull,'b-','linewidth',1)
xlim([0 stations(end)])
ylim([0.5 1])
title('Mean Wake Velocity')
ylabel('V_w/V_{\infty}')
legend('Wind tunnel data',strcat('Full Model (E=',num2str(EE),', x_e=',num2str(xe),')'),'location','southeast','fontsize',14)

% % testing out a range of entrainment coefficients
% for i=1:4
%     EE = 0.2+0.02*i;
%     [xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 
%     plot(xD,VwFull)
% end

subplot(2,1,2)
plot(stations,Dw/2,'k*',stations,Dw/2-Sw,'k*')
hold on 
plot(xD, DwFull/2, 'b-','linewidth',1)
plot(xD, DwFull/2-SwFull, 'b-','HandleVisibility','off','linewidth',1); 
xlim([0 stations(end)])
xlabel('x/D')
ylabel('r/D')
title('Wake Boundary')
sgtitle(strcat('Tophat Wake Velocity and Boundaries for S/D=', num2str(S/D)))

%% tophat model on top of velocity profiles

% preparing for the Gaussian fit, which happens later
SwFullStations = zeros(j,1); 
DwFullStations = SwFullStations; 

pcfig = figure;
pcfig.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim([0.7 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i', firstStation + j - 1))
    xlabel('U/U_{\infty}')
    ylabel('r/D')

    hold on

    % axval = axis;
    % axis([axval(1:3) -axval(3)])
    % plot(axval(1:2), [0 0], 'k:') % centerline
    % plot(uNorm{j}, rNorm{j}, ':b'); % flipped profile
    
    i = find(xD>stations(j),1)-1;
    DwFullStations(j) = DwFull(i); % Value of Dw at each station (for Gaussian fitting)
    Rwi = DwFull(i)/2; 
    rwi = Rwi - SwFull(i); 
    Vwi = VwFull(i);

    rTophat = [-2 -Rwi -Rwi -rwi -rwi rwi rwi Rwi Rwi 2];
    VwTophat = [1 1 Vwi Vwi 1 1 Vwi Vwi 1 1];
    plot(VwTophat, rTophat, 'r-');

    SwFullStations(j) = SwFull(i); % Value of Sw at each station (for Gaussian fitting)
end
sgtitle(strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with tophat profiles from Core Flux Conservation Model (E=', num2str(EE),', x_e=',num2str(xe),')'))

%% Gaussian fit on top of velocity profiles

% Version 1: define deltaU and Rp using data, but define b using Sw from tophat model
% ufit = sum of two Gaussians
% ufit = 1-deltaU*(exp((r-Rp)^2/b^2)+exp(same but r+Rp))
% deltaU is the mean of the maximum velocity deficits for the two peaks
% Rp is the mean of the locations of the two peaks in r/D coordinates
% b, the width of the peak, is defined by the tophat model: b = Sw/e

% finding average location, magnitude, and width of velocity deficit peaks
Rp = zeros(numStations,1); 
deltaU = Rp; 
b = Rp; 
SDcrit = 0.5; % criteria for S/D to determine if wake is annular or circular

for j=1:numStations
    if (SwFullStations(j)/DwFullStations(j))>=SDcrit % if wake is circular
        deltaU(j) = 1-min(uNorm{j});
        Rp(j) = 0;
        b(j) = DwFullStations(j)/exp(1); 
    else % if wake is annular
        uMin1 = min(uNorm{j}(1:find(rNorm{j}>0,1)));
        uMin2 = min(uNorm{j}(find(rNorm{j}>0,1):end));
        Rp1 = rNorm{j}(find(uNorm{j}==uMin1,1)); 
        Rp2 = rNorm{j}(find(uNorm{j}==uMin2,1)); 
        deltaU(j) = 1-(uMin1+uMin2)/2;
        Rp(j) = (abs(Rp1)+abs(Rp2))/2; 
        b(j) = SwFullStations(j)/exp(1); 
    end
end

rGauss = (-2.5:0.01:2.5)';
ufit = zeros(length(rGauss),numStations); 

pcfig = figure;
pcfig.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim([0.7 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i', firstStation + j - 1))
    xlabel('U/U_{\infty}')
    ylabel('r/D')
    
    hold on
    if (SwFullStations(j)/DwFullStations(j))>=SDcrit % if the wake is circular
        ufit(:,j) = 1 - deltaU(j).*(exp(-(rGauss).^2/b(j)^2));
    else % if the wake is annular
        ufit(:,j) = 1 - deltaU(j).*(exp(-((rGauss-Rp(j))/b(j)).^2)+exp(-((rGauss+Rp(j))/b(j)).^2));
    end
    plot(ufit(:,j),rGauss)
end
sgtitle(strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with empirical/tophat hybrid Gaussian profiles'))

%% Version 2: define deltaU, Rp, and b using curve fitting
doubleGauss = fittype(@(deltaU,Rp,b,rGauss) 1 - deltaU*(exp(-((rGauss-Rp)/b).^2)+exp(-((rGauss+Rp)/b).^2)),'independent','rGauss');
gaussFit = cell(numStations,1);

pcfig = figure;
pcfig.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim([0.7 1])
    ylim([-1.5 1.5])
    title(sprintf('x/D = %i', firstStation + j - 1))
    xlabel('U/U_{\infty}')
    ylabel('r/D')
    
    startPoints = [0.5,(R-S/2)/D,S/D];
    gaussFit{j} = fit(rNorm{j},uNorm{j},doubleGauss,'StartPoint',startPoints);
    deltaU(j) = gaussFit{j}.deltaU;
    Rp(j) = gaussFit{j}.Rp;
    b(j) = gaussFit{j}.b; 
    
    hold on
    if (SwFullStations(j)/DwFullStations(j))>=SDcrit % if the wake is circular
        ufit(:,j) = 1 - deltaU(j).*(exp(-(rGauss).^2/b(j)^2));
    else % if the wake is annular
        ufit(:,j) = 1 - deltaU(j).*(exp(-((rGauss-Rp(j))/b(j)).^2)+exp(-((rGauss+Rp(j))/b(j)).^2));
    end
    plot(ufit(:,j),rGauss)
end
sgtitle(strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with empirical Gaussian profiles'))
