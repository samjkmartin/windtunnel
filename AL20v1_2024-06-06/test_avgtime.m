% close all
clear all
clc

%{
This program illustrates how changing the amount of time used to acquire
a mean pressure value in the wind tunnel changes the maximum possible
deviation of that mean value from the true mean. I.e. it allows us to
quantify the accuracy of the mean pressure we record based on the amount
of time we average over in order to get that mean. 

This data from 4/11/24 was measured at a nadir of the S/D=0.2 annular wake (directly
downstream of mid-span) for about 110 seconds using the "fast" setting. 
%}

data = readmatrix('slow_nadir.csv'); 
voltage = data(2:end,2); 
time = data(2:end,3) - data(2,3);

meanvolts = mean(voltage); 
dt = (time(end)-time(1))/(length(time)-1); 

% avgtime = 6; %seconds 
% avgpoints = ceil(avgtime/dt); 
% 
% voltmeans = zeros(length(time)-avgpoints,1); 
% 
% for i=1:length(voltmeans)
%     voltmeans(i) = mean(voltage(i:i+avgpoints));
% end
% 
% diff = voltmeans-meanvolts; 
% 
% subplot(1,3,1)
% plot(time,voltage);
% 
% subplot(1,3,2)
% plot(dt*(1:length(voltmeans)), meanvolts*ones(length(voltmeans),1), dt*(1:length(voltmeans)), voltmeans); 
% 
% subplot(1,3,3)
% plot(dt*(1:length(voltmeans)), diff); 

avgtimerange = 1:60;
maxdiffs = zeros(length(avgtimerange),1);
for j=1:length(avgtimerange)
    avgtime = avgtimerange(j); 
    avgpoints = ceil(avgtime/dt);

    voltmeans = zeros(length(time)-avgpoints,1);
    for i=1:length(voltmeans)
        voltmeans(i) = mean(voltage(i:i+avgpoints));
    end

    diff = voltmeans-meanvolts;
    maxdiffs(j) = max(abs(diff));
end

figure
plot(avgtimerange, maxdiffs)
xlabel('averaging time (s)')
ylabel('\Deltap (inches of water)')
title('Maximum excursion of recorded mean dynamic pressure from true mean')
subtitle('S/D=0.2 wake nadir, slow transducer, 120 sec of data')
% xlim([1 10])
% ylim([0 .07])