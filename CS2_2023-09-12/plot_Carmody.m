clc
clear
close all

load("xD1.mat")
load("xD2.mat")
load("xD3.mat")
load("xD4.mat")
load("xD6.mat")
load("xD9.mat")
load("xD12.mat")

U1 = Data001(:,1);
U2 = Data002(:,1);
U3 = Data003(:,1);
U4 = Data004(:,1);
U6 = Data005(:,1);
U9 = Data006(:,1);
U12 = Data007(:,1);

% U = [U1 U2 U3 U4 U6 U9 U12]; 

R1 = Data001(:,2);
R2 = Data002(:,2);
R3 = Data003(:,2);
R4 = Data004(:,2);
R6 = Data005(:,2);
R9 = Data006(:,2);
R12 = Data007(:,2);

% r = [R1 R2 R3 R4 R6 R9 R12]; 
% rD = r/2; 

% plot(U,R, 'k*');

figure
plot(U1,R1);
hold on
plot(U2,R2);
plot(U3,R3);
plot(U4,R4);
plot(U6,R6);
plot(U9,R9);
plot(U12,R12);


%%
xD = [1; 2; 3; 4; 6; 9; 12];

Fdragnorm = zeros(7,1); 

for i=1:7
    U = eval(strcat('U',num2str(xD(i)))); 
    rD = 0.5*eval(strcat('R',num2str(xD(i)))); 
    Fdragnorm(i) = 2*pi*trapz(rD, U.*(1-U).*rD);
end

% FDnorm4 = 2*pi*trapz(R4, U4.*(1-U4).*R4) 

% Fdragnorm = trapz(rD, 2*pi*U.*(1-U).*rD);

CD = 8*Fdragnorm/pi; 

figure
plot(xD(3:7),CD(3:7),'k*')

% CD = 2FD/p*A*Uinf^2
%    = 2FD/p*pi*0.25*D^2*Uinf^2
% 
% FDhat = FD/p*D^2*Uinf^2
% FD = FDhat*p*D^2*Uinf^2
% 
% CD = 2*(FDhat*p*D^2*Uinf^2)/(p*pi*0.25*D^2*Uinf^2)
%    = 2*FDhat/(pi*0.25)
%    = 8*FDhat/pi
