function [setup, incompleteData, exitNow] = expt_setup()
% [setup, incompleteData, exitNow] = expt_setup()

%% expt name, date, time

exptName = 'twcf_cue_tex_det';
exptDate = datestr(clock,'yyyymmdd');
exptTime = datestr(clock,'HHMMSS');

%% set paths and directories

% add paths
addpath(genpath('../../supporting_code'));

% ensure current directory is correct
currentFile       = mfilename('fullpath');
currentFileFolder = fileparts(currentFile);
cd(currentFileFolder);

disp('working from directory')
disp([pwd ' ...'])
disp(' ')

%% check framerate

exitNow = 0;

w = max(Screen('Screens'));
refreshRate_inHz = Screen('FrameRate', w);

if mod(refreshRate_inHz, 60) ~= 0
    useCurrentRefreshRate = NaN;
    while ~(useCurrentRefreshRate==0 || useCurrentRefreshRate==1)
        disp(['WARNING! Current screen refresh rate is ' num2str(refreshRate_inHz) ' Hz'])
        disp('Recommended refresh rate is 60 Hz or 120 Hz')
        disp(' ')
        disp('What do you want to do about the screen refresh rate?')
        disp('0 = exit and reset the refresh rate manually')
        disp('1 = continue using the current refresh rate')
        disp(' ')
        useCurrentRefreshRate = input('');
    end
    
    if ~useCurrentRefreshRate
        setup = [];
        incompleteData = [];
        exitNow = 1;
        return;
    end    
end    

%% site

siteID = NaN;
while ~(siteID==1 || siteID==2 || siteID==3)
    disp(' ')
    disp('Which site?')
    disp('1 = UCI')
    disp('2 = BU')
    disp('3 = offsite')
    disp(' ')
    siteID = input('');
end

sites = {'UCI', 'BU', 'offsite'};
site  = sites{siteID};

%% load previous data set or start new data set

resumeDataset = NaN;
while ~(resumeDataset==0 || resumeDataset==1)
    disp(' ')
    disp('Start new data set, or resume running an incomplete data set?')
    disp('0 = Start new data set')
    disp('1 = Resume incomplete data set')
    disp(' ')
    resumeDataset = input('');
end

if resumeDataset
    
    % jump to site's data directory for ease of navigating to the saved data
    dataDirBase = ['../../../twcf_expt1_data_' site '/' exptName '/'];
    origDir     = cd(dataDirBase);
    
    % open user interface to load incomplete data set
    [filename, pathname] = uigetfile('*.mat', 'Select the data set to resume');
    
    % change back to the original directory
    cd(origDir);
    
    % this should load the following variables:
    % setup, b, p, data, timing, gaze, progress
    load([pathname filename]);
    
    % mark that this is now a resumed dataset
    setup.resumeDataset = resumeDataset;

    % package incomplete data
    incompleteData = v2struct(setup, b, p, data, timing, gaze, progress);
   
    return
else
    incompleteData = [];
end

%% get subject ID

disp(' ')
subjectID = input('Enter subject ID:  ','s');


%% stage?

stage = NaN;
while ~(stage==-1 || stage==0 || stage==1 || stage==2)
    disp(' ')
    disp('What stage?')
    disp('-1 = take screen shot')
    disp('0  = practice')
    disp('1  = thresholding')
    disp('2  = full experiment')
    disp(' ')
    stage = input('');
end

isPractice     = 0;
isThresholding = 0;
isMainExpt     = 0;
takeScreenshot = 0;

switch stage
    case -1, takeScreenshot = 1;
    case 0,  isPractice = 1;
    case 1,  isThresholding = 1; 
    case 2,  isMainExpt = 1;
end


%% practice stage?

practiceStage  = 0;

if isPractice
    practiceStages = 1:4;
    while ~(any(practiceStage == practiceStages))
        disp(' ')
        disp('What practice stage?')
        disp('1 = instructions')
        disp('2 = slowed down trials')
        disp('3 = normal trials with auditory feedback')
        disp('4 = normal trials without feedback')
        disp(' ')
        practiceStage = input('');
    end
end


%% eye tracking?

doEyetracking = NaN;
while ~(doEyetracking==0 || doEyetracking==1 || doEyetracking==2)
    disp(' ')
    disp('Turn on eyetracking?')
    disp('0 = no')
    disp('1 = yes (normal mode)')
    disp('2 = yes (debugging mode - gaze location drawn on screen during fixation acquisition)')
    disp(' ')
    doEyetracking = input('');
end


%% fMRI scanner?

exptAtScanner = 0; % NaN; % hard code this as 0 for now
while ~(exptAtScanner==0 || exptAtScanner==1)
    disp(' ')
    disp('Expt in fMRI scanner?')
    disp('0 = no')
    disp('1 = yes')
    disp(' ')
    exptAtScanner = input('');
end


%% set distance from screen in cm

if exptAtScanner
%     distFromScreen_inCm = 12;
%     disp(' ')
%     disp('*** NOTE ***')
%     disp('in the UCI CAN scanner, distance from mirror is 12 cm.')
%     disp('so, dist from screen in cm has been set to 12.')
%     disp('************')
    
else
    distFromScreen_inCm = NaN;
    while ~(distFromScreen_inCm > 0 || distFromScreen_inCm <= 120)
        disp(' ')
        distFromScreen_inCm = input('Enter distance from screen in cm (recommended value = 75):   ');
        disp(' ')
    end

end


%% EEG trigger?

% if exptAtUCI
%     useEEGtrigger = NaN;
%     while ~(useEEGtrigger==0 || useEEGtrigger==1)
%         disp(' ')
%         disp('Use EEG trigger?')
%         disp('0 = no')
%         disp('1 = yes')
%         disp(' ')
%         useEEGtrigger = input('');
%     end
% else
%     useEEGtrigger = 0;
% end


%% psychtoolbox mode

PTBmode = NaN;
while ~(PTBmode==0 || PTBmode==1)
    disp(' ')
    disp('What psychtoolbox mode?')
    disp('0 = quick and dirty (skip timing tests)')
    disp('1 = proper data collection (conducts timing tests before starting)')
    disp(' ')
    PTBmode = input('');
end

if PTBmode == 0
    % set skipSyncTests = 1 if you can't avoid sync test failures
    skipSyncTests = 1;

    % set to 1 to use a faster but potentially less accurate estimate of screen refresh rate
    skipFlipIntervalEstimation = 1;

else
    skipSyncTests = 0;
    skipFlipIntervalEstimation = 0;
end


%% define data folder and filename

% if isPractice
%     dataDir = [pwd '/data/' subjectID '/practice/'];
% elseif isThresholding
%     dataDir = [pwd '/data/' subjectID '/thresholding/'];    
% else
%     dataDir = [pwd '/data/' subjectID '/main_expt/'];
% end

dataDirBase = ['../../../twcf_expt1_data_' site '/' exptName '/'];
if isPractice
    dataDir = [dataDirBase subjectID '/practice/'];
elseif isThresholding
    dataDir = [dataDirBase subjectID '/thresholding/'];    
else
    dataDir = [dataDirBase subjectID '/main_expt/'];
end

mkdir(dataDir);

if takeScreenshot
    dataFilename = [];
else
    stageText = {'practice', 'thresholding', 'main_expt'};
    dataFilename = [exptName '_' site '_' subjectID '_' stageText{stage+1} '_' exptDate '_' exptTime];
end

threshDir = [dataDirBase subjectID '/thresholding/'];


%% if main expt stage has been selected, check that thresholding has been done

if isMainExpt
    try
        % read in the filenames for completed thresholding data sets
        fileID = fopen([threshDir 'completed_thresholding_data.txt'], 'r');
        filenames = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);

        % load the most recent thresholding data set
        % (i.e. the last dataset listed in completed_thresholding_data.txt)
        load([threshDir filenames{1}{end}]);
        
    catch
        errorText = ['Main expt cannot be run for participant "' subjectID '" because ' ...
                     'thresholding data could not be loaded. Please double-check that this ' ...
                     'participant has completed thresholding.'];
        error('expt:setup', errorText);
    end
end

%% package output

setup = v2struct(exptName, exptDate, exptTime, site, resumeDataset, subjectID, dataDir, threshDir, dataFilename, ...
                 distFromScreen_inCm, exptAtScanner, doEyetracking, isPractice, practiceStage, takeScreenshot, ...
                 isThresholding, isMainExpt, skipSyncTests, skipFlipIntervalEstimation);

setup.exitNow = 0;