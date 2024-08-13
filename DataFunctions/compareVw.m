function figVw = compareVw(stations,D,S,Vw,Dw,Sw,xD,VwFull,DwFull,SwFull,EE,xe,sizeFont,sizeTitle)

figVw = figure;
subplot(2,1,1)
plot(stations,Vw,'ko','MarkerFaceColor','k')
hold on
plot(xD,VwFull,'b-','linewidth',1)
xlim([0 stations(end)])
ylim([0.5 1])
xlabel('x/D')
ylabel('V_w/V_{\infty}')
legend('Wind tunnel data',strcat('Full Model (E=',num2str(EE),', x_e=',num2str(xe),')'),'location','southeast','fontsize',14)
fontsize(sizeFont,'points')
title(strcat('Mean Wake Velocity'));% for S/D='),num2str(S/D)))
figVw.Position = [75 75 520*[2.63 1.5]*0.85]; % powerpoint slide main textbox size is 11.5" by 5.2". For some reason, between MATLAB saving the file and importing it to PPT, some width is lost


% % testing out a range of entrainment coefficients
% for i=1:4
%     EE = 0.16+0.02*i;
%     [xD,VwFull,DwFull,SwFull] = cfcModel(D,S,CT,EE,xe,xmax); 
%     plot(xD,VwFull)
% end

subplot(2,1,2)
plot(stations,Dw/2,'k*',stations,Dw/2-Sw,'k*')
hold on 
plot(xD, DwFull/2, 'b-','linewidth',1)
plot(xD, DwFull/2-SwFull, 'b-','HandleVisibility','off','linewidth',1); 
xlim([0 stations(end)])
xlabel('x/D')
ylabel('r/D')
fontsize(sizeFont,'points')
title('Wake Boundary');% for S/D='),num2str(S/D)))
sgtitle(strcat('Tophat Wake Velocity and Boundaries for S/D=', num2str(S/D)),'fontsize',sizeTitle)

end