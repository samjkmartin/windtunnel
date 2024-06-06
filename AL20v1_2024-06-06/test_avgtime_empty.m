% close all
clear all
clc

%{
This program illustrates how changing the amount of time used to acquire
a mean pressure value in the wind tunnel changes the maximum possible
deviation of that mean value from the true mean. I.e. it allows us to
quantify the accuracy of the mean pressure we record based on the amount
of time we average over in order to get that mean. 
%}

%% fast data

data = readmatrix('fast_empty.csv'); 
voltage = data(2:end,2); 
time = data(2:end,3) - data(2,3);

meanvolts = mean(voltage); 
dt = (time(end)-time(1))/(length(time)-1); 

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
subtitle('empty WT, 5 mins of data')

%% slow data

data = readmatrix('slow_empty.csv'); 
voltage = data(2:end,2); 
time = data(2:end,3) - data(2,3);

meanvolts = mean(voltage); 
dt = (time(end)-time(1))/(length(time)-1); 

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

hold on
plot(avgtimerange, maxdiffs)
legend('fast','slow')
% xlabel('averaging time (s)')
% ylabel('\Deltap (inches of water)')
% title('Maximum excursion of recorded mean dynamic pressure from true mean')
% subtitle('empty WT, 5 mins of data')
