% Drag force estimator

% Flow info
U = 44; % free streem velocity m/s
rho = 1.18; % air density kg/m^3

% Information about the disc
D = 0.05; % diameter in m
R = D/2; % Disc radius
S = 0.02; % span in m
CD = 0.8668; % drag coefficient

FD = 0.5*rho*CD*U^2*pi*(R^2-(R-S)^2); % drag force in Newtons
FDgrams = 1000*FD/9.81 % drag "force" in grams under 1g gravity