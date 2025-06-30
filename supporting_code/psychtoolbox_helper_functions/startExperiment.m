function startData = startExperiment(experimentName)


disp('working from directory')
disp([pwd ' ...'])
disp(' ')

if IsWin
    dataDir = [pwd '\data\'];
else
    dataDir = [pwd '/data/'];
end

% get distance from screen
subjectID = input('Enter subject ID:  ');
distFromScreen_inCm = input('Enter distance from screen in cm:   ');
expDate = datestr(clock,'yyyymmdd');

% general comments
comments = ''; %input('Comments?   ','s');

startData.dataDir             = dataDir;
startData.dataFile            = dataFile;
startData.distFromScreen_inCm = distFromScreen_inCm;
startData.startupTime         = startupTime;
startData.comments            = comments;