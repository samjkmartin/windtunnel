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

data = readmatrix('Solid10v1S4.csv');

dt = 0.05; % for 20 Hz data from pressure transducer
time = 0.05:0.05:300;

pInfty = mean(data(3,6:205));

voltage = data(32,6:end);
meanvolts = mean(voltage)

meanU = sqrt(meanvolts/pInfty)

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

figure
plot(sampleTimeRange, maxDiffs, sampleTimeRange, meanStDevs) % plot Delta p (inches of water)
ylabel('\Deltap (inches of water)')
xlabel('sample time (s)')
title('Maximum excursion of recorded mean dynamic pressure from true mean')
subtitle('S/D=0.1, solidity=1, 5 mins of data, Station 4, Crank 27.25')
legend('maximum excursion for X-second sample', 'mean std dev of X-second sample')
ylim([0 inf])

figure
plot(sampleTimeRange, maxDiffs/pInfty, sampleTimeRange, meanStDevs/pInfty)
ylabel('\Deltap/p_{\infty}')
xlabel('sample time (s)')
title('Maximum excursion of recorded mean normalized pressure from true mean')
subtitle('S/D=0.1, solidity=1, 5 mins of data, Station 4, Crank 27.25')
legend('maximum excursion of X-second sample', 'mean std dev of X-second sample')
ylim([0 inf])

figure
plot(sampleTimeRange, 0.5*maxDiffs/sqrt(meanvolts*pInfty), sampleTimeRange, 0.5*meanStDevs/sqrt(meanvolts*pInfty))
ylabel('\DeltaU/U_{\infty}')
xlabel('sample time (s)')
title('Maximum excursion of recorded mean normalized velocity from true mean')
subtitle('S/D=0.1, solidity=1, 5 mins of data, Station 4, Crank 27.25')
legend('maximum excursion of X-second sample', 'mean std dev of X-second sample')
ylim([0 inf])