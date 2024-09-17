function figGaussFit = plotGaussFit(stations,D,S,uNorm,rNorm,xD,VwFull,DwFull,SwFull,EE,xe,uAxis,rAxis,sizeFont,sizeTitle);
% ufit = sum of two Gaussians
% ufit = 1-deltaU*(exp((r-Rp)^2/b^2)+exp(same but r+Rp))
% deltaU is the mean of the maximum velocity deficits for the two peaks
% Rp is the mean of the locations of the two peaks in r/D coordinates
% b is the width of the peak

numStations = length(stations);
R = D/2; 
SDcrit = 0.5; 

SwFullStations = zeros(numStations,1); 
DwFullStations = SwFullStations; 

for j=1:numStations
    i = find(xD>stations(j),1)-1;
    DwFullStations(j) = DwFull(i); % Value of Dw at each station (for Gaussian fitting)
    Rwi = DwFull(i)/2; 
    rwi = Rwi - SwFull(i); 
    Vwi = VwFull(i);
    SwFullStations(j) = SwFull(i); % Value of Sw at each station (for Gaussian fitting)
end

% define deltaU, Rp, and b using curve fitting
doubleGauss = fittype(@(deltaU,Rp,b,rGauss) 1 - deltaU*(exp(-((rGauss-Rp)/b).^2)+exp(-((rGauss+Rp)/b).^2)),'independent','rGauss');
gaussFit = cell(numStations,1);

rGauss = (-2.5:0.01:2.5)';
ufit = zeros(length(rGauss),numStations); 

figGaussFit = figure;

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
    
    startPoints = [0.5,(R-S/2)/D,S/D];
    gaussFit{j} = fit(rNorm{j},uNorm{j},doubleGauss,'StartPoint',startPoints);
    deltaU(j) = gaussFit{j}.deltaU;
    Rp(j) = gaussFit{j}.Rp;
    b(j) = gaussFit{j}.b; 
    
    hold on
    % NOTE: it probably doesn't make sense to have this if/else because the
    % fit function was applied to the double-gaussian, so the
    % single-Gaussian won't look right.
    % if (SwFullStations(j)/DwFullStations(j))>=SDcrit % if the wake is circular
    %     ufit(:,j) = 1 - 2*deltaU(j).*(exp(-(rGauss).^2/b(j)^2));
    % else % if the wake is annular
        ufit(:,j) = 1 - deltaU(j).*(exp(-((rGauss-Rp(j))/b(j)).^2)+exp(-((rGauss+Rp(j))/b(j)).^2));
    % end
    plot(ufit(:,j),rGauss, 'r--')
    
    if j==2
        legend('Wind tunnel data', 'Gaussian fit','location','southeast')
    end
end
fontsize(sizeFont,'points')
sgtitle(strcat('Wind tunnel velocity profiles for S/D=', num2str(S/D),' compared with empirical Gaussian profiles'),'fontsize',sizeTitle)
figGaussFit.Position = [100 200 520*[2.63 1.25]*0.95]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost

end