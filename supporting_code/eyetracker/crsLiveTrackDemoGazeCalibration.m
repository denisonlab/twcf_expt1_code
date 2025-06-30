function  [errDegLeft, errDegRight] = crsLiveTrackDemoGazeCalibration(viewDist, targetsDeg, WindowID)
% CRSLIVETRACKDEMOGAZECALIBRATION   This demo shows how to calibrate the
% Cambridge Research Systems Livetrack eyetracker with MATLAB and
% Psychtoolbox 
% 
% The demo shows how to aquire raw tracking data (pupil and glint 
% positions) while using Psychtoolbox to show fixations targets (dots) on a 
% screen. This is done using the function:
% crsLiveTrackGetFixationDataRaw
% Open and edit this function to change parameters for fixation criteria.
% 
% The raw tracking data is then used, together with information about the
% locations of the targets, to calibrate the gaze measurement for
% LiveTrack. This is done using the API function:
% crsLiveTrackCalibrateDevice
% 
% Finally the demo shows how to retrieve the calibrated data and stream
% it into MATLAB while using Psychtoolbox to update the stimulus screen.
% This is done using the demo function:
% crsLiveTrackDemoShowGazePosition
% 
% USAGE:
% crsLiveTrackDemoGazeCalibration(viewDist) sets the viewing distance in
% millimeters (default is 500 mm)
%
% crsLiveTrackDemoGazeCalibration(viewDist, targetsDeg) also sets
% the location of the targets (must be a two-column vector with the first
% column defining the horizontal location of the targets in degrees and the
% seconds column the vertical location).
%
% crsLiveTrackDemoGazeCalibration(viewDist, targetsDeg, WindowID) also sets
% the screen IDs which allows setting which monitor is used for the
% stimulus and which is used for the tracking information. For futher
% information see: http://docs.psychtoolbox.org/Screens
%
% Note that the default setting needs a dual monitor setup with the
% secondary monitor used for the stimulus
% 
% History:
% 09/2014   JT Created  
% 10/2016   JT Updated to work with both eyes for binocular devices 
% 05/2017   JT Updated for LiveTrack Presto and fixed minor bugs
% 05/2017   MAH Updated to work with CRS LiveTrack Toolbox for MATLAB
% 11/2017   JT Added "repeat or accept" functionality
% 01/2018   JT Updated to use median glint for head movement correction

%% Default values for input parameters (if omitted)

% Define default values for the monitors to use 
if nargin<3
    % Get the IDs of all monitors present
    screensAvaiable = Screen('Screens');

   % ID of experimenter's monitor and stimulus monitor
    WindowID(1) = max(screensAvaiable);
    if length(screensAvaiable)>1
        WindowID(2) = max(screensAvaiable)-1;       
    end
end

% Define the defualt location of the the fixation targets in degrees
% (origin at the centre, x-positive=right, y-positive=down)
if nargin<2
    targetsDeg = [-10 -10;0 -10;10 -10;-10 0;0 0;10 0;-10 10;0 10;10 10];
end

% Define default value for the viewing distance in mm
if nargin<1
    viewDist = 750;
end

%% Routines for the calibration

% Initialise LiveTrack
crsLiveTrackInit;

while true
    % Show fixation dots on the stimulus screen and collect eye tracking data for the calibration 
    [pupilL, glintL, pupilR, glintR, targets] = crsLiveTrackGetFixationDataRaw(viewDist, targetsDeg, WindowID);

    % Calculate the calibration matrix parameters for left and right eye
    [trackLeftEye, trackRightEye] = crsLiveTrackGetTracking;

    if trackLeftEye
        errDegLeft = crsLiveTrackCalibrateDevice('left', pupilL, glintL, targets, viewDist);
    else
        errDegLeft = NaN;
    end
    if trackRightEye
        errDegRight = crsLiveTrackCalibrateDevice('right', pupilR, glintR, targets, viewDist);
    else
        errDegRight = NaN;
    end
    
    % Construct a questdlg with two options
    choice = questdlg({'Calibration error:',['Left eye:  ',num2str(errDegLeft),' degrees'],['Right eye: ',num2str(errDegRight),' degrees']}, ...
	'','Accept','Repeat','Accept');
    % Handle response
    switch choice
        case 'Accept'
            disp('Calibration accepted');
            break
        case 'Repeat'
            disp('Repeating calibration');
    end
end    


% Close LiveTrack
crsLiveTrackClose;
