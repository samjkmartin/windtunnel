function figStdDev = plotStdDev(stations,D,S,stdDevP,stdDevU,rNorm,rAxis,sizeFont,sizeTitle)
% plots velocity profiles with r/D on the vertical axis and u/Uinf on the horizontal axis
% profiles at different x/D get their own subplots

numStations = length(stations);

figStdDev = figure; 
for j=1:numStations
    subplot(1,numStations,j);
    plot(stdDevP{j}, rNorm{j})
    hold on
    plot(stdDevU{j}, rNorm{j})
    legend('Dynamic Pressure (inches of water)', 'Normalized Velocity')
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
    xlabel('Standard Deviation')
    if j==1
        ylabel('r/D')
    else
        set(gca,'Yticklabel',[])
    end
end
fontsize(sizeFont,'points')
sgtitle(strcat('Std. Dev. of Dynamic Pressure and Normalized Velocity for S/D=', num2str(S/D)),'fontsize',sizeTitle)
figStdDev.Position = [100 200 520*[2.63 1]*0.95]; 

end