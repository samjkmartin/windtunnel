function figTophat = plotTophat(stations,D,S,uNorm,rNorm,xD,VwFull,DwFull,SwFull,EE,xe,uAxis,rAxis,sizeFont,sizeTitle)

numStations = length(stations);

figTophat = figure;
% figTophat.WindowState = 'maximized';
for j=1:numStations
    subplot(1,numStations,j);
    plot(uNorm{j}, rNorm{j}); 
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

    % axval = axis;
    % axis([axval(1:3) -axval(3)])
    % plot(axval(1:2), [0 0], 'k:') % centerline
    % plot(uNorm{j}, rNorm{j}, ':b'); % flipped profile
    
    i = find(xD>stations(j),1)-1;
    Rwi = DwFull(i)/2; 
    rwi = Rwi - SwFull(i); 
    Vwi = VwFull(i);

    rTophat = [-2 -Rwi -Rwi -rwi -rwi rwi rwi Rwi Rwi 2];
    VwTophat = [1 1 Vwi Vwi 1 1 Vwi Vwi 1 1];
    plot(VwTophat, rTophat, 'r-');
end

fontsize(sizeFont,'points')
sgtitle({strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with'); strcat('tophat profiles from Core Flux Conservation Model (E=', num2str(EE),', x_e=',num2str(xe),')')},'fontsize',sizeTitle)
figTophat.Position = [100 200 520*[2.63 1.25]*0.95]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost

end