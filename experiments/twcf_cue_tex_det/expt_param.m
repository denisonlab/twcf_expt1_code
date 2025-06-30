function p = expt_param(w, setup)

%% handle missing inputs

if ~exist('w','var') || isempty(w)
    w = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'skipFlipIntervalEstimation')
    setup.skipFlipIntervalEstimation = 1;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'practiceStage')
    setup.practiceStage = -1;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isMainExpt')
    setup.isMainExpt = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isPractice')
    setup.isPractice = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isThresholding')
    setup.isThresholding = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isCalibration')
    setup.isCalibration = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'takeScreenshot')
    setup.takeScreenshot = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'subjectID')
    setup.subjectID = 'no_subjectID_entered';
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'doEyetracking')
    setup.doEyetracking = 0;
end

p.setup = setup;

%% save current RNG seed

p.RNGseed = rng;

%% screen parameters

p.screen.distFromScreen_inCm = setup.distFromScreen_inCm;

p.screen.screenNum = max(Screen('Screens'));    
resolution         = Screen('Resolution', p.screen.screenNum);
p.screen.screenWidth_inPixels  = resolution.width;
p.screen.screenHeight_inPixels = resolution.height;

[screenWidth_inMm, screenHeight_inMm] = Screen('DisplaySize', p.screen.screenNum);
p.screen.screenWidth_inCm  = screenWidth_inMm / 10;
p.screen.screenHeight_inCm = screenHeight_inMm / 10;

% pixel per cm values can differ when computed from width or height, so
% here we compute the average pixels per cm value
p.screen.pixels_perCm_width  = p.screen.screenWidth_inPixels / p.screen.screenWidth_inCm;
p.screen.pixels_perCm_height = p.screen.screenHeight_inPixels / p.screen.screenHeight_inCm;

p.screen.pixels_perCm = (p.screen.pixels_perCm_width + p.screen.pixels_perCm_height) / 2;

% for UCI eyetracking, we'll also want to compute pixels per mm along the
% width (W) and height (H) dimensions
p.screen.pixels_perMm_WH = [p.screen.pixels_perCm_width, p.screen.pixels_perCm_height] / 10;


%% MAIN PARAMETERS TO PLAY WITH ARE HERE

% density of stimulus displays
p.stim.pFilled = 0.15; % indicates how many pixels of the BG are filled in by randomly drawn lines


% PERIPHERAL stimulus properties
% _inDeg suffix denotes variable is measured in units of visual degree
p.stim.periph.stimDistFromCenter_inDeg = 8;  % distance of the center of peripheral stim from central fixation point
p.stim.periph.ovalMajorAxis_inDeg      = 5;  % length of the foreground oval along its major axis
p.stim.periph.ovalMinorAxis_inDeg      = 3;  % length of the foreground oval along its minor axis

% when the foreground figure is a circle instead of an ellipse, it makes
% sense to set the area of the circle equal to the area of the ellipse.
% since area(circle) = pi*r^2 and area(ellipse) = pi*a*b where a and b are
% the distances from the center of the ellipse to the vertex and co-vertex,
% setting r^2 = a*b ensures the area of the circle with radius r equals the
% area of the ellipse
p.stim.periph.circleWidth_inDeg     = 2 * sqrt( p.stim.periph.ovalMajorAxis_inDeg/2 * p.stim.periph.ovalMinorAxis_inDeg/2 );

% priors for line lengths corresponding to
% - extreme low and high values (indeces 1 and 7)
% - p(correct) = [0.6, 0.675, 0.75, 0.825, 0.9] (indeces 2-6)
% as determined from data for the neutral cue pilot. see
% twcf_expt1\pilots\twcf_neutralcue_detection\analysis\priors_for_quest\priors_for_quest.m
% for full derivation
p.stim.periph.lineLengthPrior_inDeg_list = [0.0614, 0.1281, 0.1564, 0.1811, 0.2066, 0.2392, 0.4989];
p.stim.periph.lineWidth_inPix            = 1;

%%% define line lengths for each phase of the experiment
if setup.isMainExpt
    % for main expt, determine line lengths using thresholding results
    p.stim.periph.lineLength_inDeg_list = expt_getThresholds(setup.threshDir, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

elseif setup.isPractice
    % for practice, use line length priors
    p.stim.periph.lineLength_inDeg_list = p.stim.periph.lineLengthPrior_inDeg_list;

elseif setup.takeScreenshot
    % for screenshots, manually define desired line lenghts
    % p.stim.periph.lineLength_inDeg_list = linspace(.2, p.stim.periph.ovalMinorAxis_inDeg, 7);
    p.stim.periph.lineLength_inDeg_list = linspace(0.0614, 0.2, 7); 

elseif setup.isCalibration || setup.isThresholding
    % for calibration, line lengths are defined in the function "getTypeInfo"
    % for thresholding, line lengths are determined dynamically by QUEST
    p.stim.periph.lineLength_inDeg_list = NaN(1, 7);
end

% CENTRAL stimulus properties
p.stim.center.BGwidth_inDeg    = 4; % width of the center stimulus BG
p.stim.center.FGwidth_inDeg    = 2; % width of the center stimulus FG

p.stim.center.lineLength_inDeg = .5;  % length of texture-defining lines
p.stim.center.lineWidth_inPix  = 1;

% RANDOM TEXTURE stimulus properties
if setup.isMainExpt || setup.isPractice || setup.takeScreenshot
    % in most cases, the random texture line lengths are identical to the line lengths defined above
    p.stim.rand.lineLength_inDeg_list = p.stim.periph.lineLength_inDeg_list;

elseif setup.isThresholding || setup.isCalibration
    % for thresholding, random texture line lengths are defined using the line length priors
    % for calibration, we initially calibrate the random texture using the line length priors
    % subsequent calibration of random textures composed of other line lenght sets is performed 
    % on an on-needed basis in the "calibration" section of expt_param below
    p.stim.rand.lineLength_inDeg_list = p.stim.periph.lineLengthPrior_inDeg_list;
end

p.stim.rand.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;


%%% TIMING
p.timing.fixation1Dur_inSecs     = 0.5;  % random texture w/ aperture and fixation cross
p.timing.preCenterStimDur_inSecs = 0.25; % random texture only (no aperture)
p.timing.centerStimDur_inSecs    = 0.25; % central FG/BG texture on random texture
p.timing.fixation2Dur_inSecs     = 0.15; % random texture w/ aperture and fixation cross
p.timing.fixation3Dur_inSecs     = 0.15; % random texture w/ aperture, fixation cross, and 4 inactive cues
p.timing.precueDur_inSecs        = 0.05; % random texture w/ aperture, fixation cross, and 4 active/inactive cues
p.timing.prePeriphStimDur_inSecs = 0.25; % random texture w/ aperture, fixation cross, and 4 inactive cues
                                        
% recommended value <= 250 ms (to prevent re-allocation of attention during stimulus presentation)
p.timing.periphStimDur_inSecs    = 0.25; % 4 peripheral FG/BG textures w/ aperture, fixation cross, and 4 inactive cues

% recommended value 
% >= 200 ms (to prevent postdictive effects, i.e. the response cue retrospectively changing perception of the target)
% <= 300 ms (to avoid tapping memory instead of perception)
p.timing.fixation4Dur_inSecs     = 0.25; % blank BG w/ fixation cross and 4 inactive cues

p.timing.postcueDur_inSecs       = 5;    % blank BG w/ fixation cross, 3 inactive cues, and 1 active cue

p.timing.ITIDur_inSecs           = 0.5;  % time b/t entry of keypress on trial n and onset of fixation 1 on trial n+1

%%% aperture, fixation cross, and cue properties
p.stim.apertureWidth_inDeg = 4;   % width of gray circle containing fixation cross and cues 
p.stim.fixationWidth_inDeg = .35;
p.stim.cueWidth_inDeg      = .1;
p.stim.cueLength_inDeg     = 1;
p.stim.cueBuffer_inDeg     = .5;  % distance b/t fixation center and cue edge

%%% eyetracker parameters

% fixation radius and duration prior to starting a trial
p.eyetracker.trial.fixationRadius_inDeg = p.stim.apertureWidth_inDeg / 2; % the aperture is considered to be the acceptable fixation region
p.eyetracker.trial.fixationDur_inSecs   = 0.5; % duration of valid fixation required for trial to begin
p.eyetracker.trial.timeoutDur_inSecs    = 10; % maximum time that fixation acquisition will last before exiting

% fixation radius and duration prior to starting a block
p.eyetracker.block.fixationRadius_inDeg = p.eyetracker.trial.fixationRadius_inDeg / 2;
p.eyetracker.block.fixationDur_inSecs   = p.eyetracker.trial.fixationDur_inSecs * 2;
p.eyetracker.block.timeoutDur_inSecs    = 10; % maximum time that fixation acquisition will last before exiting

%%% colors
p.stim.lineBGcolor      = 255;               % color of BG on which lines are displayed
p.stim.lineColor        = 0;                 % color of lines
p.stim.cueColorInactive = 0;                 % color of 'inactive' cue
p.stim.cueColorActive   = 255;               % color of 'active' cue
p.stim.fixationColor{1} = 0;                 % fixation color during prestim / stim
p.stim.fixationColor{2} = 3*255/4;           % fixation color following response

% set color of BG for non-stim-related parts of screen so that its
% luminance matches the mean luminance of the texture stimuli
p.stim.BGcolor = round( p.stim.pFilled*p.stim.lineColor + (1-p.stim.pFilled)*p.stim.lineBGcolor );

%% slow things down in practice stage 2

if setup.practiceStage == 2
    p.timing.slowFactor = 4;

    p.timing.fixation1Dur_inSecs     = p.timing.slowFactor * p.timing.fixation1Dur_inSecs;
    p.timing.preCenterStimDur_inSecs = p.timing.slowFactor * p.timing.preCenterStimDur_inSecs;
    p.timing.centerStimDur_inSecs    = p.timing.slowFactor * p.timing.centerStimDur_inSecs;
    p.timing.fixation2Dur_inSecs     = p.timing.slowFactor * p.timing.fixation2Dur_inSecs;
    p.timing.fixation3Dur_inSecs     = p.timing.slowFactor * p.timing.fixation3Dur_inSecs;
    p.timing.precueDur_inSecs        = p.timing.slowFactor * p.timing.precueDur_inSecs;
    p.timing.prePeriphStimDur_inSecs = p.timing.slowFactor * p.timing.prePeriphStimDur_inSecs;
    p.timing.periphStimDur_inSecs    = p.timing.slowFactor * p.timing.periphStimDur_inSecs;
    p.timing.fixation4Dur_inSecs     = p.timing.slowFactor * p.timing.fixation4Dur_inSecs;
    p.timing.postcueDur_inSecs       = Inf;

end

%% keyboard parameters

%%% the meaning of the entries of p.kb.respKeys is as follows: %%%
% DETECTION TASK
% p.kb.respKeys{1} --> classify as vertical oval; report clear perception of shape
% p.kb.respKeys{2} --> classify as vertical oval; report clear perception of texture-defined figure, but unclear perception of shape 
% p.kb.respKeys{3} --> classify as vertical oval; report unclear perception of texture-defined figure
% p.kb.respKeys{4} --> classify as horizontal oval; report unclear perception of texture-defined figure
% p.kb.respKeys{5} --> classify as horizontal oval; report clear perception of texture-defined figure, but unclear perception of shape 
% p.kb.respKeys{6} --> classify as horizontal oval; report clear perception of shape
% 
% p.kb.exitKey --> immediately exits the block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p.kb.exitKey = 'ESCAPE';

p.kb.respKeys    = {'1!' '2@' '3#' '8*' '9(' '0)' p.kb.exitKey};
p.kb.allowedKeys = p.kb.respKeys;

% p.kb.confKeys    = {'7&' '8*' '9(' '0)' p.kb.exitKey};
% p.kb.allowedKeys = [p.kb.respKeys p.kb.confKeys];

if IsOSX
    % p.kb.kbNum = getKeyboardNumber;
    p.kb.kbNum = -1; % temporary hack to ensure kbNum works for Mac
else
    p.kb.kbNum = [];
end
    

%% UNIT CONVERSION : degrees to pixels

% peripheral
p.stim.periph.stimDistFromCenter_inPix = degrees2pixels(p.stim.periph.stimDistFromCenter_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

p.stim.periph.ovalMajorAxis_inPix      = degrees2pixels(p.stim.periph.ovalMajorAxis_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.periph.ovalMinorAxis_inPix      = degrees2pixels(p.stim.periph.ovalMinorAxis_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.periph.circleWidth_inPix        = degrees2pixels(p.stim.periph.circleWidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

p.stim.periph.lineLengthPrior_inPix_list = degrees2pixels(p.stim.periph.lineLengthPrior_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.periph.lineLength_inPix_list      = degrees2pixels(p.stim.periph.lineLength_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);


% center
p.stim.center.BGwidth_inPix    = degrees2pixels(p.stim.center.BGwidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.center.FGwidth_inPix    = degrees2pixels(p.stim.center.FGwidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

p.stim.center.lineLength_inPix = degrees2pixels(p.stim.center.lineLength_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% random
p.stim.rand.lineLength_inPix_list = degrees2pixels(p.stim.rand.lineLength_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% fixation and cue
p.stim.apertureWidth_inPix = degrees2pixels(p.stim.apertureWidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.fixationWidth_inPix = degrees2pixels(p.stim.fixationWidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.cueWidth_inPix      = degrees2pixels(p.stim.cueWidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.cueLength_inPix     = degrees2pixels(p.stim.cueLength_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.cueBuffer_inPix     = degrees2pixels(p.stim.cueBuffer_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% eyetracking fixation region
p.eyetracker.trial.fixationRadius_inPix = degrees2pixels(p.eyetracker.trial.fixationRadius_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.eyetracker.block.fixationRadius_inPix = degrees2pixels(p.eyetracker.block.fixationRadius_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);


%% check to see that line length pixel values fall within min and max range

lineLength_inPix_min        = 3;
lineLength_inPix_max_periph = p.stim.periph.ovalMinorAxis_inPix;
lineLength_inPix_max_center = p.stim.center.FGwidth_inPix;

% enforce min length in pix for periph
f = p.stim.periph.lineLength_inPix_list < lineLength_inPix_min;
p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_min;

% enforce max length in pix for periph
f = p.stim.periph.lineLength_inPix_list > lineLength_inPix_max_periph;
p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_max_periph;


% enforce min length in pix for center
f = p.stim.center.lineLength_inPix < lineLength_inPix_min;
p.stim.center.lineLength_inPix(f) = lineLength_inPix_min;

% enforce max length in pix for periph
f = p.stim.center.lineLength_inPix > lineLength_inPix_max_center;
p.stim.center.lineLength_inPix(f) = lineLength_inPix_max_center;


%% UNIT CONVERSION : pixels to degrees

p.stim.periph.lineWidth_inDeg = pixels2degrees(p.stim.periph.lineWidth_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.stim.center.lineWidth_inDeg = pixels2degrees(p.stim.center.lineWidth_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);


%% UNIT CONVERSION : seconds to frames

if setup.skipFlipIntervalEstimation
    p.screen.refreshRate_inHz = Screen('FrameRate', w);
    p.screen.flipInterval     = 1/p.screen.refreshRate_inHz;
else
    p.screen.flipInterval     = Screen('GetFlipInterval', w, 100, 0.00005, 20);
    p.screen.refreshRate_inHz = round(1/p.screen.flipInterval);
end

p.timing.fixation1Dur_inFrames     = round( p.timing.fixation1Dur_inSecs / p.screen.flipInterval );
p.timing.preCenterStimDur_inFrames = round( p.timing.preCenterStimDur_inSecs / p.screen.flipInterval );
p.timing.centerStimDur_inFrames    = round( p.timing.centerStimDur_inSecs / p.screen.flipInterval );
p.timing.fixation2Dur_inFrames     = round( p.timing.fixation2Dur_inSecs / p.screen.flipInterval );
p.timing.fixation3Dur_inFrames     = round( p.timing.fixation3Dur_inSecs / p.screen.flipInterval );
p.timing.precueDur_inFrames        = round( p.timing.precueDur_inSecs / p.screen.flipInterval );
p.timing.prePeriphStimDur_inFrames = round( p.timing.prePeriphStimDur_inSecs / p.screen.flipInterval );
p.timing.periphStimDur_inFrames    = round( p.timing.periphStimDur_inSecs / p.screen.flipInterval );
p.timing.fixation4Dur_inFrames     = round( p.timing.fixation4Dur_inSecs / p.screen.flipInterval );
p.timing.postcueDur_inFrames       = round( p.timing.postcueDur_inSecs / p.screen.flipInterval );
p.timing.ITIDur_inFrames           = round( p.timing.ITIDur_inSecs / p.screen.flipInterval );

% actual timing of trial events is some integer multiple of the flip interval
p.timing.true_fixation1Dur_inSecs     = p.timing.fixation1Dur_inFrames * p.screen.flipInterval;
p.timing.true_preCenterStimDur_inSecs = p.timing.preCenterStimDur_inFrames * p.screen.flipInterval;
p.timing.true_centerStimDur_inSecs    = p.timing.centerStimDur_inFrames * p.screen.flipInterval;
p.timing.true_fixation2Dur_inSecs     = p.timing.fixation2Dur_inFrames * p.screen.flipInterval;
p.timing.true_fixation3Dur_inSecs     = p.timing.fixation3Dur_inFrames * p.screen.flipInterval;
p.timing.true_precueDur_inSecs        = p.timing.precueDur_inFrames * p.screen.flipInterval;
p.timing.true_prePeriphStimDur_inSecs = p.timing.prePeriphStimDur_inFrames * p.screen.flipInterval;
p.timing.true_periphStimDur_inSecs    = p.timing.periphStimDur_inFrames * p.screen.flipInterval;
p.timing.true_fixation4Dur_inSecs     = p.timing.fixation4Dur_inFrames * p.screen.flipInterval;
p.timing.true_postcueDur_inSecs       = p.timing.postcueDur_inFrames * p.screen.flipInterval;
p.timing.true_ITIDur_inSecs           = p.timing.ITIDur_inFrames * p.screen.flipInterval;


%% psychtoolbox rects

%%% window rects
p.rects.window               = Screen('Rect', w);
[p.rects.midW, p.rects.midH] = getScreenMidpoint(w);

% ensure midW and midH are integers
p.rects.midW = round(p.rects.midW);
p.rects.midH = round(p.rects.midH);

%%% central stim and fixation rects
p.rects.fixation = makeCrosshairDestRect(p.stim.fixationWidth_inPix, [], p.rects.midW, p.rects.midH);
p.rects.aperture = CenterRect(p.stim.apertureWidth_inPix*[0 0 1 1], p.rects.window);
p.rects.centerBG = CenterRect(p.stim.center.BGwidth_inPix*[0 0 1 1], p.rects.window);
p.rects.centerFG = CenterRect(p.stim.center.FGwidth_inPix*[0 0 1 1], p.rects.window);

%%% qudrant rects

% rects for BG periph stim
ww = p.rects.window(3); % width of window rect
wh = p.rects.window(4); % height of window rect

p.rects.periphBG(:,1) = [0;       0; ww/2; wh/2]; % upper left
p.rects.periphBG(:,2) = [ww/2;    0;   ww; wh/2]; % upper right
p.rects.periphBG(:,3) = [ww/2; wh/2;   ww; wh];   % lower right
p.rects.periphBG(:,4) = [0;    wh/2; ww/2; wh];   % lower left

% initial cue rects
cueRect    = [0, 0, p.stim.cueWidth_inPix, p.stim.cueLength_inPix];
cueDist    = p.stim.cueLength_inPix / 2 + p.stim.cueBuffer_inPix;

% initial FG rects
ovalVert  = [0, 0, p.stim.periph.ovalMinorAxis_inPix, p.stim.periph.ovalMajorAxis_inPix];
ovalHoriz = [0, 0, p.stim.periph.ovalMajorAxis_inPix, p.stim.periph.ovalMinorAxis_inPix];
circle    = [0, 0, p.stim.periph.circleWidth_inPix, p.stim.periph.circleWidth_inPix];

% angle list order: upper left, upper right, lower right, lower left
p.rects.angleList_inRadians = [pi/4 3*pi/4 5*pi/4 7*pi/4];
for i = 1:length(p.rects.angleList_inRadians)
    angle = p.rects.angleList_inRadians(i);
    
    % peripheral stimulus rects
    x_pos = p.stim.periph.stimDistFromCenter_inPix * cos(angle);
    y_pos = p.stim.periph.stimDistFromCenter_inPix * sin(angle);

    % vertical oval (code=1)
    p.rects.periphFG{1}(:,i) = CenterRectOnPoint(ovalVert, p.rects.midW - x_pos, p.rects.midH - y_pos)';
    p.rects.periphFG{1}(:,i) = MakeRectPositionInteger(p.rects.periphFG{1}(:,i)')'; % ensure integer rect coordinates
    
    % horizontal oval (code=2)
    p.rects.periphFG{2}(:,i) = CenterRectOnPoint(ovalHoriz, p.rects.midW - x_pos, p.rects.midH - y_pos)';
    p.rects.periphFG{2}(:,i) = MakeRectPositionInteger(p.rects.periphFG{2}(:,i)')'; % ensure integer rect coordinates
    
    % circle (code=3)
    p.rects.periphFG{3}(:,i) = CenterRectOnPoint(circle, p.rects.midW - x_pos, p.rects.midH - y_pos)';
    p.rects.periphFG{3}(:,i) = MakeRectPositionInteger(p.rects.periphFG{3}(:,i)')'; % ensure integer rect coordinates    
    
    % cue rects
    x_pos = cueDist * cos(angle);
    y_pos = cueDist * sin(angle);

    p.rects.cueRect(:,i) = CenterRectOnPoint(cueRect, p.rects.midW - x_pos, p.rects.midH - y_pos)';
    p.rects.cueRect(:,i) = MakeRectPositionInteger(p.rects.cueRect(:,i)')'; % ensure integer rect coordinates

end


%% masks

% peripheral ovals and circle
for i = 1:length(p.rects.angleList_inRadians)

    % vertical oval mask
    Screen('FillRect', w, 0);
    Screen('FillOval', w, 255, p.rects.periphFG{1}(:,i));
    p.masks.periphFG{1}{i} = Screen('GetImage', w, p.rects.periphFG{1}(:,i), 'backBuffer', [], 1);
    
    % horizontal oval mask
    Screen('FillRect', w, 0);
    Screen('FillOval', w, 255, p.rects.periphFG{2}(:,i));
    p.masks.periphFG{2}{i} = Screen('GetImage', w, p.rects.periphFG{2}(:,i), 'backBuffer', [], 1);    
    
    % circle mask
    Screen('FillRect', w, 0);
    Screen('FillOval', w, 255, p.rects.periphFG{3}(:,i));
    p.masks.periphFG{3}{i} = Screen('GetImage', w, p.rects.periphFG{3}(:,i), 'backBuffer', [], 1);    

end

% center BG
Screen('FillRect', w, 0);
Screen('FillOval', w, 255, p.rects.centerBG);
p.masks.centerBG = Screen('GetImage', w, p.rects.centerBG, 'backBuffer', [], 1);
    
% center FG
Screen('FillRect', w, 0);
Screen('FillOval', w, 255, p.rects.centerFG);
p.masks.centerFG = Screen('GetImage', w, p.rects.centerFG, 'backBuffer', [], 1);

% center BG annulus
Screen('FillRect', w, 0);
Screen('FillOval', w, 255, p.rects.centerBG);
Screen('FillOval', w, 0, p.rects.centerFG);
p.masks.centerBGannulus = Screen('GetImage', w, p.rects.centerBG, 'backBuffer', [], 1);


%% cue textures

for i = 1:length(p.stim.cueColorActive)
    cueActive(:,:,i) = p.stim.cueColorActive(i) * ones(p.stim.cueLength_inPix, p.stim.cueWidth_inPix);
end
p.tex.cue_active = Screen('MakeTexture', w, cueActive);

for i = 1:length(p.stim.cueColorInactive)
    cueInactive(:,:,i) = p.stim.cueColorInactive(i) * ones(p.stim.cueLength_inPix, p.stim.cueWidth_inPix);
end
p.tex.cue_inactive = Screen('MakeTexture', w, cueInactive);


%% auditory feedback

p.auditoryFB.Fs             = 44100;
p.auditoryFB.toneFreq       = [523, 784]; % lower C and higher G
p.auditoryFB.toneDur_inSecs = .25;        % duration of tone in seconds
for i_tone = 1:numel(p.auditoryFB.toneFreq)
    tone = MakeBeep(p.auditoryFB.toneFreq(i_tone), p.auditoryFB.toneDur_inSecs);
    p.auditoryFB.tones(i_tone,:) = applyEnvelope(tone, p.auditoryFB.Fs);
end


%% text settings

p.text.nLettersPerCol  = 50; 
p.text.widthBuffer     = 0.15;
[fontSize, sx, wrapat] = getTextSettings(w, p.rects.window, p.text.nLettersPerCol, p.text.widthBuffer);

p.text.fontSize = fontSize;
p.text.sx       = sx;
p.text.sy       = 'center';
p.text.wrapat   = wrapat;

Screen('TextSize', w, fontSize);


%% calibration
%  determine nLines needed for p(filled) target for each calibration type

% determine min and max line lengths that thresholding could visit
p.calibration.lineLength_inPix_min        = lineLength_inPix_min;
p.calibration.lineLength_inPix_max_periph = lineLength_inPix_max_periph;
p.calibration.lineLength_inPix_max_center = lineLength_inPix_max_center;

p.calibration.lineLength_inDeg_min        = pixels2degrees(p.calibration.lineLength_inPix_min, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.calibration.lineLength_inDeg_max_periph = p.stim.periph.ovalMinorAxis_inDeg;
p.calibration.lineLength_inDeg_max_center = p.stim.center.FGwidth_inDeg;


% define calibration types
p.calibration.typeNames = {'periphBG', 'periphFG_oval', 'periphFG_circle', 'centerBG_annulus', 'centerFG_circle', 'random'};
p.calibration.allCalibrated = 1;

for i_type = 1:length(p.calibration.typeNames)
    
    type = p.calibration.typeNames{i_type};
    info = getTypeInfo(type, p);
    
    switch type

        case 'random'
            nLines = nLines4pFilled(type, p.stim.pFilled, info.lineLength_inPix_list, info.lineWidth_inPix, info.lineRect, info.innerRect);
            eval(['p.calibration.' type '.nLines = nLines;'])
            
            % perform calibration for random texture using line length set
            % from thresholding, if this hasn't been done already
            if any(isnan(nLines))
                makePlot = 1; savePlot = 1; saveFit = 1; showLines = 0;
                fit = pfilled_calibration(w, p, type, info.lineLength_inPix_list, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);
                nLines = nLines4pFilled(type, p.stim.pFilled, info.lineLength_inPix_list, info.lineWidth_inPix, info.lineRect, info.innerRect);
                eval(['p.calibration.' type '.nLines = nLines;'])        
            end
                        
        otherwise
            
            eval(['p.calibration.' type '.lineLength_inPix_list = info.lineLength_inPix_list;'])
            
            for i_line = 1:length(info.lineLength_inPix_list)
                lineLength_inPix = info.lineLength_inPix_list(i_line);
                nLines = nLines4pFilled(type, p.stim.pFilled, lineLength_inPix, info.lineWidth_inPix, info.lineRect, info.innerRect);
                eval(['p.calibration.' type '.nLines(i_line) = nLines;'])
            end
    end
    
    eval(['p.calibration.' type '.isCalibrated = ~any(isnan(nLines));'])
    p.calibration.typeCalibrated(i_type) = ~any(isnan(nLines));
    if any(isnan(nLines))
        p.calibration.allCalibrated = 0;
    end
end

p.calibration.detectionCalibrated = p.calibration.periphBG.isCalibrated & ...
                                    p.calibration.periphFG_oval.isCalibrated & ...
                                    p.calibration.random.isCalibrated;
                                
                                
%% eyetracking

p.eyetracker.doEyetracking = setup.doEyetracking;
if setup.doEyetracking == 2
    p.eyetracker.drawGazeLoc = 1;
else
    p.eyetracker.drawGazeLoc = 0;
end
p.rects.gaze               = p.stim.fixationWidth_inPix*[0 0 1 1];


%% QUEST parameters

% see
% twcf_expt1\pilots\twcf_neutralcue_detection\analysis\priors_for_quest\priors_for_quest.m
% for derivation and inspection of QUEST priors

% threshold
p.quest.pThreshold = 0.75; 
p.quest.tGuess     = -0.74217;
p.quest.tGuessSD   = 3;

% beta = psychometric function slope
p.quest.beta = 3.3438;

% delta = guess rate
p.quest.delta = 0.066909;

% gamma = chance rate
p.quest.gamma = 0.5;

% grain and range of x-values for psychometric function
p.quest.grain = 0.01;
p.quest.range = 5;