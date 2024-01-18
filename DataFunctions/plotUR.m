function figProfiles = plotUR(stations,D,S,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle)
% plots velocity profiles with r/D on the vertical axis and u/Uinf on the horizontal axis
% profiles at different x/D get their own subplots

numStations = length(stations);

figProfiles = figure; 
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, rNorm{j})
    xlim(uAxis)
    ylim(rAxis)
    title(sprintf('x/D = %i', stations(j)))
    xlabel('U/U_{\infty}')
    if j==1
        ylabel('r/D')
    else
        set(gca,'Yticklabel',[])
    end

    hold on
    axval = axis;
    axis([axval(1:3) -axval(3)])
    plot(axval(1:2), [0 0], 'k:') % centerline
    plot(uNorm{j}, -rNorm{j}, ':b'); % flipped profile
end
fontsize(sizeFont,'points')
sgtitle(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)),'fontsize',sizeTitle)
figProfiles.Position = [100 200 520*[2.63 1]*0.95]; 

end