function [pupilL, glintL, pupilR, glintR, targets, order, nValid] = crsLiveTrackGetFixationDataRaw_mp(viewDist, targetsDeg, WindowID, winStim)
%CRSLIVETRACKGETFIXATIONDATARAW  This script collects data to calibrate the
%LiveTrack Lightning from within an existing PTB code suite
%
%   This script uses Psychtoolbox functions to drive the display while 
%   acquiring data from CRS LiveTrack devices. The script places dots on
%   the screen at various positions while the participant must fixate the
%   each dot until the a valid data has been aquired. If no valid data as
%   been aquired after a time out period, the fixation point will be
%   skipped and the script moves to the next fixation.
%
%   The function will output the average location of the pupil and glint
%   for each fixation in coordinated of the camera image sensor of the eye
%   tracker. The corresponding location of the fixaxtion dots is returned
%   in pixel coordinates of the screen. An array with the order in which
%   the fixations were taken is also returned.
%
%   The parameters for the locations of the fixaxtion dots and the fixation
%   criteria can be adjusted in the "User input" section at the beginning
%   of the function.
%
%   The input to this function must be:
%   viewDist - perpendicular distance between the participants eyes and the
%   screen in millimetres.
%   WindowID - a two-entry vector containing the ID of the control monitor 
%   and the stimulus monitor as specified by the function Screen('Screens'). 


% History:
% 09/2016 JT Created
% 05/2017 MAH adapted to use CRS Toolbox for data 
% 06/2017 JT changed to use buffered data from the CRS Toolbox
% 03/05/22 MAKP edited heavily for use with the TWCF EXPT 1 project

%% User input

% Time before getting data from fixation (to ignore initial saccade)
setupDelay = 500; % duration in mS

% Define the minimum amount of time required for each fixation (in mS) - 
% decrease to make calibration "easier"/faster
minDur = 1200; % fixation duration in mS

% Time limit for aquiring fixation - if a fixation has not been aquired 
% within this time, the fixation point will be skipped.
fixTimeout = 5; % timeout duration in seconds

% Fixation threshold in camera pixels (all samples taken wihtin the "minDur"
% time must be within this threshold) - increase this to make the  
% calibration "easier" (e.g. for subjects with difficulties making precise
% eye fixations)
fixThreshold = 3.1;

% Define the diameter of the fixation points (in degrees of visual angle)
fixDotInDeg = 0.1; % inner circle
fixDotOutDeg = 0.6; % outer circle

% Randomize the order of the targets:
order = randperm(size(targetsDeg,1));
targetsDeg = targetsDeg(order,:);

% Set up to count how many valid fixations we get
nValid.L = 0;
nValid.R = 0;

%% Setup/launch LiveTrack

% Start LiveTrack raw data streaming
crsLiveTrackSetResultsTypeRaw;

% Start buffering data to the library
crsLiveTrackStartTracking;

% Get an estimate of the sample rate
[ width, height, sampleRate, offsetX, offsetY, ErrorCode ] = crsLiveTrackGetCaptureConfig; %#ok<ASGLU>

% Calculate how many data samples the fixation duration (fixDur) contains
fixDurSamples = round((minDur/1000)*sampleRate);

% Find out which eye to get fixation data from
[trackLeftEye, trackRightEye] = crsLiveTrackGetTracking;

%% Calculate stimulus screen 
% MAKP: note that this is redundant with some of the other things we do for
% this suite of code. However, I would prefer to leave it as-is for the
% sake of it being self-contained for other uses.

% Get the resolution of the stimulus monitor
ResStim = Screen('Resolution', WindowID);

% Get screen width and height (in mm)
screenW = Screen('DisplaySize', WindowID);

% Calculate pixel size (in mm) assuming square pixels
pixSize = screenW/ResStim.width;

% Caliculate millimetres per degree (NB. Only accurate for small eye
% angles)
MMperDeg = tand(1)*viewDist;

% Calculate pixels per degree
pixPerDeg = MMperDeg/pixSize;

% Calculate the radius of the fixation points (in pixels)
fixRadIn = fixDotInDeg*pixPerDeg/2;
fixRadOut = fixDotOutDeg*pixPerDeg/2;

% Target locations in screen pixel coordinates
cnrTarget = [round(ResStim.width/2) round(ResStim.height/2)];
tgtLocs(:,1) = round(targetsDeg(:,1)*pixPerDeg+cnrTarget(1)); 
tgtLocs(:,2) = round(targetsDeg(:,2)*pixPerDeg+cnrTarget(2));

%% Start collecting data

% Initialise the output data
pupilL = nan(size(targetsDeg,1),2);
pupilR = nan(size(targetsDeg,1),2);
glintL = nan(size(targetsDeg,1),2);
glintR = nan(size(targetsDeg,1),2);
targets = nan(size(targetsDeg,1),2);
EscPressed = false;

% Run a loop over each fixation point and get the fixation data
for i=1:size(targetsDeg,1)
    
    % Draw new fixation point with the outer circle at 75% grey and the
    % inner circle black
    Screen('FillOval', winStim, 255, round([tgtLocs(i,1)-fixRadOut...
        tgtLocs(i,2)-fixRadOut tgtLocs(i,1)+fixRadOut tgtLocs(i,2)+fixRadOut]));
    Screen('FillOval', winStim, 0, round([tgtLocs(i,1)-fixRadIn...
        tgtLocs(i,2)-fixRadIn tgtLocs(i,1)+fixRadIn tgtLocs(i,2)+fixRadIn]));
    Screen('Flip', winStim);
    
    % This flag will be set to true when a valid fixation has been acquired
    gotFixLeft = false;  
    gotFixRight = false;
       
    tic; % reset fixation timer 
    % Loop until fixation data has been aquired for this dot (or timed out) 
    while 1

        % Make sure there is at least one sample in the buffer before
        % continuing
        while crsLiveTrackGetResultsCount<1
            if toc>1
                error('ERROR: Could not get any data from LiveTrack!');
            end
        end
        
        % Get the most recent data samples since the buffer was cleared,
        % up to the number specified in fixDurSamples
        Data = crsLiveTrackGetLatestEyePosition(fixDurSamples);

        % Calculate the pupil-to-glint vector for x and y direction and
        % left and right eye
        PGvectorLeftX = Data.pupilPositions(:,1)-Data.glintPositions(:,1);
        PGvectorLeftY = Data.pupilPositions(:,2)-Data.glintPositions(:,2);
        PGvectorRightX = Data.pupilPositions(:,1)-Data.glintPositions(:,1);
        PGvectorRightY = Data.pupilPositionsRight(:,2)-Data.glintPositionsRight(:,2);

        % Calculate the maximum difference in the pupil-to-glint 
        % vectors for the samples in the buffer, for left eye
        pgDistLeft = max([max(PGvectorLeftX)-min(PGvectorLeftX) ...
            max(PGvectorLeftY)-min(PGvectorLeftY)]);
        % and for the right eye
        pgDistRight = max([max(PGvectorRightX)-min(PGvectorRightX) ...
            max(PGvectorRightY)-min(PGvectorRightY)]);

        % Check if the maximum vector difference is within the defined
        % limit for a fixation (fixWindow) and all samples are tracked, and
        % the time to wait for fixations (waitTimeForFix) has passed, for
        % the left eye
        if pgDistLeft<=fixThreshold && all(Data.tracked) && toc>setupDelay/1000
            % Check if there are enough samples in the buffer for the
            % defined duration (fixDurSamples)
            if size(PGvectorLeftX,1)>=fixDurSamples && ~gotFixLeft
                % save the data for this fixation
                pupilL(i,:) = median(Data.pupilPositions);
                glintL(i,:) = median(Data.glintPositions);
                disp(['Fixation #',num2str(i),': Found valid fixation for left eye']);
                gotFixLeft = true; % good fixation aquired
            end
        end
        % and for the right eye
        if pgDistRight<=fixThreshold && all(Data.trackedRight) && toc>setupDelay/1000
            % Check if there are enough samples in the buffer for the
            % defined duration (fixDurSamples)
            if size(PGvectorRightX,1)>=fixDurSamples && ~gotFixRight
                % save the data for this fixation
                pupilR(i,:) = median(Data.pupilPositionsRight);
                glintR(i,:) = median(Data.glintPositionsRight);
                disp(['Fixation #',num2str(i),': Found valid fixation for right eye']);
                gotFixRight = true; % good fixation aquired
            end
        end

        
        if toc>fixTimeout
            if ~gotFixLeft && trackLeftEye
                disp(['Fixation #',num2str(i),': Did not get fixation for left eye (timeout)']);
            end
            if ~gotFixRight && trackRightEye
                disp(['Fixation #',num2str(i),': Did not get fixation for right eye (timeout)']);
            end
            break; % fixation timed out
        end
        
        % Exit if all eyes that are enabled have got a fixation
        if (gotFixLeft || ~trackLeftEye) && (gotFixRight || ~trackRightEye)
            if trackLeftEye; nValid.L = nValid.L + 1; end
            if trackRightEye; nValid.R = nValid.R + 1; end
            Screen('Flip', winStim);
            break;
        end
    end
                 
    % Return the target positions in millimetres
    targets(i,:) = targetsDeg(i,:)*MMperDeg;
    

end

% % Close all PTB windows
% sca;
% 
% % Stop buffering data to the library
% crsLiveTrackStopTracking;
% 
% % Clear the data in the buffer
% crsLiveTrackClearDataBuffer;

% put data back in order before returning it
pupilL(order,:) = pupilL;
glintL(order,:) = glintL;
pupilR(order,:) = pupilR;
glintR(order,:) = glintR;
targets(order,:) = targets;


end