a = sheetnames("Wind tunnel data v2 2022.xlsx");

for i = 1:numel(a)
    sheetName = a{i};
    data = readtable("Wind tunnel data v2 2022.xlsx",'Sheet', sheetName);
    fileName = strcat(sheetName,'.csv');
    writetable(data,fileName)
end
