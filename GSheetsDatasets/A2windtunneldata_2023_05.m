clc;
clear all;
close all;
% extracting data from the csv file
data = readmatrix('Wind tunnel data v2 2022 - 2022-10-04 annulus A2');
% initiate the velocity matrix
velocity = zeros(121,8);
% use two for loop to extract the value of v/v_infinity from data matrix
sz = size(velocity);
row = 23;
col = 7;
for j = 1:sz(2)
    for i = 1:sz(1)
        velocity(i,j)=data(row, col);
        row = row + 1;
    end
    col = col + 9;
    row = 23;
end

rOverD = zeros(121,9);
row = 23;
col = 3;
for j = 1:sz(2)
    for i = 1:sz(1)
        rOverD(i,j)=data(row, col);
        row = row + 1;
    end
    col = col + 9;
    row = 23;
end

%% r over D
rOverD1 = rOverD(:,1);
rOverD2 = rOverD(:,2);
rOverD3 = rOverD(:,3);
rOverD4 = rOverD(:,4);
rOverD5 = rOverD(:,5);
rOverD6 = rOverD(:,6);
rOverD7 = rOverD(:,7);
rOverD8 = rOverD(:,8);

%% now get the data for each x/D, and initiate the y-axis, cranks number
V1 = velocity(:,1);
cranks1 = ndgrid(0:0.5:60);

% remove all the NaNs and their crank numbers
numberofnan = sum(isnan(velocity(:,1)));
k = size(V1) - numberofnan;

for k = 1:k
    if anynan(V1(k)) == 1
    cranks1(k) = [];
    rOverD1(k) = [];
    V1(k) =[];
    end
end


%% another station
cranks2 = ndgrid(0:0.5:60);
V2 = velocity(:,2);
numberofnan = sum(isnan(velocity(:,2)));
k = size(V2) - numberofnan;

for k = 1:k
    if anynan(V2(k)) == 1
    cranks2(k) = [];
    rOverD2(k) = [];
    V2(k) =[];
    end
end


%% another station 3
cranks3 = ndgrid(0:0.5:60);
V3 = velocity(:,3);
numberofnan = sum(isnan(velocity(:,3)));
k = size(V3) - numberofnan;

for k = 1:k
    if anynan(V3(k)) == 1
    cranks3(k) = [];
    rOverD3(k) = [];
    V3(k) =[];
    end
end


%% another station 4
cranks4 = ndgrid(0:0.5:60);
V4 = velocity(:,4);
numberofnan = sum(isnan(velocity(:,4)));
k = size(V4) - numberofnan;

for k = 1:k
    if anynan(V4(k)) == 1
    cranks4(k) = [];
    rOverD4(k) = [];
    V4(k) =[];
    end
end


%% another station 5
cranks5 = ndgrid(0:0.5:60);
V5 = velocity(:,5);
numberofnan = sum(isnan(velocity(:,5)));
k = size(V5) - numberofnan;

for k = 1:k
    if anynan(V5(k)) == 1
    cranks5(k) = [];
    rOverD5(k) = [];
    V5(k) =[];
    end
end

% rOverD5 = rOverD5 - 0.0762;

%% another station 6
cranks6 = ndgrid(0:0.5:60);
V6 = velocity(:,6);
numberofnan = sum(isnan(velocity(:,6)));
k = size(V6) - numberofnan;

for k = 1:k
    if anynan(V6(k)) == 1
    cranks6(k) = [];
    rOverD6(k) = [];
    V6(k) =[];
    end
end


%% another station 7
cranks7 = ndgrid(0:0.5:60);
V7 = velocity(:,7);
numberofnan = sum(isnan(velocity(:,7)));
k = size(V7) - numberofnan;

for k = 1:k
    if anynan(V7(k)) == 1
    cranks7(k) = [];
    rOverD7(k) = [];
    V7(k) =[];
    end
end


%% another station 8
cranks8 = ndgrid(0:0.5:60);
V8 = velocity(:,8);
numberofnan = sum(isnan(velocity(:,8)));
k = size(V8) - numberofnan;

for k = 1:k
    if anynan(V8(k)) == 1
    cranks8(k) = [];
    rOverD8(k) = [];
    V8(k) =[];
    end
end

%% plot!
figure(1)
tiledlayout(1,7)
% nexttile
% xoverD_1 = plot(V1,rOverD1,'b-');
% hold on
% title('x/D=1')
% ylabel('r/D')
% xlabel('U/U_{\infty}')
% axis([0.2,1,-1.5,1.5])
% fontsize(20, 'points')

nexttile
xoverD_2 = plot(V2,rOverD2,'b-');
title('x/D=2')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_3 = plot(V3,rOverD3,'b-');
title('x/D=3')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_4 = plot(V4,rOverD4,'b-');
title('x/D=4')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_5 = plot(V5,rOverD5,'b-');
title('x/D=5')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_6 = plot(V6,rOverD6,'b-');
title('x/D=6')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_7 = plot(V7,rOverD7,'b-');
title('x/D=7')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

nexttile
xoverD_8 = plot(V8,rOverD8,'b-');
title('x/D=8')
ylabel('r/D')
xlabel('U/U_{\infty}')
axis([0.5,1,-1.5,1.5])
fontsize(20, 'points')

% %% cranks figure
% figure(2)
% tiledlayout(1,8)
% nexttile
% xoverD_1c = plot(V1,cranks1,'b--o');
% hold on
% title('x/D=1')
% ylabel('Cranks')
% xlabel('v/v_0')
% 
% nexttile
% xoverD_2c = plot(V2,cranks2,'b--o');
% title('x/D=2')
% 
% nexttile
% xoverD_3c = plot(V3,cranks3,'b--o');
% title('x/D=3')
% 
% nexttile
% xoverD_4c = plot(V4,cranks4,'b--o');
% title('x/D=4')
% 
% nexttile
% xoverD_5c = plot(V5,cranks5,'b--o');
% title('x/D=5')
% 
% nexttile
% xoverD_6 = plot(V6,cranks6,'b--o');
% title('x/D=6')
% 
% nexttile
% xoverD_7c = plot(V7,cranks7,'b--o');
% title('x/D=7')
% 
% nexttile
% xoverD_8c = plot(V8,cranks8,'b--o');
% title('x/D=8')

%% Calculating drag coefficients

% from spreadsheet: dF = pi*(ro-ri)*(ro*uo*(1-uo)+ri*ui*(1-ui)) where o=outer, i=inner

FDnorm = zeros(1,8); % Drag force normalized by density, D^2, and U^2, for stations 1-8
for i=1:8
    u = eval(strcat('V',num2str(i))); 
    rD = eval(strcat('rOverD',num2str(i))); 
%     FDnorm(i) = -2*pi*trapz(rD, u.*(1-u).*abs(rD)); % the negative sign is needed because the data is in reverse order (from positive r to negative r)
    umax = 0.98; % u/Uinf threshold above which we do not include the data points in the drag calc
    for j=1:length(u)
        if u(j) < umax
            FDnorm(i) = FDnorm(i) + pi*abs(rD(j)-rD(j-1))*(abs(rD(j))*u(j)*(1-u(j))+abs(rD(j-1))*u(j-1)*(1-u(j-1))); 
        end
    end
end
FDnorm = 0.5*FDnorm; % because we integrated from -R to R instead of 0 to R, so we double-counted

D = 5; % disc diameter, cm
R = D/2; 
S = 0.9; % disc span, cm
A = pi*(R^2 - (R-S)^2); % disc area, cm^2
Anorm = A/D^2; % normalized disc area

CD = 2*FDnorm/Anorm; 

figure
plot(1:8, CD, 'k*')

mean(CD(2:8))
