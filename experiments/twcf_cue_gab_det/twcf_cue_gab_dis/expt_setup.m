function [setup, incompleteData, exitNow] = expt_setup()
% twcf_cue_gab_det
% [setup, incompleteData, exitNow] = expt_setup()

%% expt name, date, time

exptName = 'twcf_cue_gab_dis';
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

%% starting new session or continuing an ongoing one?

loadSavedSettings = NaN;
while ~(loadSavedSettings==1 || loadSavedSettings==2)
    disp(' ')
    disp('Do you want to load the previously recorded setup info?')
    disp('1 = no, enter all setup info manually')
    disp('   (e.g. if this is the first thing the participant is doing today, or if their previously entered settings need to be changed)')
    disp('2 = yes, load the saved setup info')
    disp('   (e.g. if setup info for the participant has already been entered earlier in this session)')
    disp(' ')
    loadSavedSettings = input('');
end

loadSavedSettings = loadSavedSettings - 1;
enterNewSettings  = ~loadSavedSettings;

if loadSavedSettings
    load('expt_setup_most_recent_info.mat')
end


%% site

if enterNewSettings

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

end


%% load previous data set or start new data set

resumeDataset = NaN;
while ~(resumeDataset==0 || resumeDataset==1)
    disp(' ')
    disp('Start new experiment stage, or resume running an interrupted experiment stage?')
    disp('0 = Start new experiment stage')
    disp('1 = Resume interrupted experiment stage')
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

if enterNewSettings
    disp(' ')
    subjectID = input('Enter subject ID:  ','s');
end


%% stage?

stage = NaN;
while isnan(stage)
    disp(' ')
    disp('What stage?')
    disp('-1 = take screen shot')
    disp('0  = practice')
    disp('1  = training')
    disp('2  = thresholding')
    disp('3  = validation')
    disp('4  = full experiment')
    disp('5  = piloting')
    disp(' ')
    stage = input('');
end

takeScreenshot = 0;
isPractice     = 0;
isTraining     = 0;
isThresholding = 0;
isValidation   = 0;
isMainExpt     = 0;
isPiloting     = 0; 
prestimNoise   = NaN; % by default yes prestimNoise 

switch stage
    case -1, takeScreenshot = 1;
    case 0,  isPractice = 1;
    case 1,  isTraining = 1; % reference training 
    case 2,  isThresholding = 1; % tilt training 
    case 3,  isValidation = 1;
    case 4,  isMainExpt = 1;
    case 5,  isPiloting = 1; 
    otherwise 
        error('Expt stage not recognized. Please try again.')
end

%% one or two button reports per trial

buttons = NaN;
switch stage
    % no visibility judgement for reference and tilt training 
    % yes visibility judgement in practice, validation, and main 
    case {-1, 0, 3, 4, 5}
        buttons = 2; 
    otherwise 
        buttons = 1; 
        % while isnan(buttons)
        %     disp(' ')
        %     disp('How many button reports?')
        %     disp('1  = orientation and reference comparison')
        %     disp('2  = orientation and reference comparison + orientation visibility')
        %     disp(' ')
        %     buttons = input('');
        % end
end

%% turn off prestim noise pedestal?

switch stage
    % case 5 % only option for noise in piloting
    %     prestimNoises = 0:1;
    %     while ~(any(prestimNoise == prestimNoises))
    %         disp(' ')
    %         disp('Use prestim noise?')
    %         disp('0 = no')
    %         disp('1 = yes')
    %         disp(' ')
    %         prestimNoise = input('');
    %     end
    otherwise
        prestimNoise = 0; % defaults to noise off 
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


%% instruction stage?

instructionStage  = 0;

if practiceStage == 1
    instructionStages = 1:2;
    while ~(any(instructionStage == instructionStages))
        disp(' ')
        disp('What instruction stage?')
        disp('1 = day 1 (full instructions)')
        disp('2 = day 2 and beyond (refresher)')
        disp(' ')
        instructionStage = input('');
    end
end


%% eye tracking?

if enterNewSettings
    
    doEyetracking = NaN;
    while ~(doEyetracking==0 || doEyetracking==1 || doEyetracking==2)
        disp(' ')
        disp('Are we using eyetracking today?')
        disp('0 = no')
        disp('1 = yes (normal mode)')
        disp('2 = yes (debugging mode - gaze location drawn on screen during fixation acquisition)')
        disp(' ')
        doEyetracking = input('');
    end

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

if enterNewSettings
    
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

if enterNewSettings
    
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

end


%% define data folder and filename

dataDirBase = ['../../../twcf_expt1_data_' site '/' exptName '/'];
if isPractice
    dataDir = [dataDirBase subjectID '/practice/'];
elseif isTraining
    dataDir = [dataDirBase subjectID '/training/']; 
elseif isThresholding
    dataDir = [dataDirBase subjectID '/thresholding/']; 
elseif isValidation
    dataDir = [dataDirBase subjectID '/validation/']; 
elseif isPiloting
    dataDir = [dataDirBase subjectID '/piloting/']; 
else
    dataDir = [dataDirBase subjectID '/main_expt/'];
end

if ~exist(dataDir, 'dir')
    mkdir(dataDir);
end

if takeScreenshot
    dataFilename = [];
else
    stageText       = {'practice', 'training', 'thresholding', 'validation', 'main_expt', 'piloting'};
    dataFilename    = [exptName '_' site '_' subjectID '_' stageText{stage+1} '_' exptDate '_' exptTime];
end

threshDir = [dataDirBase subjectID '/thresholding/'];


%% if validation or main expt stage has been selected, check that thresholding has been done

if isValidation || isMainExpt
    try
        % read in the filenames for completed thresholding data sets
        fileID = fopen([threshDir 'completed_thresholding_data.txt'], 'r');
        filenames = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);

        % load the most recent thresholding data set
        % (i.e. the last dataset listed in completed_thresholding#_data.txt)
        load([threshDir filenames{1}{end}]);
        
    catch
        errorText = ['Validation and main expt cannot be run for participant "' subjectID '" because ' ...
                     'thresholding data could not be loaded. Please double-check that this ' ...
                     'participant has completed thresholding.'];
        error('expt:setup', errorText);
    end
end


%% save setup info

if enterNewSettings
    save('expt_setup_most_recent_info.mat', ...
         'siteID', 'site', 'subjectID', 'doEyetracking', 'distFromScreen_inCm', ...
         'PTBmode', 'skipSyncTests', 'skipFlipIntervalEstimation');
end


%% ensure eye tracking is turned off during instructions and slowed down practice

if practiceStage == 1 || practiceStage == 2
    doEyetracking = 0;
end


%% package output

setup = v2struct(exptName, exptDate, exptTime, site, resumeDataset, subjectID, dataDir, threshDir, dataFilename, ...
                 distFromScreen_inCm, exptAtScanner, doEyetracking, isPractice, practiceStage, instructionStage, takeScreenshot, ...
                 isTraining, isThresholding, isValidation, isMainExpt, isPiloting, skipSyncTests, skipFlipIntervalEstimation, ...
                 prestimNoise, buttons);

setup.exitNow = 0;
