CT1 = 0:0.01:0.96;
CT2 = 0.96:0.01:2;
plot(CT1,1/2 - sqrt((1-CT1)/4),CT2,1/7 + (3/14)*sqrt(14*CT2-12))
xlabel('CT')
ylabel('a')
grid on