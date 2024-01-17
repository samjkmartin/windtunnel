clc;
clear all;
close all;

if contains(path,'sam')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/DataFunctions','-end')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/Models','-end')
else
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/DataFunctions','-end')
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/Models','-end')
end

% Information about the disc
discName = 'A7';
D = 50; % diameter in mm
R = D/2; % Disc radius
S = 20; % span in mm

stations = [2:9];
numStations = length(stations);

crankHeight = 3; % mm per crank
crankOffsets = [33.75,33.5,33.5,33.5,33.5,33,33.5,33.5]; % to set position of r=0 for each disc

cranks = cell(numStations,1); 
r = cranks; 
pressure = cranks; 
rNorm = cranks;
uNorm = cranks; 

uAxis = [0.55 1]; % U axis values for all velocity profile plots
rAxis = [-1.2 1.2]; % r axis values for all velocity profile plots
sizeFont = 20; % default font size for multi-panel figures
sizeTitle = 24; % default title font size for multi-panel figures

% convert raw data into normalized radial position and velocity
for j=1:numStations
    data = readmatrix(strcat(discName,'S',num2str(stations(j)),'.csv'));
    cranks{j} = data(:,2); % number of cranks up from starting probe position
    pressure{j} = data(:,4); % dynamic pressure in inches of water
    
    r = crankHeight*(cranks{j}-crankOffsets(j)); % vertical position in mm relative to the center of the disc
    rNorm{j} = r/D;
    
    pInfty = pressure{j}(1); 
    uNorm{j} = sqrt(pressure{j}/pInfty); 
end

figProfiles = plotUR(stations,S,D,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle); 
% exportgraphics(figProfiles, strcat('SD0,', num2str(100*S/D), '_profiles.pdf'),'ContentType','vector','BackgroundColor','none')

figOverlap = plotOverlap(stations,S,D,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle); 

uMax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc
[CD, figCD] = dragCoeff(stations,S,D,uNorm,rNorm,uMax,14,14);

[Vw, Dw, Sw, figMeanWake] = meanWake(stations,S,D,uNorm,rNorm,uMax,14,14);

CT = mean(CD);
EE = 0.12; 
xe = 0.5; 
xmax = 10;
[xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 

figVw = compareVw(stations,S,D,Vw,xD,VwFull); 


%{
%% Mean wake comparison with 1-D (tophat) entrainment models

CT = mean(CD);
EE = 0.12; 
xe = 0.5; 
xmax = 10;
if contains(path,'sam')
    addpath('/Users/samjkmartin/Documents/MATLAB/windtunnel/Models','-end')
else
    addpath('/Users/smartin/Documents/MATLAB/Github/windtunnel/Models','-end')
end
[xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 

figVw = figure;
% figVw.WindowState = 'maximized';
% subplot(2,1,1)
plot(stations,Vw,'ko','MarkerFaceColor','k')
hold on
plot(xD,VwFull,'b-','linewidth',1)
xlim([0 stations(end)])
ylim([0.5 1])
xlabel('x/D')
ylabel('V_w/V_{\infty}')
legend('Wind tunnel data',strcat('Full Model (E=',num2str(EE),', x_e=',num2str(xe),')'),'location','southeast','fontsize',14)
fontsize(sizeFont,'points')
% title(strcat('Mean Wake Velocity for S/D=',num2str(S/D)),'FontSize',sizeTitle)
figVw.Position = [100 200 520*[2.63 1]*0.95]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost
% exportgraphics(figVw, strcat('SD0,', num2str(100*S/D), '_Vw.pdf'),'ContentType','vector','BackgroundColor','none')

% % testing out a range of entrainment coefficients
% for i=1:4
%     EE = 0.16+0.02*i;
%     [xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 
%     plot(xD,VwFull)
% end

%{
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
%}

%% tophat model on top of velocity profiles

% preparing for the Gaussian fit, which happens later
SwFullStations = zeros(j,1); 
DwFullStations = SwFullStations; 

figTophat = figure;
% figTophat.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim(uAxis)
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
    xlabel('U/U_{\infty}')
    if j==1
        ylabel('r/D')
    else
        set(gca,'Yticklabel',[])
    end

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
% set(gcf,'color','white')
fontsize(sizeFont,'points')
% sgtitle({strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with'); strcat('tophat profiles from Core Flux Conservation Model (E=', num2str(EE),', x_e=',num2str(xe),')')},'fontsize',sizeTitle)
figTophat.Position = [100 200 520*[2.63 1]*0.95]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost
exportgraphics(figTophat, strcat('SD0,', num2str(100*S/D), '_tophat.pdf'),'ContentType','vector','BackgroundColor','none')

%% Gaussian fit on top of velocity profiles

%% Version 1: define deltaU and Rp using data, but define b using Sw from tophat model
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

%{
figHybrid = figure;
figHybrid.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim(uAxis)
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
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
%}

%% Version 2: define deltaU, Rp, and b using curve fitting
doubleGauss = fittype(@(deltaU,Rp,b,rGauss) 1 - deltaU*(exp(-((rGauss-Rp)/b).^2)+exp(-((rGauss+Rp)/b).^2)),'independent','rGauss');
gaussFit = cell(numStations,1);

figGauss = figure;
% figGauss.WindowState = 'maximized';
% set(gcf,'color','white')
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, -rNorm{j}) % flipped because for this dataset, row 1 corresponds to top of wake, so this orients the velocity profile as it was in real life
    xlim(uAxis)
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
    xlabel('U/U_{\infty}')
    if j==1
        ylabel('r/D')
    else
        set(gca,'Yticklabel',[])
    end
    
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
    plot(ufit(:,j),rGauss, 'r--')
    
    if j==2
        legend('Wind tunnel data', 'Gaussian fit','location','southeast')
    end
end
fontsize(sizeFont,'points')
sgtitle(strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with empirical Gaussian profiles'),'fontsize',sizeTitle)
figGauss.Position = [100 200 520*[2.63 1]*0.95]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost
exportgraphics(figGauss, strcat('SD0,', num2str(100*S/D), '_Gaussian.pdf'),'ContentType','vector','BackgroundColor','none')
%}