errorbar(pressure{1},cranks{1},0.025*ones(length(cranks{1})),'horizontal','.')
errU = 0.5*0.025./sqrt(pressure{1}*pInfty(1));
errorbar(uNorm{1},rNorm{1},errU,'horizontal','.')

% could replace 0.025 with std dev, or results from 5-min sample