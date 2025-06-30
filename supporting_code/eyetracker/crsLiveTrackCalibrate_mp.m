function  [exitNow] = crsLiveTrackCalibrate_mp(viewDist, WindowID, winStim,p)
% MAKP EDIT 3/5/22
% viewDist should be an input from p.viewingDistance in our expt code
% WindowID is the number of the screen (e.g. 2)
% winStim should be p.win

% 3/5/22    MAKP Forked a demo for use with the TWCF EXPT 1 project

% 4/21/22 MAKP added functionality to exit after 3 failed attempts

%% Default values for input parameters (if omitted)

if nargin<2
    DEBUGMODE=1;

    % Define default values for the monitors to use, for debugging purposes
    if nargin<2
        % Get the IDs of all monitors present
        screensAvailable = Screen('Screens');

       % ID of experimenter's monitor and stimulus monitor
        WindowID = max(screensAvailable);
%         if length(screensAvailable)>1
%             WindowID(2) = max(screensAvailable)-1;       
%         end
    end

    p.stim.BGcolor = 0.5;
    p.kb.kbNum = [];
    p.kb.exitKey = 'ESCAPE';

    atFIBRE = input('Are we at FIBRE? y/n ','s');
    if strcmp(atFIBRE,'y')
        p.fixationDots = [];
    end

    % Define default value for the viewing distance in mm, for debugging
    % purposes
    if nargin<1
        viewDist = 750;
        if isfield(p,'fixationDots') % MAKP 3-12-24 hack to mak this also work at FIBRE for debugging
            viewDist = 1280;
        end
    end
    

    
else % for use with our real suite of code
    DEBUGMODE=0;
end

%% Parameters to control behavior of calibration

% Define the defualt location of the the fixation targets in degrees
% (origin at the centre, x-positive=right, y-positive=down)
% MAKP 3-12-24 fixed this so it doesn't break the in-the-lab stuff due to
% FIBRE edits
if isfield(p,'fixationDots')
    targetsDeg = [-5 -5;0 -5;5 -5;-5 0;0 0;5 0;-5 5;0 5;5 5]; %Adjusted to fit FIBRE screen
else
    targetsDeg = [-10 -10;0 -10;10 -10;-10 0;0 0;10 0;-10 10;0 10;10 10];
end
targetN = size(targetsDeg,1); % how many targets are we calibrating

acceptableError = 0.3; % The amount of error we will accept for eyetracker calibration

validThresh = 0.8; % The percent of calibration targets we need to achieve in order to count as good calibration

exitNow = 0;
nrounds = 3;

%% Routines for the calibration

if DEBUGMODE
    % Initialise LiveTrack
    crsLiveTrackInit; 
    
    % Open a full screen window with grey background on stimulus monitor
    % If this is the real deal, we would pass this as an input to the main
    % function
    PsychDefaultSetup(2);
    winStim = PsychImaging('OpenWindow', WindowID, 0.5);

end
calRound = 1;
while true
    % Show fixation dots on the stimulus screen and collect eye tracking data for the calibration 
    [pupilL, glintL, pupilR, glintR, targets, ~, nValid] = crsLiveTrackGetFixationDataRaw_mp(viewDist, targetsDeg, WindowID, winStim);

    if DEBUGMODE
        

    end

    % Calculate the calibration matrix parameters for left and right eye
    [trackLeftEye, trackRightEye] = crsLiveTrackGetTracking;

    % Check whether we hit the minimum for # of targets to calibrate to
    % NOTE: crsLiveTrackCalibrateDevice requires >=5 valid targets
    % We are therefore being more stringent than CRS, for now.   
    % Do the calibration
    if trackLeftEye & (nValid.L/targetN >= validThresh)
        errDegLeft = crsLiveTrackCalibrateDevice('left', pupilL, glintL, targets, viewDist);
    else
        errDegLeft = NaN;
    end
    if trackRightEye & (nValid.R/targetN >= validThresh)
        errDegRight = crsLiveTrackCalibrateDevice('right', pupilR, glintR, targets, viewDist);
    else
        errDegRight = NaN;
    end

    % Show the errors to the experimenter in the command window
    disp(['Left error:  ' num2str(errDegLeft) ' deg']);
    disp(['Right error:  ' num2str(errDegRight) ' deg']);
    
    % Check the calibration
    goodCal = [0 0];
    if trackLeftEye & (errDegLeft < acceptableError) 
        goodCal(1) = 1;
    end
    if ~isfield(p,'fixationDots') % 3-12-24 MAKP hack to make this extensible across lab and FIBRE
    %FIBRE eyetracker on tracks left eye so if we're not in the scanner,
    %also track the right eye
        if trackRightEye & (errDegRight < acceptableError)
            goodCal(2) = 1;
        end
    end


    % If it's within acceptable parameters, accept, otherwise repeat. 
     if sum(goodCal) > 0 % If we have successfully calibrated at least one eye... 
        disp('Calibration accepted...');
        crsLiveTrackSetResultsTypeCalibrated; % Tell the eyetracker it is now calibrated
        fixtext = ['Calibration accepted!'];
        Screen('FillRect', winStim, p.stim.BGcolor);
        DrawFormattedText(winStim, fixtext, 'center', 'center', 0);
        Screen('Flip', winStim);
        WaitSecs(1);
        Screen('Flip',winStim);
        break
    else % If neither eye got a good calibration
        if calRound < nrounds
            disp('Repeating calibration...');
            fixtext = ['Let''s try that again.\n\n' ...
                   'Try adjusting your head a little bit to help the eyetracker see your eyes better.\n\n' ...
                   'Press any key to try again.'];
            Screen('FillRect', winStim, p.stim.BGcolor);
            DrawFormattedText(winStim, fixtext, 'center', 'center', 0);
            Screen('Flip', winStim);

            % wait for keypress
            KbWait(p.kb.kbNum);
            [k, secs, key] = KbCheck(p.kb.kbNum);
            if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end  
            
            calRound = calRound + 1;
        else
            disp('Calibration is failing! Go adjust the camera!');
            fixtext = ['Looks like we need to try something different.\n\n' ...
                   'The experimenter will come adjust the camera.'];
            Screen('FillRect', winStim, p.stim.BGcolor);
            DrawFormattedText(winStim, fixtext, 'center', 'center', 0);
            Screen('Flip', winStim);

            % wait for keypress of any kind, and exit upon keypress
            KbWait(p.kb.kbNum);
            exitNow = 1;
            return
        end
    end

end

if DEBUGMODE
    
    % Close all PTB windows that we opened for testing purposes
    sca;

    % Stop buffering data to the library
    crsLiveTrackStopTracking;

    % Clear the data in the buffer
    crsLiveTrackClearDataBuffer;
end



