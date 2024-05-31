close all
clear all
clc

data = readmatrix('fast_nadir.csv'); 
time = data(2:end,3) - data(2,3);
voltage = data(2:end,2); 

subplot(1,3,1)
plot(time,voltage);

dt = (time(end)-time(1))/(length(time)-1); 
avgtime = 5; %seconds 
avgpoints = ceil(avgtime/dt); 

voltmeans = zeros(length(time)-avgpoints,1); 

for i=1:length(voltmeans)
    voltmeans(i) = mean(voltage(i:i+avgpoints));
end

meanvolts = mean(voltage); 
diff = voltmeans-meanvolts; 

subplot(1,3,2)
plot(dt*(1:length(voltmeans)), meanvolts*ones(length(voltmeans),1), dt*(1:length(voltmeans)), voltmeans); 

subplot(1,3,3)
plot(dt*(1:length(voltmeans)), diff); 