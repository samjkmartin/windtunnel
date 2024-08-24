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

%% S/D=0.5 wake S4 crank 29

data = readmatrix('AL50v1S4_5mins.csv');

dt = 0.05; % for 20 Hz data from pressure transducer
time = 0.05:0.05:300;

voltage = data(4,:);
meanvolts = mean(voltage)

pInfty = mean(data(1,1:200));

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
% plot(sampleTimeRange, maxDiffs, sampleTimeRange, meanStDevs) % plot Delta p (inches of water)
% ylabel('\Deltap (inches of water)')
plot(sampleTimeRange, maxDiffs/meanvolts, sampleTimeRange, meanStDevs/meanvolts)
ylabel('\Deltap/p')
xlabel('sample time (s)')
title('Maximum excursion of recorded mean dynamic pressure from true mean')
subtitle('S/D=0.5, 5 mins of data')
legend('Crank 29', 'Crank 29, mean std dev of X-second sample')
