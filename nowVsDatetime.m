% comparison between the speed of now and datetime

nows = zeros(100,1);
datetimes = nows;

for i=1:100
    t1 = now;
    t2 = now - t1;
    nows(i) = t2*86400000;
end

for i=1:100
    d1 = datetime;
    d2 = datetime - d1;
    datetimes(i) = milliseconds(d2);
end

disp(['average time it takes to call now: ', num2str(mean(nows)), ' milliseconds'])
disp(['average time it takes to call datetime: ', num2str(mean(datetimes)), ' milliseconds'])
