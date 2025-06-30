function [data, timing, gaze, exitNow] = expt_runTrial(w, p, b, data, timing, gaze, i_index, i_trial)

%% trial stages
% fixation1     - random texture w/ aperture and fixation cross
% fixation3     - random texture w/ aperture, fixation cross, and 4 inactive cues
% precue        - random texture w/ aperture, fixation cross, 3 inactive cues, and 1 active cue (or 4 active cues on neutral trials)
% prePeriphStim - random texture w/ aperture, fixation cross, and 4 inactive cues
% periphStim    - 4 peripheral FG/BG textures w/ aperture, fixation cross, and 4 inactive cues
% fixation4     - blank BG w/ fixation cross and 4 inactive cues
% postcue       - blank BG w/ fixation cross, 3 inactive cues, and 1 active cue

%%% these stages are excluded from the detection task for now
% preCenterStim - random texture only (no aperture)
% centerStim    - central FG/BG texture on random texture
% fixation2     - random texture w/ aperture and fixation cross


%% initialize

exitNow                 = 0;
data.RNGseed{i_trial}   = rng;
data.goodTrial(i_trial) = 0; % updated to 1 at the end of this function if appropriate

%% save index and stimulus data
%  to avoid confusion between i_trial (the current trial # being displayed
%  to the subject) and i_index (the current index to counterbalanced trial
%  structure stored in the b struct), all instances of i_index being used 
%  to index the "b" struct are handled in this block of code, and afterwards 
%  only i_trial is used to index the "data" struct

%%% save indeces
data.i_index(i_trial) = i_index;
data.i_trial(i_trial) = i_trial;
data.i_block(i_trial) = b.i_block(i_index);

%%% save pre-determined trial / stimulus information
% 4 x N variables
data.angleBG_all(:, i_trial)       = b.angleBG_all(:, i_index);
data.angleFG_all(:, i_trial)       = b.angleFG_all(:, i_index);
data.stimID_all(:, i_trial)        = b.stimID_all(:, i_index);
data.lineLengthID_all(:, i_trial)  = b.lineLengthID_all(:, i_index);
% data.lineLength_inDeg_all        - determined below
% data.lineLength_inPix_all        - determined below

% 1 x N variables
data.precueLoc(i_trial)            = b.precueLoc(i_index);
data.postcueLoc(i_trial)           = b.postcueLoc(i_index);
data.cueValidity(i_trial)          = b.cueValidity(i_index);
data.stimID_postcue(i_trial)       = b.stimID_postcue(i_index);
data.lineLengthID_postcue(i_trial) = b.lineLengthID_postcue(i_index);
% data.lineLength_inDeg_postcue    - determined below
% data.lineLength_inPix_postcue    - determined below

if p.setup.isThresholding
    data.qID(i_trial) = b.qID(i_index);    
end

%on BU's side, send a message to the eyelink timestamping 
% trial start and trial id.
if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
    Eyelink('Message', 'TRIALID %d', i_trial);
    Eyelink('Message', 'SYNCTIME');		% zero-plot time for EDFVIEW
end


%% MAKE random texture
%  this must be done prior to fixation 1

t0 = GetSecs;

s = p.stim.rand;
tex_stim_rand = expt_makeStimTexRand(w, p, s);

% save time needed to create stim
timing.randTexCreationTime(i_trial) = GetSecs - t0;


%% MAKE center and periph textures

t0 = GetSecs;

% % %%% make center stim texture
% % s = p.stim.center;
% % 
% % % get unique properties for the center stim on this trial
% % s.angle_BG        = data.angle_BG_center(i_trial);
% % s.angle_FG        = data.angle_FG_center(i_trial);
% % 
% % tex_stim_center   = twcf_makeStimTexCenter(w, p, s);


%%% make peripheral stim textures

% get general properties for peripheral stim
s = p.stim.periph;

% get unique properties for peripheral stim on this trial
s.angleBG_all = data.angleBG_all(:, i_trial);
s.angleFG_all = data.angleFG_all(:, i_trial);
s.stimID_all  = data.stimID_all(:, i_trial);

if p.setup.isThresholding
    
    % get current QUEST estimate of line length
    lineLength_inDeg = 10.^QuestMean( data.q( data.qID(i_trial) ) );
    lineLength_inPix = degrees2pixels(lineLength_inDeg, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
    
    % ensure line length is a whole number within min and max bounds
    lineLength_inPix = round(lineLength_inPix);
    if lineLength_inPix < p.calibration.lineLength_inPix_min
        lineLength_inPix = p.calibration.lineLength_inPix_min;
    elseif lineLength_inPix > p.calibration.lineLength_inPix_max_periph
        lineLength_inPix = p.calibration.lineLength_inPix_max_periph;
    end
    
    % compute line length in degrees corresponding to processed length in pixels
    lineLength_inDeg = pixels2degrees(lineLength_inPix, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
    
    % save line length values derived from QUEST
    data.lineLength_inDeg_postcue(i_trial) = lineLength_inDeg;
    data.lineLength_inPix_postcue(i_trial) = lineLength_inPix;

    % assign line lengths to each quadrant randomly selected from the priors list
    ind = randperm( length(p.stim.periph.lineLengthPrior_inDeg_list), 4 );
    data.lineLengthID_all(:, i_trial)     = ind';
    data.lineLength_inDeg_all(:, i_trial) = p.stim.periph.lineLengthPrior_inDeg_list(ind);
    data.lineLength_inPix_all(:, i_trial) = p.stim.periph.lineLengthPrior_inPix_list(ind);

    % assign the QUEST-derived line length to the postcued quadrant
    data.lineLengthID_all(data.postcueLoc(i_trial), i_trial)     = NaN;    
    data.lineLength_inDeg_all(data.postcueLoc(i_trial), i_trial) = lineLength_inDeg;
    data.lineLength_inPix_all(data.postcueLoc(i_trial), i_trial) = lineLength_inPix;
    
    s.lineLength_inPix_all = data.lineLength_inPix_all(:, i_trial);
    
else
    s.lineLength_inPix_all = s.lineLength_inPix_list( data.lineLengthID_all(:, i_trial) );
    s.lineLengthID_all     = data.lineLengthID_all(:, i_trial);
    
    % save line length values
    ind = data.lineLengthID_all(:, i_trial);
    data.lineLength_inDeg_all(:, i_trial)  = p.stim.periph.lineLength_inDeg_list(ind);
    data.lineLength_inPix_all(:, i_trial)  = p.stim.periph.lineLength_inPix_list(ind);
    
    data.lineLength_inDeg_postcue(i_trial) = data.lineLength_inDeg_all( data.postcueLoc(i_trial), i_trial );
    data.lineLength_inPix_postcue(i_trial) = data.lineLength_inPix_all( data.postcueLoc(i_trial), i_trial );
    
end

% create the stim
tex_stim_periph = expt_makeStimTexPeriph(w, p, s);

% save time needed to create stim
timing.stimCreationTime(i_trial) = GetSecs - t0;


%% PRESENT fixation1 
%  random texture w/ aperture and fixation cross

% since screen flips can't be controlled in a frame loop in the initial
% blank period due to stim creation, calculate the timestamp for when the
% cue screen flip should occur
if i_trial == 1
    flipTime = 0;
else
    flipTime = timing.keypress(i_trial-1) + p.timing.true_ITIDur_inSecs;
end

tex_cue_active   = p.tex.cue_active;
tex_cue_inactive = p.tex.cue_inactive;

% draw random texture
Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);

% draw aperture and fixation cross
Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

% flip
[timing.fixation1.VBL(i_trial), timing.fixation1.onset(i_trial), timing.fixation1.flip(i_trial), ...
    timing.fixation1.missed(i_trial), timing.fixation1.beampos(i_trial)] = Screen('Flip', w, flipTime);

% on BU's side, send a message to the eyelink timestamping this moment in the trial. 
if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
    Eyelink('Message','fix1')
end

%% ACQUIRE FIXATION

if p.eyetracker.doEyetracking
    exitNow = eyetracker_preTrialFixation(w, p, tex_stim_rand);
    if exitNow, return; end
end


%% PRESENT pre-center stimulus
% % % %  random texture only (no aperture)
% % % 
% % % % since screen flips can't be controlled in a frame loop in the initial
% % % % blank period due to stim creation, calculate the timestamp for when the
% % % % cue screen flip should occur
% % % flipTime = timing.fixation1.VBL(i_trial) + p.timing.fixation1Dur_inSecs;
% % % 
% % % for f = 1:p.timing.preCenterStimDur_inFrames
% % % 
% % %     % draw random texture
% % %     Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
% % %     
% % %     % flip
% % %     if f==1
% % %         [timing.preCenterStim.VBL(i_trial), timing.preCenterStim.onset(i_trial), timing.preCenterStim.flip(i_trial), ...
% % %             timing.preCenterStim.missed(i_trial), timing.preCenterStim.beampos(i_trial)] = Screen('Flip', w, flipTime);
% % %     else
% % %         Screen('Flip', w);
% % %     end    
% % % end


%% PRESENT center stimulus
% % % %  central FG/BG texture on random texture
% % % 
% % % for f = 1:p.timing.centerStimDur_inFrames
% % %     
% % %     % draw random texture
% % %     Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
% % %     
% % %     % draw center stimulus
% % %     Screen('DrawTexture', w, tex_stim_center.bg, [], p.rects.centerBG);  
% % %     Screen('DrawTexture', w, tex_stim_center.fg, [], p.rects.centerFG);
% % %              
% % %     % flip
% % %     if f==1
% % %         [timing.centerStim.VBL(i_trial), timing.centerStim.onset(i_trial), timing.centerStim.flip(i_trial), ...
% % %             timing.centerStim.missed(i_trial), timing.centerStim.beampos(i_trial)] = Screen('Flip', w);
% % %     else
% % %         Screen('Flip', w);
% % %     end
% % % end


%% PRESENT fixation2
% % % %  random texture w/ aperture and fixation cross
% % % 
% % % for f = 1:p.timing.fixation2Dur_inFrames
% % % 
% % %     % draw random texture
% % %     Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
% % % 
% % %     % draw aperture and fixation cross
% % %     Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
% % %     Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
% % % 
% % %     % flip
% % %     if f==1
% % %         [timing.fixation2.VBL(i_trial), timing.fixation2.onset(i_trial), timing.fixation2.flip(i_trial), ...
% % %             timing.fixation2.missed(i_trial), timing.fixation2.beampos(i_trial)] = Screen('Flip', w);
% % %     else
% % %         Screen('Flip', w);
% % %     end
% % % end


%% PRESENT fixation3
%  random texture w/ aperture, fixation cross, and 4 inactive cues

% since screen flips can't be controlled in a frame loop in the initial
% blank period due to stim creation, calculate the timestamp for when the
% cue screen flip should occur
flipTime = timing.fixation1.VBL(i_trial) + p.timing.fixation1Dur_inSecs;


for f = 1:p.timing.fixation3Dur_inFrames

    % draw random texture
    Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);

    % draw aperture and fixation cross
    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    
    % draw 4 inactive cues
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end    

    % flip
    if f==1
        [timing.fixation3.VBL(i_trial), timing.fixation3.onset(i_trial), timing.fixation3.flip(i_trial), ...
            timing.fixation3.missed(i_trial), timing.fixation3.beampos(i_trial)] = Screen('Flip', w, flipTime);

        %on BU's side, send a message to the eyelink timestamping this moment in the trial.
        if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
            Eyelink('Message','fix3')

        end
    else
        Screen('Flip', w);
    end
    
    % confirm gaze in fixation region
    if p.eyetracker.doEyetracking
        gaze = eyetracker_checkFixation(w, p, gaze, 'fixation3', f, i_trial);
        
        % exit this trial immediately if fixation is bad
        if gaze.anyBadFixations(i_trial), data.goodFixation(i_trial) = 0; return; end
    end
end

if p.setup.takeScreenshot
    expt_takeScreenshot(w, 'rand');
end


%% PRESENT precue
%  random texture w/ aperture, fixation cross, 3 inactive cues, and 1 active cue (or 4 active cues on neutral trials)

for f = 1:p.timing.precueDur_inFrames
    
    % draw random texture
    Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
    
    % draw aperture and fixation cross
    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    
    % draw 4 inactive cues
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end

    % draw active cues
    if data.precueLoc(i_trial) > 0
        
        % single active cue
        Screen('DrawTexture', w, tex_cue_active, [], p.rects.cueRect(:, data.precueLoc(i_trial)), rad2deg(p.rects.angleList_inRadians(data.precueLoc(i_trial)))+90);
    else
        
        % all active cues (neutral condition)
        for i_loc = 1:4
            Screen('DrawTexture', w, tex_cue_active, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
        end        
    end
    
    % flip
    if f==1
        [timing.precue.VBL(i_trial), timing.precue.onset(i_trial), timing.precue.flip(i_trial), ...
            timing.precue.missed(i_trial), timing.precue.beampos(i_trial)] = Screen('Flip', w);

        %on BU's side, send a message to the eyelink timestamping this moment in the trial.
        if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
            Eyelink('Message','precue')
        end

    else
        Screen('Flip', w);
    end
    


    % confirm gaze in fixation region
    if p.eyetracker.doEyetracking
        gaze = eyetracker_checkFixation(w, p, gaze, 'precue', f, i_trial);
        
        % exit this trial immediately if fixation is bad
        if gaze.anyBadFixations(i_trial), data.goodFixation(i_trial) = 0; return; end
    end
end

if p.setup.takeScreenshot
    expt_takeScreenshot(w, 'precue');
end

%% PRESENT pre-peripheral stimulus
%  random texture w/ aperture, fixation cross, and 4 inactive cues

for f = 1:p.timing.prePeriphStimDur_inFrames
    
    % draw random texture
    Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
    
    % draw aperture and fixation cross
    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    
    % draw 4 inactive cues
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end

    % flip
    if f==1
        [timing.prePeriphStim.VBL(i_trial), timing.prePeriphStim.onset(i_trial), timing.prePeriphStim.flip(i_trial), ...
            timing.prePeriphStim.missed(i_trial), timing.prePeriphStim.beampos(i_trial)] = Screen('Flip', w);

        %on BU's side, send a message to the eyelink timestamping this moment in the trial.
        if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
            Eyelink('Message','prePeriphStim')
        end

    else
        Screen('Flip', w);
    end

    % confirm gaze in fixation region
    if p.eyetracker.doEyetracking
        gaze = eyetracker_checkFixation(w, p, gaze, 'prePeriphStim', f, i_trial);
        
        % exit this trial immediately if fixation is bad
        if gaze.anyBadFixations(i_trial), data.goodFixation(i_trial) = 0; return; end
    end
end


%% PRESENT peripheral stimuli
%  4 peripheral FG/BG textures w/ aperture, fixation cross, and 4 inactive cues

for f = 1:p.timing.periphStimDur_inFrames

    % draw peripheral stimuli
    for i_periph = 1:4
        
        % BG
        Screen('DrawTexture', w, tex_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
        
        % FG
        if data.stimID_all(i_periph, i_trial) > 0
            Screen('DrawTexture', w, tex_stim_periph(i_periph).fg, [], p.rects.periphFG{ s.stimID_all(i_periph) }(:,i_periph));
        end
        
    end
    
    % draw aperture and fixation cross
    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    
    % draw 4 inactive cues
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end
    
    % flip
    if f==1
        [timing.periphStim.VBL(i_trial), timing.periphStim.onset(i_trial), timing.periphStim.flip(i_trial), ...
            timing.periphStim.missed(i_trial), timing.periphStim.beampos(i_trial)] = Screen('Flip', w);

        %on BU's side, send a message to the eyelink timestamping this moment in the trial.
        if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
            Eyelink('Message','periphStim')
        end

    else
        Screen('Flip', w);
    end

    % confirm gaze in fixation region
    if p.eyetracker.doEyetracking
        gaze = eyetracker_checkFixation(w, p, gaze, 'periphStim', f, i_trial);
        
        % exit this trial immediately if fixation is bad
        if gaze.anyBadFixations(i_trial), data.goodFixation(i_trial) = 0; return; end
    end
end

if p.setup.takeScreenshot
    expt_takeScreenshot(w, 'periph');
end


%% PRESENT fixation4
%  blank BG w/ fixation cross and 4 inactive cues

for f = 1:p.timing.fixation4Dur_inFrames
    
    % draw fixation cross
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    
    % draw 4 inactive cues
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end

    % flip
    if f==1
        [timing.fixation4.VBL(i_trial), timing.fixation4.onset(i_trial), timing.fixation4.flip(i_trial), ...
            timing.fixation4.missed(i_trial), timing.fixation4.beampos(i_trial)] = Screen('Flip', w);

        %on BU's side, send a message to the eyelink timestamping this moment in the trial.
        if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
            Eyelink('Message','fix4')
        end

    else
        Screen('Flip', w);
    end

    % confirm gaze in fixation region
    if p.eyetracker.doEyetracking
        gaze = eyetracker_checkFixation(w, p, gaze, 'fixation4', f, i_trial);
        
        % exit this trial immediately if fixation is bad
        if gaze.anyBadFixations(i_trial), data.goodFixation(i_trial) = 0; return; end
    end
end


%% all gaze fixation checks passed!

if p.eyetracker.doEyetracking
    data.goodFixation(i_trial) = 1;
end


%% PRESENT postcue
%  blank BG w/ fixation cross, 3 inactive cues, and 1 active cue

% draw fixation cross
Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

% draw 4 inactive cues
for i_loc = 1:4
    Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
end

% draw 1 active cue
Screen('DrawTexture', w, tex_cue_active, [], p.rects.cueRect(:, data.postcueLoc(i_trial)), rad2deg(p.rects.angleList_inRadians(data.postcueLoc(i_trial)))+90);    

[timing.postcue.VBL(i_trial), timing.postcue.onset(i_trial), timing.postcue.flip(i_trial), ...
    timing.postcue.missed(i_trial), timing.postcue.beampos(i_trial)] = Screen('Flip', w);

%on BU's side, send a message to the eyelink timestamping this moment in the trial. 
if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
    Eyelink('Message','postcue')
end


%% collect and process keyboard input

% listen for keyboard input
try
    [respKey, data.RT(i_trial), timing.keypress(i_trial)] = ... 
        recordValidKeys(timing.postcue.onset(i_trial), p.timing.postcueDur_inSecs, p.kb.kbNum, p.kb.allowedKeys);
    
    % handle keypress timestamps when no keypress was successfully entered.
    % this is necessary b/c the onset of the following trial is timed
    % relative to timing.keypress(i_trial)
    if timing.keypress(i_trial) == 0
        data.RT(i_trial) = NaN;
        timing.keypress(i_trial) = GetSecs;
    end
    
    % check if respKey is valid input to a switch statement
    if ~isscalar(respKey) && ~ischar(respKey)
        respKey = 'error';
        data.RT(i_trial) = NaN;
        timing.keypress(i_trial) = GetSecs;
    end

catch
    respKey = 'error';
    data.RT(i_trial) = NaN;
    timing.keypress(i_trial) = GetSecs;
end


% sort out response
switch respKey
    
    % valid responses
    case p.kb.allowedKeys(1),   data.respDis(i_trial) = 1;   data.respDet(i_trial) = 1;   data.ratingDis(i_trial) = 1;  data.resp(i_trial) = 1;
    case p.kb.allowedKeys(2),   data.respDis(i_trial) = 1;   data.respDet(i_trial) = 1;   data.ratingDis(i_trial) = 0;  data.resp(i_trial) = 2;
    case p.kb.allowedKeys(3),   data.respDis(i_trial) = 1;   data.respDet(i_trial) = 0;   data.ratingDis(i_trial) = 0;  data.resp(i_trial) = 3;
    case p.kb.allowedKeys(4),   data.respDis(i_trial) = 2;   data.respDet(i_trial) = 0;   data.ratingDis(i_trial) = 0;  data.resp(i_trial) = 4;
    case p.kb.allowedKeys(5),   data.respDis(i_trial) = 2;   data.respDet(i_trial) = 1;   data.ratingDis(i_trial) = 0;  data.resp(i_trial) = 5;
    case p.kb.allowedKeys(6),   data.respDis(i_trial) = 2;   data.respDet(i_trial) = 1;   data.ratingDis(i_trial) = 1;  data.resp(i_trial) = 6;
    
    % invalid responses / errors / etc
    case 'noanswer',            data.resp(i_trial) = -1;
    case 'invalid',             data.resp(i_trial) = -2;
    case 'cell',                data.resp(i_trial) = -3;
    case p.kb.exitKey,          data.resp(i_trial) = -4;   exitNow = 1;
    otherwise,                  data.resp(i_trial) = -5;
end

data.validKeypress(i_trial) = data.resp(i_trial) > 0;

if exitNow, return; end

 
%% post-response processing

% flash crosshair color change after response is entered
if data.validKeypress(i_trial)
    Screen('FillRect', w, p.stim.fixationColor{2}, p.rects.fixation); % draw fixation cross
    for i_loc = 1:4
        Screen('DrawTexture', w, tex_cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
    end
    
    Screen('Flip', w);

    % on BU's side, send a message to the eyelink timestamping this moment in the trial. 
    if p.eyetracker.doEyetracking && strcmp(p.setup.site,'BU')
        Eyelink('Message','response')
    end
end


% determine accuracy for discrimination task
if ~data.validKeypress(i_trial)
    % no keyboard input
    data.correctDis(i_trial) = -2;
    
elseif data.stimID_postcue(i_trial) == 0
    % no accuracy measure for orientation discrim when stim is absent
    data.correctDis(i_trial) = -1;
    
else
    data.correctDis(i_trial) = data.respDis(i_trial) == data.stimID_postcue(i_trial);
end


% determine accuracy for detection task
if ~data.validKeypress(i_trial)
    % no keyboard input
    data.correctDet(i_trial) = -2;
    
else
    stimPresent = double( data.stimID_postcue(i_trial) > 0 );
    data.correctDet(i_trial) = data.respDet(i_trial) == stimPresent;
    
end

% update QUEST if a valid response was entered on a stimulus present trial
if p.setup.isThresholding && (data.correctDis(i_trial) >= 0)
    data.q( data.qID(i_trial) ) = QuestUpdate( data.q( data.qID(i_trial) ), log10(data.lineLength_inDeg_postcue(i_trial)), data.correctDis(i_trial) );
end

%% print trial results to matlab prompt

switch data.correctDis(i_trial)
    case -1,   disText = 'n/a';
    case -2,   disText = 'missing keypress';
    otherwise, disText = num2str(data.correctDis(i_trial));
end

switch data.correctDet(i_trial)
    case -2,   detText = 'missing keypress';
    otherwise, detText = num2str(data.correctDet(i_trial));
end

disp(['* block # ' num2str(data.i_block(i_trial)) ', trial #' num2str(i_trial)])
disp(['detection accuracy = ' detText]);
disp(['discrimination accuracy = ' disText]);
disp(['discrimination rating = ' num2str(data.ratingDis(i_trial))]);
disp(' ');


%% feedback

if b.practiceStage == 2
    
    % show text feedback
    stimText = upper( {'no figure', 'vertical oval', 'horizontal oval'} );
    respText = upper( {'vertical oval - saw shape', 'vertical oval - saw a figure but not its shape', 'vertical oval - didn''t see a figure' ... 
                       'horizontal oval - didn''t see a figure', 'horizontal oval - saw a figure but not its shape', 'horizontal oval - saw shape'} );
    fbText   = ['At the cued location, the stimulus was: ' stimText{ data.stimID_postcue(i_trial)+1 } '\n\n' ...
                'Your response was: ' respText{ data.resp(i_trial) } '\n\n' ...
                'Press any key to continue.'];
    
    WaitSecs(1);

    DrawFormattedText(w, fbText, 'center', 'center'); 
    Screen('Flip', w);
    
    % keep on screen til key press
    WaitSecs(0.5);
    KbWait(p.kb.kbNum);
    
    % check for exit key
    [k, secs, key] = KbCheck(p.kb.kbNum);
    if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; end
    
elseif b.auditoryFB 
    
    % for trials where an oval was present, provide veridical auditory FB
    % about the orientation response
    if data.stimID_postcue(i_trial) > 0
        if data.correctDis(i_trial) == 1
            Snd('Play', p.auditoryFB.tones(2, :));
            data.feedback(i_trial) = 1;
        else
            Snd('Play', p.auditoryFB.tones(1, :));
            data.feedback(i_trial) = 0;            
        end
        
    % for trials where no oval was presented, provide random auditory FB 
    % with 75% chance "correct" FB and 25% chance "incorrect"    
    else
        if rand > 0.25
            Snd('Play', p.auditoryFB.tones(2, :));
            data.feedback(i_trial) = 1;
        else
            Snd('Play', p.auditoryFB.tones(1, :));
            data.feedback(i_trial) = 0;
        end
    end
end


%% if we made it this far and the keypress was valid, then this was a good trial

data.goodTrial(i_trial) = data.validKeypress(i_trial);

%% close textures

Screen('Close', tex_stim_rand.bg);
for i = 1:4
    Screen('Close', tex_stim_periph(i).bg);
    
    if ~isempty(tex_stim_periph(i).fg)
        Screen('Close', tex_stim_periph(i).fg);
    end
end
