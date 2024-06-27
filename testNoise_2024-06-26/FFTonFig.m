% run FFT on figure with 10sec of data measured at 20Hz

a = get(gca,'Children');
xdata = get(a, 'XData');
ydata = get(a, 'YData');
noise = ydata - mean(ydata);
F = fft(noise);

figure
plot((0:199)/10, abs(F))
xlabel('frequency (Hz)')
ylabel('|fft(pressure|')
xlim([0 10])