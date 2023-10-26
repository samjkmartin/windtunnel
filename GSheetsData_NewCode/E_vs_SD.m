SD = [0.1 0.3 0.4 0.5]; 
EE = [0.25 0.14 0.12 0.1]; 

plot(SD,EE,'ko')
axis([0 0.55 0 0.3])
xlabel('S/D')
ylabel('E')
title('Variation of E with S/D for porous annuli with ~50% solidity')
fontsize(14,'points')
set(gcf,'color','white')