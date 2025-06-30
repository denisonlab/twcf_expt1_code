function p = expt_param(w, setup, w_tilt)

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

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isTraining')
    setup.isTraining = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isThresholding')
    setup.isThresholding = 0;
end

if ~exist('setup','var') || isempty(setup) || ~isfield(setup, 'isValidation')
    setup.isValidation = 0;
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

% Pixels per degree conversion for RD functions
p.ppd = degrees2pixels(1,p.screen.distFromScreen_inCm,p.screen.pixels_perCm);

% Contrast resolution 
p.screen.contrastRes = 0.0078; % RGB 0-255 space,  1/(256/2) = 0.0078, or 0.78%

%% MAIN PARAMETERS TO PLAY WITH ARE HERE

% density of stimulus displays
% p.stim.pFilled = 0.15; % indicates how many pixels of the BG are filled in by randomly drawn lines

% PERIPHERAL stimulus properties
% _inDeg suffix denotes variable is measured in units of visual degree
p.stim.periph.stimDistFromCenter_inDeg = 5;  % 8, distance of the center of peripheral stim from central fixation point

% Size
p.stim.periph.ovalMajorAxis_inDeg      = 5;  % 8, length of the foreground oval along its major axis
p.stim.periph.ovalMinorAxis_inDeg      = 5;  % 8, 3, length of the foreground oval along its minor axis

% GABOR settings

% when the foreground figure is a circle instead of an ellipse, it makes
% sense to set the area of the circle equal to the area of the ellipse.
% since area(circle) = pi*r^2 and area(ellipse) = pi*a*b where a and b are
% the distances from the center of the ellipse to the vertex and co-vertex,
% setting r^2 = a*b ensures the area of the circle with radius r equals the
% area of the ellipse
% note this is used for size of gabors for consistency
p.stim.periph.circleWidth_inDeg     = 2 * sqrt( p.stim.periph.ovalMajorAxis_inDeg/2 * p.stim.periph.ovalMinorAxis_inDeg/2 );
p.stim.periph.circleWidth_inPix     = p.ppd * p.stim.periph.circleWidth_inDeg; 
% p.stim.periph.circleWidth_inPix     = degrees2pixels(p.stim.periph.circleWidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

%p.stim.gab.showPlaceholders = 1; % remove this later
%p.stim.gab.imPos = [4.25 4.25]; % position
%p.stim.gab.imSize = 4.25; % side length of square holding gabor

%%% GRATING parameters
p.stim.gab.gratingSF = 1; % 0.75; 1 for 5 deg ecc? % try 0.5 - 4 cpd, 1.3 is preferred dpc at 8 deg ecc full contrast = 1/1.3 ~= 0.75 cpd
% See Broderick, Simoncelli, Winawer 2022 
p.stim.gab.orientation = [-45 45]; % possible max orientations
p.stim.gab.phase = 0; 

% grating edge 
p.stim.gab.aperture = 'cosine'; %  'gaussian' 'square' 'cosine'
p.stim.gab.apertureEdgeWidth_inDeg = 0.5; % degrees
p.stim.gab.apertureEdgeWidth_inPix = p.stim.gab.apertureEdgeWidth_inDeg * p.ppd; 
switch p.stim.gab.aperture
    case 'gaussian'
        p.stim.gab.rad = p.stim.periph.circleWidth_inPix/8; % SD of gabor, 4 SDs visible at full contrast 
    case 'square'
        p.stim.gab.rad = p.stim.periph.circleWidth_inPix/2; % radius 
    case 'cosine'
        p.stim.gab.rad = (p.stim.periph.circleWidth_inPix/2) - p.stim.gab.apertureEdgeWidth_inPix; % radius 
end

%%% NOISE parameters 
% noise type 
p.stim.gab.noiseType     = 'filteredSF'; % 'uniform' 'gaussian' 'OOF' 'filteredSF' 'filteredOriSF' 'highPassFilter'
p.stim.gab.noiseContrast = 0.2; % 0.5; % 0.5 0.2; 0.08 (Rahnev) 

% Piloting for contrast priors in twcf_cue_gab_det yielded an estimate for
% the contrast yielding 75% correct discrimination performance for
% post-cued stimulus-present trials as XXX. 
% (see
% twcf_expt1\pilots\twcf_neutralcue_detection\analysis\priors_for_quest\priors_for_quest.m
% for full derivation.) 
% 
% In the discrimination task, we use contrasts defined over a
% suprathreshold range of visibility. 
% 
% Specifically, we set the middle contrast (i.e. the 4th of the 7 values)
% to the contrast where p(correct) in the neutral cue detection pilot =
% 0.95. This turns out to be a contrast of X. 
% 
% We then determine the other contrasts as follows: 
% - the lowest contrast (1 of 7) is defined as the contrast where
% p(correct) in the neutral cue pilot = 0.75. This turns out to be a
% contrast of X. 
% - The contrasts between the 1st and 4th are defined to be evenly spaced
% on a log10 scale. 
% - The highest contrast (7 of 7) is defined to be the contrast of
% (maximum = 0.5??) 
% The contrasts between the 4th and 7th are defined to be evenly spaced on
% a log10 scale. 

% This procedure results in a different spacing between line lengths 1-4
% and line lengths 4-7. We chose to use this procedure on the basis of
% piloting (in twcf_cue_gab_det_MCS) which suggested that this procedure
% would yield the maximum range of p(correct) values for the different
% cueing conditions, which is desirable for the analysis of subjective visibility as a
% function of performance. 

% p.stim.gab.contrast_pCorr_75  = 0.1123; % lowest contrast (1 of 7) 
% p.stim.gab.contrast_pCorr_95  = 0.1721; % midway contrast (4 of 7) 
% p.stim.gab.contrast_pCorr_100 = 0.377; % 0.5; % highest contrast (7 of 7) % 0.2 is the fitted max.. constrain by that? two points in upper asymptote 

% list or prior list?? 
% p.stim.gab.gratingContrast_list(1:4) = 10 .^ linspace( log10(p.stim.gab.contrast_pCorr_75), log10(p.stim.gab.contrast_pCorr_95),  4);
% p.stim.gab.gratingContrast_list(4:7) = 10 .^ linspace( log10(p.stim.gab.contrast_pCorr_95), log10(p.stim.gab.contrast_pCorr_100), 4);

p.stim.gab.gratingContrast_min = 0.05; 
p.stim.gab.gratingContrast_max = 0.5; % 0.5 0.8
p.stim.gab.gratingContrast_list = logspace(log10(p.stim.gab.gratingContrast_min), log10(p.stim.gab.gratingContrast_max), 7); 

p.stim.gab.contrastPrior_list = p.stim.gab.gratingContrast_list; 

% switch p.stim.gab.noiseContrast
%     case 0.5
%         p.stim.gab.gratingContrast_min = 0.05;
%         p.stim.gab.gratingContrast_max = 0.2;
%         p.stim.gab.contrastPrior_list = logspace(log10(p.stim.gab.gratingContrast_min), log10(p.stim.gab.gratingContrast_max) ,7); 
%     case 0.2
%         p.stim.gab.gratingContrast_min = 0.05*(0.2/0.5);
%         p.stim.gab.gratingContrast_max = 0.2*(0.2/0.5);
% 
%     otherwise
%         error('signal contrast for desired noise contrast undefined')
% end

%%% define contrasts for each phase of the experiment
if setup.isMainExpt || setup.isValidation

    p.stim.gab.contrast_list = p.stim.gab.contrastPrior_list; 

    % if thresholds greater than max possible contrast, redo threshold 
    % if any(p.stim.gab.contrast_list > 1 - p.stim.gab.noiseContrast)
    %     error('Threshold contrast higher than maximum possible. Please redo threshold.')
    % end

    p.stim.periph.w_tilt = expt_getThreshold(setup.threshDir); % LOAD THRESHOLD FOR ACTUAL DATA COLLECTION!
    
elseif setup.isPractice
    % for practice, use easier contrasts 
    % p.stim.periph.lineLength_inDeg_list = p.stim.periph.lineLengthPrior_inDeg_list;
    % p.stim.gab.gratingContrast_max = 0.9 - p.stim.gab.noiseContrast; 
    % p.stim.gab.contrast_list = logspace(log10(p.stim.gab.gratingContrast_min), log10(p.stim.gab.gratingContrast_max), 7); 
    
    p.stim.gab.contrast_list = p.stim.gab.contrastPrior_list;
    
    % for practice use easy tilt
    p.stim.periph.w_tilt = 1; 

elseif setup.takeScreenshot || setup.isTraining
    % for screenshots, manually define desired contrasts
    % p.stim.periph.lineLength_inDeg_list = linspace(.2, p.stim.periph.ovalMinorAxis_inDeg, 7);
    % p.stim.gab.gratingContrast_max = 0.9 - p.stim.gab.noiseContrast; 
    % p.stim.gab.contrast_list = logspace(log10(p.stim.gab.gratingContrast_min), log10(p.stim.gab.gratingContrast_max), 7); 
    
    p.stim.gab.contrast_list = p.stim.gab.contrastPrior_list;
    p.stim.periph.w_tilt = 1; 

elseif setup.isCalibration || setup.isThresholding 
    % for calibration, line lengths are defined in the function "getTypeInfo"
    % for thresholding, line lengths are determined dynamically by QUEST
    % p.stim.periph.lineLength_inDeg_list = NaN(1, 7);
    % p.stim.gab.contrast_list = NaN(1, 7);

    % p.stim.gab.contrast_list = p.stim.gab.gratingContrast_list;
    % set all to median contrast at idx 4 
    p.stim.gab.contrast_list = repmat(p.stim.gab.contrastPrior_list(4), size(p.stim.gab.contrastPrior_list)); 
    
    % p.stim.gab.contrast_list = p.stim.gab.contrastPrior_list; % all 7 contrasts in threshold

    p.stim.periph.w_tilt = []; 

elseif setup.isPiloting 
    % for piloting, use method of constant stimuli 
    p.stim.gab.contrast_list = p.stim.gab.contrastPrior_list; % logspace(log10(1-p.stim.gab.noiseContrast),log10(0.05),7); 

    % p.stim.gab.noiseContrast = NaN; 
    % p.stim.gab.noiseContrast = 1 - p.stim.gab.contrast_list; 

    p.stim.periph.w_tilt = 1; 

end

% CENTRAL stimulus properties
% p.stim.center.BGwidth_inDeg    = 4; % width of the center stimulus BG
% p.stim.center.FGwidth_inDeg    = 2; % width of the center stimulus FG

%p.stim.center.lineLength_inDeg = .5;  % length of texture-defining lines
%p.stim.center.lineWidth_inPix  = 1;

% RANDOM TEXTURE stimulus properties

%%we can add variables here if need be

% if setup.isMainExpt || setup.isPractice || setup.takeScreenshot
%     % in most cases, the random texture line lengths are identical to the line lengths defined above
%     % p.stim.rand.lineLength_inDeg_list = p.stim.periph.lineLength_inDeg_list;
% 
% elseif setup.isThresholding || setup.isCalibration
%     % for thresholding, random texture line lengths are defined using the line length priors
%     % for calibration, we initially calibrate the random texture using the line length priors
%     % subsequent calibration of random textures composed of other line lenght sets is performed 
%     % on an on-needed basis in the "calibration" section of expt_param below
%     % p.stim.rand.lineLength_inDeg_list = p.stim.periph.lineLengthPrior_inDeg_list;
% end

% p.stim.rand.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;


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

p.timing.postcueDur_inSecs       = 5;    % blank BG w/ grey fixation cross, 3 inactive cues, and 1 active cue (response 1) 
p.timing.postcue2Dur_inSecs      = 5;    % blank BG w/ white fixation cross, 3 inactive cues, and 1 active cue (response 2) 

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
% p.stim.lineBGcolor      = 255;               % color of BG on which lines are displayed
% p.stim.lineColor        = 0;                 % color of lines
p.stim.cueColorInactive = 0;                 % color of 'inactive' cue
p.stim.cueColorActive   = 255;               % color of 'active' cue
p.stim.fixationColor{1} = 0;                 % fixation color during prestim / stim
p.stim.fixationColor{2} = 3*255/4;           % fixation color following response 1 
p.stim.fixationColor{3} = 255;               % fixation color following response 2 

% set color of BG for non-stim-related parts of screen so that its
% luminance matches the mean luminance of the texture stimuli
% p.stim.BGcolor = round( p.stim.pFilled*p.stim.lineColor + (1-p.stim.pFilled)*p.stim.lineBGcolor );
p.stim.BGcolor = round(255/2); % 217 from texture 

%% slow things down in practice stage 2

if setup.practiceStage == 2
    p.timing.slowFactor = 2; % 4 for textures, too slow for gabors 

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
    p.timing.postcue2Dur_inSecs      = Inf; 

end

%% keyboard parameters

%%% the meaning of the entries of p.kb.respKeys is as follows: %%%
% DETECTION TASK
% p.kb.respKeys{1} --> -45° tilt; report periph more visible than ref
% p.kb.respKeys{2} --> -45° tilt; report periph less visible than ref
% p.kb.respKeys{3} --> +45° tilt; report periph less visible than ref
% p.kb.respKeys{4} --> +45° tilt; report periph more visible than ref
% 
% p.kb.exitKey --> immediately exits the block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p.kb.exitKey = 'ESCAPE';

p.kb.respKeys    = {'1!' '2@' '9(' '0)' p.kb.exitKey}; % 1st button press 
p.kb.allowedKeys = p.kb.respKeys;

p.kb.respKeys2    = {'3#' '8*' p.kb.exitKey}; % 2nd button press
p.kb.allowedKeys2 = p.kb.respKeys2; 

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

% p.stim.periph.ovalMajorAxis_inPix      = degrees2pixels(p.stim.periph.ovalMajorAxis_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
% p.stim.periph.ovalMinorAxis_inPix      = degrees2pixels(p.stim.periph.ovalMinorAxis_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

%p.stim.periph.lineLengthPrior_inPix_list = degrees2pixels(p.stim.periph.lineLengthPrior_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
%p.stim.periph.lineLength_inPix_list      = degrees2pixels(p.stim.periph.lineLength_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% center
% p.stim.center.BGwidth_inPix    = degrees2pixels(p.stim.center.BGwidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
% p.stim.center.FGwidth_inPix    = degrees2pixels(p.stim.center.FGwidth_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% p.stim.center.lineLength_inPix = degrees2pixels(p.stim.center.lineLength_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% random
% p.stim.rand.lineLength_inPix_list = degrees2pixels(p.stim.rand.lineLength_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

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

% lineLength_inPix_min        = 3;
% lineLength_inPix_max_periph = p.stim.periph.ovalMinorAxis_inPix;
% lineLength_inPix_max_center = p.stim.center.FGwidth_inPix;

% % enforce min length in pix for periph
% f = p.stim.periph.lineLength_inPix_list < lineLength_inPix_min;
% p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_min;
% 
% % enforce max length in pix for periph
% f = p.stim.periph.lineLength_inPix_list > lineLength_inPix_max_periph;
% p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_max_periph;

% 
% % enforce min length in pix for center
% f = p.stim.center.lineLength_inPix < lineLength_inPix_min;
% p.stim.center.lineLength_inPix(f) = lineLength_inPix_min;
% 
% % enforce max length in pix for periph
% f = p.stim.center.lineLength_inPix > lineLength_inPix_max_center;
% p.stim.center.lineLength_inPix(f) = lineLength_inPix_max_center;


%% UNIT CONVERSION : pixels to degrees

% p.stim.periph.lineWidth_inDeg = pixels2degrees(p.stim.periph.lineWidth_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
% p.stim.center.lineWidth_inDeg = pixels2degrees(p.stim.center.lineWidth_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);


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
p.timing.postcue2Dur_inFrames      = round( p.timing.postcue2Dur_inSecs / p.screen.flipInterval ); 
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
p.timing.true_postcue2Due_inSecs      = p.timing.postcue2Dur_inFrames * p.screen.flipInterval; 
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
% p.rects.centerBG = CenterRect(p.stim.center.BGwidth_inPix*[0 0 1 1], p.rects.window);
% p.rects.centerFG = CenterRect(p.stim.center.FGwidth_inPix*[0 0 1 1], p.rects.window);

%%% qudrant rects

% rects for BG periph stim
% ww = p.rects.window(3); % width of window rect
% wh = p.rects.window(4); % height of window rect
% 
% p.rects.periphBG(:,1) = [0;       0; ww/2; wh/2]; % upper left
% p.rects.periphBG(:,2) = [ww/2;    0;   ww; wh/2]; % upper right
% p.rects.periphBG(:,3) = [ww/2; wh/2;   ww; wh];   % lower right
% p.rects.periphBG(:,4) = [0;    wh/2; ww/2; wh];   % lower left

% initial cue rects
cueRect    = [0, 0, p.stim.cueWidth_inPix, p.stim.cueLength_inPix];
cueDist    = p.stim.cueLength_inPix / 2 + p.stim.cueBuffer_inPix;

% initial FG rects
% ovalVert  = [0, 0, p.stim.periph.circleWidth_inPix, p.stim.periph.circleWidth_inPix];
% ovalHoriz = [0, 0, p.stim.periph.circleWidth_inPix, p.stim.periph.circleWidth_inPix];
circle    = [0, 0, p.stim.periph.circleWidth_inPix, p.stim.periph.circleWidth_inPix];

% angle list order: upper left, upper right, lower right, lower left
p.rects.angleList_inRadians = [pi/4 3*pi/4 5*pi/4 7*pi/4];
for i = 1:length(p.rects.angleList_inRadians)
    angle = p.rects.angleList_inRadians(i);
    
    % peripheral stimulus rects
    x_pos = p.stim.periph.stimDistFromCenter_inPix * cos(angle);
    y_pos = p.stim.periph.stimDistFromCenter_inPix * sin(angle);

    % vertical oval (code=1) --> -45 for gabor (all circle) 
    p.rects.periphFG{1}(:,i) = CenterRectOnPoint(circle, p.rects.midW - x_pos, p.rects.midH - y_pos)';
    p.rects.periphFG{1}(:,i) = MakeRectPositionInteger(p.rects.periphFG{1}(:,i)')'; % ensure integer rect coordinates
    
    % horizontal oval (code=2) --> 45 for gabor (all circle) 
    p.rects.periphFG{2}(:,i) = CenterRectOnPoint(circle, p.rects.midW - x_pos, p.rects.midH - y_pos)';
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
%for i = 1:length(p.rects.angleList_inRadians)

%     % vertical oval mask
%     Screen('FillRect', w, 0);
%     Screen('FillOval', w, 255, p.rects.periphFG{1}(:,i));
%     p.masks.periphFG{1}{i} = Screen('GetImage', w, p.rects.periphFG{1}(:,i), 'backBuffer', [], 1);
%     
%     % horizontal oval mask
%     Screen('FillRect', w, 0);
%     Screen('FillOval', w, 255, p.rects.periphFG{2}(:,i));
%     p.masks.periphFG{2}{i} = Screen('GetImage', w, p.rects.periphFG{2}(:,i), 'backBuffer', [], 1);    
    
    % circle mask
    %Screen('FillRect', w, 0);
    %Screen('FillOval', w, 255, p.rects.periphFG{3}(:,i));
    %p.masks.periphFG{3}{i} = Screen('GetImage', w, p.rects.periphFG{3}(:,i), 'backBuffer', [], 1);    
 
% end

% moved to makeStimGabPeriph = easier to generate with the gabors

% center BG
% Screen('FillRect', w, 0);
% Screen('FillOval', w, 255, p.rects.centerBG);
% p.masks.centerBG = Screen('GetImage', w, p.rects.centerBG, 'backBuffer', [], 1);
    
% center FG
% Screen('FillRect', w, 0);
% Screen('FillOval', w, 255, p.rects.centerFG);
% p.masks.centerFG = Screen('GetImage', w, p.rects.centerFG, 'backBuffer', [], 1);

% center BG annulus
% Screen('FillRect', w, 0);
% Screen('FillOval', w, 255, p.rects.centerBG);
% Screen('FillOval', w, 0, p.rects.centerFG);
% p.masks.centerBGannulus = Screen('GetImage', w, p.rects.centerBG, 'backBuffer', [], 1);


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
p.reqlatencyclass = 1; % For BU PsychPort audio; Level 2 means: Take full control over the audio device, even if this causes other sound applications to fail or shutdown.

% BU initialize sound
if strcmp( setup.site , 'BU')
    deviceName = 'sysdefault'; % desired device; 'sysdefault' 'Scarlett'
    PsychPortAudio('Close');

    % Initialize the sound driver
    InitializePsychSound(1);

    % Find appropriate sound output (-1 default not working)
    PsychPortAudioDevices = PsychPortAudio('GetDevices');
    PsychPortAudioDeviceNames = {PsychPortAudioDevices.DeviceName};
    PsychPortAudioDeviceIndex = [PsychPortAudioDevices.DeviceIndex];

    deviceNameIdxs = find( contains(PsychPortAudioDeviceNames, deviceName) );
    deviceIdx =  PsychPortAudioDeviceIndex( deviceNameIdxs(:,1) ); 

    % deviceID = PsychPortAudioDeviceNames( find(deviceName, 1, 'first') );
    pahandle = PsychPortAudio('Open', deviceIdx(1), 1, p.reqlatencyclass,  p.auditoryFB.Fs, 2); %scarlett, mode, latency, Fs, stereo
    Snd('Open', pahandle, 1); % links eyetracker sound output to psychportaudio
    disp('BU audio initialized. ')
end

% Make sounds 
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

%temporary fix for m1
% Screen('TextSize', w, 12);


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
p.quest.pThreshold = 0.75; % target performance 

% threshold type 
% p.quest.type = 'logw'; % 'log1-w' 'linearw', 'logw' is default 

p.quest.tGuess     = log10(0.25); % initial guess 0.75 --> 33.3°, 11.25°? 

p.quest.tGuessSD   = 3; % 3 is the QUEST toolbox's suggested default 

% beta = psychometric function slope
p.quest.beta = 3.5; % 3.5 is the QUEST toolbox's suggested default 

% delta = guess rate
p.quest.delta = 0.039; 

% gamma = chance rate
p.quest.gamma = 0.5; % discrimination 

% grain and range of x-values for psychometric function
p.quest.grain = 0.01; % luminance 
p.quest.range = 5; % recommended, 1 - p.stim.gab.noiseContrast - p.stim.gab.gratingContrast_min; % 5;



