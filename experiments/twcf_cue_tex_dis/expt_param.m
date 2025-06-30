function p = expt_param(w, setup, w_ecc)

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


%% MAIN PARAMETERS TO PLAY WITH ARE HERE

% density of stimulus displays
p.stim.pFilled = 0.15; % indicates how many pixels of the BG are filled in by randomly drawn lines


% PERIPHERAL stimulus properties
% _inDeg suffix denotes variable is measured in units of visual degree

% NOTE: the values of oval major and minor axis defined here are defaults
% set equal to the values used in the detection task. the actual values
% used in the main experiment are determined via thresholding.
p.stim.periph.stimDistFromCenter_inDeg = 8;  % distance of the center of peripheral stim from central fixation point

% this corresponds to the width of a circle whose area equals an oval w/
% axes of 5 deg and 3 deg, the values used in twcf_cue_tex_det
p.stim.periph.circleWidth_inDeg = 2 * sqrt( 5/2 * 3/2 );


%%% oval aspect ration
% define oval aspect ratio for each phase of the experiment
if setup.isValidation || setup.isMainExpt
    % for validation and main expt, determine line lengths using thresholding results
    p.stim.periph.w_ecc = expt_getThreshold(setup.threshDir);

elseif setup.takeScreenshot
    % for screenshots, manually define desired line lenghts
    p.stim.periph.w_ecc = 1;

elseif setup.isThresholding 
    p.stim.periph.w_ecc = 1;

else
    p.stim.periph.w_ecc = 1;
end

% overwrite w_ecc with input value, as long as this is not main expt block
if exist('w_ecc','var') && (w_ecc >= 0 && w_ecc <= 1) && ~setup.isMainExpt && ~setup.isValidation
    p.stim.periph.w_ecc = w_ecc;
end

% determine oval dimensions according to w_ecc

% define min and max values for oval major axis
onePix_inDeg = pixels2degrees(1, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
ovalMajorAxis_inDeg_min = p.stim.periph.circleWidth_inDeg + onePix_inDeg;
ovalMajorAxis_inDeg_max = 5;

% define major axis using w_ecc to scale between min and max values
p.stim.periph.ovalMajorAxis_inDeg = ovalMajorAxis_inDeg_min + p.stim.periph.w_ecc * (ovalMajorAxis_inDeg_max - ovalMajorAxis_inDeg_min);

% define minor axis so that the area of the oval is the same as that
% used in twcf_cue_tex_det
p.stim.periph.ovalMinorAxis_inDeg = p.stim.periph.circleWidth_inDeg^2 / p.stim.periph.ovalMajorAxis_inDeg;

%%% end oval aspect ratio


% piloting for line length priors in twcf_cue_tex_det yielded an estimate
% for the line length yielding 75% correct discrimination performance for
% post-cued stimulus-present trials as 0.1811 degrees. (see
% twcf_expt1\pilots\twcf_neutralcue_detection\analysis\priors_for_quest\priors_for_quest.m
% for full derivation.)
% 
% in the discrimination task, we use line length values defined over a
% suprathreshold range of figure visibility. 
%
% specifically, we set the middle line length value (i.e. the 4th of the 7 
% values) to the line length where p(correct) in the neutral cue detection 
% pilot = 0.95. this turns out to be a line length of 0.4122 degrees.
%
% we then determine the other line lengths as follows:
% - the smallest line length (1 of 7) is defined as the line length where 
%   p(correct) in the neutral cue pilot = 0.75. this turns out to be a line
%   length of 0.1811 degrees.
% - the line lengths between the 1st and 4th are defined to be evenly
%   spaced on a log10 scale.
% - the largest line length (7 of 7) is defined to be the length of the 
%   minor axis of the oval used in the detection task, i.e. 3 degrees.
% - the line lengths between the 4th and 7th are defined to be evenly
%   spaced on a log10 scale.
%
% this procedure results in different spacing between line lengths 1-4 and
% line lengths 4-7. we chose to use this procedure on the basis of initial
% piloting (in twcf_cue_tex_dis_v2) which suggested that this procedure
% would yield the maximum range of p(correct) values for the different
% cuing conditions, which is desireable for the analysis of confidence as a
% function of performance.

p.stim.periph.lineLength_inDeg_list(1:4) = 10 .^ linspace(log10(0.1811), log10(.4122), 4);
p.stim.periph.lineLength_inDeg_list(4:7) = 10 .^ linspace(log10(.4122), log10(3), 4);

p.stim.periph.lineWidth_inPix = 1;

    
%%% define line lengths separately for special cases
if setup.takeScreenshot
    % for screenshots, manually define desired line lengths
    p.stim.periph.lineLength_inDeg_list = 10 .^ linspace(log10(0.1811), log10(3), 7);

% % elseif setup.isCalibration
% %     % for calibration, line lengths are defined in the function "getTypeInfo"
% %     p.stim.periph.lineLength_inDeg_list = NaN(1, 7);
end


% RANDOM TEXTURE stimulus properties
p.stim.rand.lineLength_inDeg_list = p.stim.periph.lineLength_inDeg_list;
p.stim.rand.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;


%%% TIMING
p.timing.fixation1Dur_inSecs     = 0.5;  % random texture w/ aperture and fixation cross
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
p.stim.BGcolor          = round(255*(1-p.stim.pFilled));

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
    p.timing.fixation3Dur_inSecs     = p.timing.slowFactor * p.timing.fixation3Dur_inSecs;
    p.timing.precueDur_inSecs        = p.timing.slowFactor * p.timing.precueDur_inSecs;
    p.timing.prePeriphStimDur_inSecs = p.timing.slowFactor * p.timing.prePeriphStimDur_inSecs;
    p.timing.periphStimDur_inSecs    = p.timing.slowFactor * p.timing.periphStimDur_inSecs;
    p.timing.fixation4Dur_inSecs     = p.timing.slowFactor * p.timing.fixation4Dur_inSecs;
    p.timing.postcueDur_inSecs       = Inf;

end

%% keyboard parameters

%%% the meaning of the entries of p.kb.respKeys is as follows: %%%
% DISCRIMINATION TASK
% p.kb.respKeys{1} --> classify as vertical oval; report peripheral stimulus more visible than central stimulus
% p.kb.respKeys{2} --> classify as vertical oval; report central stimulus more visible than peripheral stimulus
% p.kb.respKeys{3} --> classify as horizontal oval; report central stimulus more visible than peripheral stimulus
% p.kb.respKeys{4} --> classify as horizontal oval; report peripheral stimulus more visible than central stimulus
% 
% p.kb.exitKey --> immediately exits the block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p.kb.exitKey = 'ESCAPE';

p.kb.respKeys    = {'1!' '2@' '9(' '0)' p.kb.exitKey};
p.kb.allowedKeys = p.kb.respKeys;

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

p.stim.periph.lineLength_inPix_list    = degrees2pixels(p.stim.periph.lineLength_inDeg_list, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

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

lineLength_inPix_max_periph = degrees2pixels(3, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);

% enforce min length in pix for periph
f = p.stim.periph.lineLength_inPix_list < lineLength_inPix_min;
p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_min;

% enforce max length in pix for periph
f = p.stim.periph.lineLength_inPix_list > lineLength_inPix_max_periph;
p.stim.periph.lineLength_inPix_list(f) = lineLength_inPix_max_periph;


%% UNIT CONVERSION : pixels to degrees

p.stim.periph.lineWidth_inDeg = pixels2degrees(p.stim.periph.lineWidth_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);


%% UNIT CONVERSION : seconds to frames

if setup.skipFlipIntervalEstimation
    p.screen.refreshRate_inHz = Screen('FrameRate', w);
    p.screen.flipInterval     = 1/p.screen.refreshRate_inHz;
else
    p.screen.flipInterval     = Screen('GetFlipInterval', w, 100, 0.00005, 20);
    p.screen.refreshRate_inHz = round(1/p.screen.flipInterval);
end

p.timing.fixation1Dur_inFrames     = round( p.timing.fixation1Dur_inSecs / p.screen.flipInterval );
p.timing.fixation3Dur_inFrames     = round( p.timing.fixation3Dur_inSecs / p.screen.flipInterval );
p.timing.precueDur_inFrames        = round( p.timing.precueDur_inSecs / p.screen.flipInterval );
p.timing.prePeriphStimDur_inFrames = round( p.timing.prePeriphStimDur_inSecs / p.screen.flipInterval );
p.timing.periphStimDur_inFrames    = round( p.timing.periphStimDur_inSecs / p.screen.flipInterval );
p.timing.fixation4Dur_inFrames     = round( p.timing.fixation4Dur_inSecs / p.screen.flipInterval );
p.timing.postcueDur_inFrames       = round( p.timing.postcueDur_inSecs / p.screen.flipInterval );
p.timing.ITIDur_inFrames           = round( p.timing.ITIDur_inSecs / p.screen.flipInterval );

% actual timing of trial events is some integer multiple of the flip interval
p.timing.true_fixation1Dur_inSecs     = p.timing.fixation1Dur_inFrames * p.screen.flipInterval;
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

p.calibration.lineLength_inDeg_min        = pixels2degrees(p.calibration.lineLength_inPix_min, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
p.calibration.lineLength_inDeg_max_periph = 3; %p.stim.periph.ovalMinorAxis_inDeg;


% define calibration types
%%% purposely leaving in center stim types here to prevent breaking
%%% compatibility with older calibration code which is also used by
%%% twcf_cue_tex_det
p.calibration.typeNames = {'periphBG', 'periphFG_oval', 'periphFG_circle', 'centerBG_annulus', 'centerFG_circle', 'random'};
p.calibration.allCalibrated = 1;

for i_type = [1 2 3 6] % 1:length(p.calibration.typeNames)
    
    type = p.calibration.typeNames{i_type};
    info = getTypeInfo(type, p);
    
    clear nLines
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

        case 'periphFG_oval'
            p.calibration.periphFG_oval.lineLength_inPix_list = p.stim.periph.lineLength_inPix_list;
            
            for i_line = 1:length(p.stim.periph.lineLength_inPix_list)
                lineLength_inPix = p.stim.periph.lineLength_inPix_list(i_line);
                nLines(i_line) = nLines4pFilled(type, p.stim.pFilled, lineLength_inPix, info.lineWidth_inPix, info.lineRect, info.innerRect);
                eval(['p.calibration.' type '.nLines(i_line) = nLines(i_line);'])
            end
            
            % perform calibration for random texture using line length set
            % from thresholding, if this hasn't been done already
            if any(isnan(nLines))
                makePlot = 1; savePlot = 1; saveFit = 1; showLines = 0;
                
                clear nLines
                for i_line = 1:length(p.stim.periph.lineLength_inPix_list)
                    lineLength_inPix = p.stim.periph.lineLength_inPix_list(i_line);
                    fit = pfilled_calibration(w, p, type, lineLength_inPix, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);
                    nLines(i_line) = nLines4pFilled(type, p.stim.pFilled, lineLength_inPix, info.lineWidth_inPix, info.lineRect, info.innerRect);
                    eval(['p.calibration.' type '.nLines(i_line) = nLines(i_line);'])
                end
            end            
            
        otherwise
            
            eval(['p.calibration.' type '.lineLength_inPix_list = info.lineLength_inPix_list;'])
            
            for i_line = 1:length(info.lineLength_inPix_list)
                lineLength_inPix = info.lineLength_inPix_list(i_line);
                nLines(i_line) = nLines4pFilled(type, p.stim.pFilled, lineLength_inPix, info.lineWidth_inPix, info.lineRect, info.innerRect);
                eval(['p.calibration.' type '.nLines(i_line) = nLines(i_line);'])
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


%% QUEST parameters for the peripheral oval orientation task
%  here we threshold on the parameter k_ecc (eccentricity scalar) to find
%  the eccentricity of the peripheral ovals yielding 75% correct in the
%  orientation discrimination task for intermediate line length under
%  neutral cue

% threshold
p.quest_ecc.pThreshold = 0.75;      % target performance
p.quest_ecc.tGuess     = log10(.5); % initial guess ~ set w_ecc = 0.5
p.quest_ecc.tGuessSD   = 3;

% beta = psychometric function slope
p.quest_ecc.beta = 3.5; % 3.5 is the QUEST toolbox's suggested default

% delta = guess rate
p.quest_ecc.delta = 0.01; % 0.01 is the QUEST toolbox's suggested default

% gamma = chance rate
p.quest_ecc.gamma = 0.5;

% grain and range of x-values for psychometric function
p.quest_ecc.grain = 0.01;
p.quest_ecc.range = 5;