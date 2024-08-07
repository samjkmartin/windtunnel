function [xD,Vw,Dw,Sw] = cfcModel(D,S,CT,EE,xe,xmax)
% by Sam Kaufman-Martin

%% Function description

% This function models the wake of an annular object facing perpendicularly to a uniform oncoming flow. 
% The model used is the Core Flux Conservation Model from Kaufman-Martin et al. (2022).

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

if ((D<=0)||(S<=0)||(CT<=0)||(EE<=0)||(xmax<=0)||(S>D/2)||(CT>2)||(EE>1))
    disp('Error: check that your inputs are correct.'); 
    disp('D, S, CT, EE, and xmax must all be positive, real values.');
    disp('S must be less than or equal to D/2.');
    disp('CT must be less than or equal to 2.')
    disp('EE must be less than or equal to 1.')
    return
end

% CT = 4*a*(1-a)
% CT/4 = a - a^2
% a^2 - a = -CT/4
% a^2 - a + 1/4 = 1/4 - CT/4
% (a - 1/2)^2 = (1-CT)/4
% a - 1/2 = -sqrt((1-CT)/4)
S = S/D; % normalizing by D
D = 1; 
if CT <= 0.96
    a = 1/2 - sqrt((1-CT)/4); % calculate axial induction factor from CT
else
    a = (20 + 3*sqrt(CT*50))/50; % Glauert correction for a>0.4
end
Vinf = 1; % this code defaults to calculating normalized velocity, i.e. the free-stream velocity Vinf = 1

% Initial Conditions
Vw0 = Vinf*(1 - 2*a);
Dw0 = sqrt(D^2+(4*a/(1-2*a))*(S*D-S^2));
Sw0 = S + (Dw0-D)/2;

% Convert ICs into mass and momentum fluxes
mi0 = .25*Vinf*(Dw0 - 2*Sw0)^2;
ma0 = Vw0*Sw0*(Dw0 - Sw0);
Ma0 = Vw0^2*Sw0*(Dw0 - Sw0);
ICs = [mi0, ma0, Ma0];

% Solve system of eqns (see function at end) in ODE 45
xspan = [0 xmax];
[x, f] = ode45(@(x,f)odefun(x,f,EE,Vinf),xspan,ICs);
mi = f(:,1);
ma = f(:,2);
Ma = f(:,3);

% Convert fluxes back into velocities and lengths
Vw = Ma./ma; 
Dw = 2*sqrt(mi./Vinf + ma.^2./Ma);
Sw = sqrt(mi./Vinf + ma.^2./Ma) - sqrt(mi./Vinf);

Vw = real(Vw);
Dw = real(Dw);
Sw = real(Sw);

% adjust x/D by expansion length
xD = x + xe; 

% % plot
% subplot(2,1,1)
% plot(xD,Vw,'b-','linewidth',1)
% subplot(2,1,2)
% plot(x, Dw/2, 'b-','linewidth',1)
% hold on
% plot(x, Dw/2-Sw, 'b-','HandleVisibility','off','linewidth',1); 
% plot(x, -Dw/2, 'b-','HandleVisibility','off','linewidth',1); 
% plot(x, -(Dw/2-Sw), 'b-','HandleVisibility','off','linewidth',1); 

end

%% Differential equations (the heart of the CFC model) to be solved by ODE45
function derivs = odefun(x, f, EE, Vinf)
derivs = [-2*EE*(Vinf-f(3)/f(2))*sqrt(f(1)/Vinf);
    2*EE*(Vinf-f(3)/f(2))*((f(1)/Vinf + f(2)^2/f(3))^.5 + sqrt(f(1)/Vinf)); 
    2*EE*(Vinf-f(3)/f(2))*((f(1)/Vinf + f(2)^2/f(3))^.5 + sqrt(f(1)/Vinf))*Vinf];
end