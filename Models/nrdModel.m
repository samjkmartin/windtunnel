function [xD,Vw,Dw,Sw] = nrdModel(D,S,CT,EE,xe,xmax)
% by Sam Kaufman-Martin

%% Function description

% This function models the wake of an annular object facing perpendicularly to a uniform oncoming flow. 
% The model used is the No Radial Drift Model from Kaufman-Martin et al. (2022).

% Inputs: 
% D = outer diameter of an annular object
% S = span of the object ((D - inner diameter)/2). Must be between 0 and 0.5 
% CT = thrust coefficient of the object (must be between 0 and 1)
% EE = entrainment coefficient of the flow (between 0 and 1)
% xe = expansion length (empirical constant for the model, usually between 0 and 1)
% xmax = farthest value of x/D (normalized distance behind the turbine) for which you want to model the wake behind the turbine

% Outputs: 
% xD = x/D over which the calculation is performed (independent variable)
% Dw = outer diameter of the wake, normalized by D
% Sw = span of the wake, normalized by D
% Vw = mean velocity of the wake, normalized by the free-stream velocity

%%

if ((D<=0)||(S<=0)||(CT<=0)||(EE<=0)||(xmax<=0)||(S>D/2)||(CT>1)||(EE>1))
    disp('Error: check that your inputs are correct.'); 
    disp('D, S, CT, EE, and xmax must all be positive, real values.');
    disp('S must be less than or equal to D/2.');
    disp('CT must be less than or equal to 1.')
    disp('EE must be less than or equal to 1.')
    return
end

S = S/D; % normalizing by D
D = 1; 
a = 1/2 - sqrt((1-CT)/4); % calculate axial induction factor from CT
Vinf = 1; % this code defaults to calculating normalized velocity, i.e. the free-stream velocity Vinf = 1
x = 0:0.1:xmax; 

% Initial Conditions
Vw0 = Vinf*(1 - 2*a);
Dw0 = sqrt(D^2+(4*a/(1-2*a))*(S*D-S^2));
Sw0 = S + (Dw0-D)/2;

% Uses same ICs as 1st model
C1 = Sw0*Vw0*(Vinf-Vw0);
xc = -Sw0*(1-2*a)/(8*EE*a);
Vw = Vinf*(1-sqrt(Sw0*a*(1-2*a)./(2*EE*(x-xc)))); 
Sw = C1./(Vw.*(Vinf-Vw));
Dw = Dw0 - Sw0 + Sw;

% adjust x/D by expansion length
xD = x + xe; 

% % plot
% subplot(2,1,1)
% plot(xD,Vw,'b-','linewidth',1)
% subplot(2,1,2)
% plot(xD, Dw/2, 'b-','linewidth',1)
% hold on
% plot(xD, Dw/2-Sw, 'b-','HandleVisibility','off','linewidth',1); 
% plot(xD, -Dw/2, 'b-','HandleVisibility','off','linewidth',1); 
% plot(xD, -(Dw/2-Sw), 'b-','HandleVisibility','off','linewidth',1); 

end