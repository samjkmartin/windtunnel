function [CD, figCD] = dragCoeff(stations,S,D,uNorm,rNorm,uMax,sizeFont,sizeTitle)
% calculates the drag coefficient of an annular disc at each station (x/D)
% for which normalized velocity profile data is provided

R = D/2; 
numStations = length(stations);

FDnorm = zeros(numStations,1); % placeholder for drag force normalized by Uinf and D
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

figCD = figure; 
plot(stations, CD, 'ko','MarkerFaceColor','k')
fontsize(sizeFont,'points')
title(strcat('Calculated drag coefficient of porous annular disc with S/D=',num2str(S/D)),'fontsize',sizeTitle)
xlabel('x/D')
ylabel('C_D')


end