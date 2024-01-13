function [Vw, Dw, Sw, figMeanWake] = meanWake(stations,uNorm,rNorm,uMax);

numStations = length(stations);
Dw = zeros(numStations,1);
Sw = Dw;
Vw = Dw;
for j=1:numStations
    % finding outer wake boundaries
    top = 1;
    while uNorm{j}(top)>=uMax
        top = top+1;
    end
    bottom = length(uNorm{j});
    while uNorm{j}(bottom) >= uMax
        bottom = bottom-1;
    end

    % finding wake core boundaries
    coreTop = top;
    while uNorm{j}(coreTop)<uMax
        coreTop = coreTop+1;
    end
    coreBottom = bottom;
    while uNorm{j}(coreBottom)<uMax
        coreBottom = coreBottom-1;
    end

    % because the first set of while loops overshoot the outer edges
    top = top-1;
    bottom = bottom+1;

    % wake diameter
    Dw(j) = rNorm{j}(bottom)-rNorm{j}(top);

    % Check to see if the wake is annular or circular
    isRing = 1;
    if coreTop >= coreBottom
        isRing = 0;
    end

    % calculating Sw (wake span) and Vw (area-based avg of uNorm inside wake)
    if isRing
        Sw(j) = (rNorm{j}(coreTop)-rNorm{j}(top)+ rNorm{j}(bottom)-rNorm{j}(coreBottom))/2;
        uTop = uNorm{j}(top:coreTop);
        rTop = rNorm{j}(top:coreTop);
        uBottom = uNorm{j}(coreBottom:bottom);
        rBottom = rNorm{j}(coreBottom:bottom);
        I = pi*(trapz(rTop, uTop.*abs(rTop))+trapz(rBottom, uBottom.*rBottom)); % 2*pi*Integral is double-counting because we're using both positive and "negative" r, so we divide by 2
        Aring = 0.25*pi*(Dw(j)^2-(Dw(j)-2*Sw(j))^2);
        Vw(j) = I/Aring;
    else
        Sw(j) = Dw(j)/2;
        I = pi*(trapz(rNorm{j}(top:bottom),abs(rNorm{j}(top:bottom)).*uNorm{j}(top:bottom)));
        Aring = 0.25*pi*Dw(j)^2;
        Vw(j) = I/Aring;
    end
end

figMeanWake = figure;
plot(stations,Vw,'ko','MarkerFaceColor','k')
xlim([0 stations(end)])
ylim([0.5 1])
xlabel('x/D')
ylabel('V_w/V_{\infty}')

end