close all
clear all
clc

%{
This program illustrates how changing the amount of time used to acquire
a mean pressure value in the wind tunnel changes the maximum possible
deviation of that mean value from the true mean. I.e. it allows us to
quantify the accuracy of the mean pressure we record based on the amount
of time we average over in order to get that mean. 
%}

%% Free Stream Data

figFreeStream = openfig('pin_A0_FreeStream_300s.fig', 'invisible');
freeStream = get(gca,'Children');

sampleNums = get(freeStream, 'XData');
dt = 0.05; % for 20 Hz data from pressure transducer
time = sampleNums*dt; 

voltage = get(freeStream, 'YData');
meanvolts = mean(voltage)

close

sampleTimeRange = 1:60;
maxDiffs = zeros(length(sampleTimeRange),1);
meanStDevs = maxDiffs;
for j=1:length(sampleTimeRange)
    sampleTime = sampleTimeRange(j); 
    samplePoints = ceil(sampleTime/dt);

    voltMeans = zeros(length(time)-samplePoints,1);
    stDevs = voltMeans;
    for i=1:length(voltMeans)
        voltMeans(i) = mean(voltage(i:i+samplePoints));
        stDevs(i) = std(voltage(i:i+samplePoints));
    end

    diff = voltMeans-meanvolts;
    maxDiffs(j) = max(abs(diff));
    meanStDevs(j) = mean(stDevs); 
end

hold on
plot(sampleTimeRange, maxDiffs, sampleTimeRange, meanStDevs)
xlabel('sample time (s)')
ylabel('\Deltap (inches of water)')
title('Maximum excursion of recorded mean dynamic pressure from true mean')
subtitle('S/D=0.2, 5 mins of data')

%% Wake Nadir Data

figWakeNadir = openfig('pin_A0_WakeNadir_300s.fig','invisible');
wakeNadir = get(gca,'Children');

sampleNums = get(wakeNadir, 'XData');
dt = 0.05; % for 20 Hz data from pressure transducer
time = sampleNums*dt; 

voltage = get(wakeNadir, 'YData');
meanvolts = mean(voltage)

close

sampleTimeRange = 1:60;
maxDiffs = zeros(length(sampleTimeRange),1);
meanStDevs = maxDiffs;
for j=1:length(sampleTimeRange)
    sampleTime = sampleTimeRange(j); 
    samplePoints = ceil(sampleTime/dt);

    voltMeans = zeros(length(time)-samplePoints,1);
    stDevs = voltMeans;
    for i=1:length(voltMeans)
        voltMeans(i) = mean(voltage(i:i+samplePoints));
        stDevs(i) = std(voltage(i:i+samplePoints));
    end

    diff = voltMeans-meanvolts;
    maxDiffs(j) = max(abs(diff));
    meanStDevs(j) = mean(stDevs); 
end

hold on
plot(sampleTimeRange, maxDiffs, sampleTimeRange, meanStDevs)
legend('Free Stream', 'Free Stream, mean std dev of X-second sample', 'Wake Nadir', 'Wake Nadir, mean std dev of X-second sample')
