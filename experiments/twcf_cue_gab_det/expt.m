clear

rng('shuffle')

%% collect setup info

[setup, incompleteData, exitNow] = expt_setup();
if exitNow, return; end

if setup.resumeDataset
    % unpack incomplete data struct
    v2struct(incompleteData);
end

%% initialize PTB window

% if requested, skip sync test
Screen('Preference', 'SkipSyncTests', setup.skipSyncTests);

%%%TEMPORARY FIX FOR M1 MACS
%%we can change this to a parameters setting if we want
%     disp("WARNING - Testing mode for macbooks is active! Turn this off if you want timing to be correct!");
%     %Skip sync tests for m1
%     Screen('Preference', 'SkipSyncTests', 1);
%     %m1 graphics fix
%     Screen('Preference','ConserveVRAM', 16384);
%     %skip annoying warning signs
%     Screen('Preference','VisualDebugLevel', 0);
%%%%%%%%%%%%

winFraction = 0.5; % 1 = full screen, < 1 = smaller screen
screenNum   = max(Screen('Screens'));
w           = openScreen(screenNum, winFraction);
Screen(w, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% gamma table setup
gammaTableOrig = [];
switch setup.site
    case 'UCI'
        load('../../supporting_code/gamma_calibration/gammaTableUCI.mat')
        gammaTableOrig = Screen('LoadNormalizedGammaTable', w, gammaTableUCI);
    case 'BU'
        load('../../supporting_code/gamma_calibration/gammaTableBU.mat')
        gammaTableOrig = Screen('LoadNormalizedGammaTable', w, gammaTableBU);
end


%% get parameters for experiment

p = expt_param(w, setup);

Screen('FillRect', w, p.stim.BGcolor*[1,1,1]);


%% exit if stimulus calibration is not complete

% if ~p.calibration.detectionCalibrated
%     Screen('CloseAll');
%     
%     calibStr = [];
%     for i_type = 1:length(p.calibration.typeCalibrated)
%         if ~p.calibration.typeCalibrated(i_type)
%             calibStr = [calibStr, p.calibration.typeNames{i_type} '\n'];
%         end
%     end
%     errorText = ['calibration has not been completed yet on this computer for the current screen distance of ' num2str(p.screen.distFromScreen_inCm) ' cm '...
%                  'and resolution of ' num2str(p.screen.screenWidth_inPixels) ' x ' num2str(p.screen.screenHeight_inPixels) ' pixels.\n\n' ...
%                  'The following calibration types for this distance and resolution have not been performed:\n\n' calibStr '\n' ...
%                  'Please calibrate by running expt_calibrateStim, or doublecheck that distance from screen in cm and screen resolution are correct.'];
%     error('expt:calibration', errorText);
% end
% 

%% initialize eyetracker


if setup.doEyetracking && setup.practiceStage ~= 1
    [p, exitNow] = eyetracker_initialize(w, p);
end


%% run the experiment

if ~exitNow
    if setup.practiceStage == 1
        expt_instructions(w, p);
    else
        if ~setup.resumeDataset
            b = expt_makeBlock(setup);
        end
        [data, timing, exitNow] = expt_runBlock(w, p, b, setup, incompleteData);
    end
end

%% if thresholding, plot the results

if setup.isThresholding && ~exitNow
    expt_plotQuestResults(setup.threshDir);
end


%% finish up

% We do not do eyetracking for instructions, so we only need to turn off
% the eyetracker if we have already started using it (for any of the other
% phases); if we try to turn it off but it has not been turned on, this
% function will cause an error
if setup.doEyetracking && setup.practiceStage ~= 1
    eyetracker_stopRecording(w, p);
end

if ~isempty(gammaTableOrig)
    Screen('LoadNormalizedGammaTable', w, gammaTableOrig);
end

Screen('CloseAll');

% Clean up audio at BU 
% if strcmp( setup.site , 'BU')
%     % PsychPortAudio('Stop');
%     PsychPortAudio('Close');
%     Snd('Close')
%     disp('Audio closed...')
% end

