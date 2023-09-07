% Use function by typing in the command window
% final input arguments would be 
% station positions to be ignored
% ex: convert("","",11,2,3,4)

function convert(readFile,writeFile,maxStation,varargin)
% Script to get number of cranks and delta h from excel

data     = readmatrix(readFile);

% Counter variables
readCol1 = 1;
readCol2 = 6;
writCol1 = 1;
writCol2 = 2;

excludeStations = cell2mat(varargin);

for i = 1:maxStation
    if ismember(i, excludeStations)
    else
        stations(:,writCol1) = data(24:172,readCol1);
        stations(:,writCol2) = data(24:172,readCol2);
        writCol1 = writCol1 + 2;
        writCol2 = writCol2 + 2;
    end

    readCol1 = readCol1 + 9;
    readCol2 = readCol2 + 9;
end

writematrix(stations,writeFile)

end