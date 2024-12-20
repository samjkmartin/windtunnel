function figStdDev = plotStdDev(stations,D,S,pInfty,pressure,stdDevP,uNorm,stdDevU,rNorm,rAxis,sizeFont,sizeTitle)
% plots velocity profiles with r/D on the vertical axis and u/Uinf on the horizontal axis
% profiles at different x/D get their own subplots

numStations = length(stations);

figStdDev = figure; 
for j=1:numStations
    subplot(1,numStations,j);
    plot(stdDevP{j}/pInfty(j), rNorm{j})
    hold on
    plot(stdDevU{j}, rNorm{j})
    legend('\Deltap/p_{\infty}', '\DeltaU/U_{\infty}')
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
    xlabel('Std. Dev.')
    if j==1
        ylabel('r/D')
    else
        set(gca,'Yticklabel',[])
    end
end
fontsize(sizeFont,'points')
sgtitle(strcat('Standard Deviation of Dynamic Pressure and Normalized Velocity for S/D=', num2str(S/D)),'fontsize',sizeTitle)
figStdDev.Position = [75 200 520*[2.63 1]*0.95]; 

end