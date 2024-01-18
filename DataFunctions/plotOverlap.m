function figOverlap = plotOverlap(stations,D,S,uNorm,rNorm,uAxis,rAxis,sizeFont,sizeTitle)
% plots velocity profiles with r/D on the vertical axis and u/Uinf on the horizontal axis
% velocity profiles for all x/D are plotted overlapping in one figure

numStations = length(stations);

figOverlap = figure; 
for j = 1:numStations
    plot(uNorm{j}, -rNorm{j})
    hold on
end

axval = axis;
axis([axval(1:3) -axval(3)])
plot(axval(1:2), [0 0], 'k:') % centerline
xlim(uAxis)
ylim(rAxis)
xlabel('U/U_{\infty}')
ylabel('r/D')

legends = cell(numStations,1); 
for j = 1:numStations
    legends{j} = strcat('x/D=', num2str(stations(j)));
end
legend(legends,'location','northwest')

fontsize(sizeFont,'points')
title(strcat('Normalized Velocity Profiles for S/D=', num2str(S/D)),'FontSize',sizeTitle)
figOverlap.Position = [100 200 520*[2.63 1.5]*0.95]; 

end