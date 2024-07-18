% run FFT on figure with 10sec of data measured at 20Hz

clear

a = get(gca,'Children');
xdata = get(a, 'XData');
ydata = get(a, 'YData');
noise = ydata - mean(ydata);

sampleFreq = 20; %Hz
sampleTime = length(xdata)/sampleFreq; 

F = fft(noise);

figure
plot((0:(length(xdata)-1))/sampleTime, abs(F))
xlabel('frequency (Hz)')
ylabel('|fft(pressure)|')
xlim([0 sampleFreq/2])