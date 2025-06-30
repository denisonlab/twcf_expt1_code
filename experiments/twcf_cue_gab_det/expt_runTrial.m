function [data, timing, gaze, exitNow] = expt_runTrial(w, p, b, data, timing, gaze, i_index, i_trial)

%% trial stages
% fixation1     - random pedestal and fixation cross
% fixation3     - random pedestal, fixation cross, and 4 inactive cues
% precue        - random pedestal, fixation cross, 3 inactive cues, and 1 active cue (or 4 active cues on neutral trials)
% prePeriphStim - random pedestal, fixation cross, and 4 inactive cues
% periphStim    - 4 peripheral gabors, fixation cross, and 4 inactive cues
% fixation4     - blank BG w/ fixation cross and 4 inactive cues
% postcue       - blank BG w/ fixation cross, 3 inactive cues, and 1 active cue

%%% these stages are excluded from the detection task for now
% preCenterStim - random pedestal only (no aperture)
% centerStim    - central FG/BG texture on random texture
% fixation2     - random texture w/ aperture and fixation cross

%% initialize

exitNow                     = 0;
data.RNGseed{i_trial}       = rng; 
data.goodTrial(i_trial)     = 0; % updated to 1 at the end of this function if appropriate

helpText = 0; % display debugging text displaying expt stage, and saves screenshot of periph stim 

prestimNoise = logical(data.prestimNoise);

%% save index and stimulus data
%  to avoid confusion between i_trial (the current trial # being displayed
%  to the subject) and i_index (the current index to counterbalanced trial
%  structure stored in the b struct), all instances of i_index being used 
%  to index the "b" struct are handled in this block of code, and afterwards 
%  only i_trial is used to index the "data" struct

%%% save indices
data.i_index(i_trial) = i_index;
data.i_trial(i_trial) = i_trial;
data.i_block(i_trial) = b.i_block(i_index);

%%% save pre-determined trial / stimulus information
% 4 x N variables
% data.angleBG_all(:, i_trial)       = b.angleBG_all(:, i_index);
% data.angleFG_all(:, i_trial)       = b.angleFG_all(:, i_index);
data.stimID_all(:, i_trial)         = b.stimID_all(:, i_index);
data.contrastID_all(:, i_trial)     = b.contrastID_all(:, i_index); 
% data.lineLengthID_all(:, i_trial)  = b.lineLengthID_all(:, i_index);
% data.lineLength_inDeg_all        - determined below
% data.lineLength_inPix_all        - determined below

% 1 x N variables
data.precueLoc(i_trial)             = b.precueLoc(i_index);
data.postcueLoc(i_trial)            = b.postcueLoc(i_index);
data.cueValidity(i_trial)           = b.cueValidity(i_index);
data.stimID_postcue(i_trial)        = b.stimID_postcue(i_index);
data.contrastID_postcue(:, i_trial) = b.contrastID_postcue(:, i_index);  
% data.lineLengthID_postcue(i_trial) = b.lineLengthID_postcue(i_index);
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

% t0 = GetSecs; 

%s = p.stim.rand;
% s = [];
% gab_stim_rand = expt_makeStimGabRand(w, p, s);

% save time needed to create stim
% timing.randTexCreationTime(i_trial) = GetSecs - t0;


%% MAKE center and periph textures

t0 = GetSecs;

% % %%% make center stim texture
% % s = p.stim.center;
% % 
% % % get unique properties for the center stim on this trial
% % s.angle_BG        = data.angle_BG_center(i_trial);
% % s.angle_FG        = data.angle_FG_center(i_trial);
% % tex_stim_center   = twcf_makeStimTexCenter(w, p, s);

%%% make peripheral stim textures

% get general properties for peripheral stim
s = p.stim;

% get unique properties for peripheral stim on this trial
% s.angleBG_all = data.angleBG_all(:, i_trial);
% s.angleFG_all = data.angleFG_all(:, i_trial);
s.stimID_all  = data.stimID_all(:, i_trial);

if p.setup.isThresholding

    % get current QUEST estimate of contrast 
    contrast = 10.^QuestMean( data.q (data.qID(i_trial) ) ); 

    % if current QUEST estimate of contrast greater than max possible
    % contrast, set to max
    if contrast > 1 - p.stim.gab.noiseContrast
        contrast = 1 - p.stim.gab.noiseContrast;
    elseif contrast < p.screen.contrastRes % 0.0078 
        contrast = p.screen.contrastRes; 
    end
    
    % save contrast derived from QUEST
    data.contrast_postcue(i_trial) = contrast;
    
    % assign contrasts to each quadrant randomly selected from the priors list
    ind = randperm( length(p.stim.gab.contrastPrior_list), 4 );
    data.contrastID_all(:, i_trial) = ind'; 
    data.contrast_all(:, i_trial)   = p.stim.gab.contrastPrior_list(ind);
    
    % assign the QUEST-derived contrast to the postcued quadrant
    data.contrastID_all(data.postcueLoc(i_trial), i_trial)    = NaN;   
    data.contrast_all(data.postcueLoc(i_trial), i_trial)      = contrast;  
    
    s.contrast_all = data.contrast_all(:, i_trial);

elseif p.setup.isPiloting
%     s.contrast_all   = s.stim.gab.contrast_list( data.contrastID_all(:, i_trial) );

    % assign contrasts to each quadrant randomly selected from the priors list
    ind = randperm( length(p.stim.gab.contrastPrior_list), 4 );
    data.contrastID_all(:, i_trial) = ind'; 
    data.contrast_all(:, i_trial)   = p.stim.gab.contrastPrior_list(ind);

    % assign contrast to postcued quadrant
    % data.contrastID_all(data.postcueLoc(i_trial), i_trial)    = data.contrastID_postcue(i_trial);   
    data.contrast_all(data.postcueLoc(i_trial), i_trial)      = p.stim.gab.contrast_list( data.contrastID_postcue(i_trial) );  

    % save contrast values 
%     ind = data.contrastID_all(:, i_trial); 
%     data.contrast_all(:, i_trial)     = p.stim.gab.contrast_list(ind);
    data.contrastID_postcue(i_trial)  = data.contrastID_all( data.postcueLoc(i_trial), i_trial );
    data.contrast_postcue(i_trial)    = data.contrast_all( data.postcueLoc(i_trial), i_trial );
    
    % save to s structure 
    s.contrast_all = data.contrast_all(:, i_trial);
    s.contrastID_all = data.contrastID_all(:, i_trial);

else % main, practice 
    s.contrast_all   = s.gab.contrast_list( data.contrastID_all(:, i_trial) );
    s.contrastID_all = data.contrastID_all(:, i_trial);

    % save contrast values 
    ind = data.contrastID_all(:, i_trial); 
    data.contrast_all(:, i_trial)     = p.stim.gab.contrast_list(ind);

    data.contrast_postcue(i_trial)    = data.contrast_all( data.postcueLoc(i_trial), i_trial );

end

% CREATE STIM SCREENSHOTS (DELETE) 
% noiseContrasts = [0.08 0.2 0.5]; % Rahnev 2011, low, high 
% contrasts = [0 0.05 0.1 0.2 0.5]; 
% noiseTypes = {'filteredOriSF','uniform','filteredSF','highPassFilter'}; 
% for iNC = 1:numel(noiseContrasts) 
%     for iGC = 1:numel(contrasts) 
%         for iNT = 1:numel(noiseTypes) 
%             p.stim.gabor.noiseType = noiseTypes{iNT};
%             expt_makeStimGabPeriph_screenshot(w, p, s, noiseContrasts(iNC), contrasts(iGC))
%         end
%     end
% end

% create the stim (grating [.fg] and noise [.bg])
rng(data.RNGseed{i_trial})
[gab_stim_periph, numNoiseGenerated] = expt_makeStimGabPeriph(w, p, s);
% data.rng(i_trial).rngstate_prestim = rngstate_prestim; not saving because
% causing timing lag 
% data.rng(i_trial).rngstate_stim = rngstate_stim; 
data.rng(i_trial).numNoiseGenerated = numNoiseGenerated; 

% save time needed to create stim
timing.stimCreationTime(i_trial) = GetSecs - t0;


%% PRESENT fixation1 
%  random noise pedestal w/ aperture and fixation cross

% since screen flips can't be controlled in a frame loop in the initial
% blank period due to stim creation, calculate the timestamp for when the
% cue screen flip should occur
if i_trial == 1
    flipTime = 0;
else
    % if this is the first trial of a new pass (i.e. first trial of a
    % resumed data set), then flip ASAP...
    if data.passCurrent > data.pass(i_trial-1)
        flipTime = 0;

        % ...otherwise, flip after (ITI) secs have passed following previous
        % keypress
    else
        flipTime = timing.keypress(i_trial-1) + p.timing.true_ITIDur_inSecs;
    end
end

tex_cue_active   = p.tex.cue_active;
tex_cue_inactive = p.tex.cue_inactive;

% ---
if helpText
    text = 'fix1';
    DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
end
% --- 

if prestimNoise
    % draw random noise
    for i_periph = 1:4
        Screen('DrawTexture', w, gab_stim_periph(i_periph).bg, [], p.rects.periphFG{2}(:,i_periph));
    end
end

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
    if ~prestimNoise
        gab_stim_rand = []; 
    else 
        error('eyetracker not defined to use with prestim noise')
    end
    exitNow = eyetracker_preTrialFixation(w, p, gab_stim_rand); % edit out gab_stim_rand
    if exitNow, return; end
end


%% PRESENT fixation2
% % % %  random texture w/ aperture and fixation cross
% % % 
% % % for f = 1:p.timing.fixation2Dur_inFrames
% % % 
% % %     % draw random texture
% % %     Screen('DrawTexture', w, gab_stim_rand.bg, [], p.rects.window);
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
%  random pedestal w/ aperture, fixation cross, and 4 inactive cues

% since screen flips can't be controlled in a frame loop in the initial
% blank period due to stim creation, calculate the timestamp for when the
% cue screen flip should occur
flipTime = timing.fixation1.VBL(i_trial) + p.timing.fixation1Dur_inSecs;

for f = 1:p.timing.fixation3Dur_inFrames

    % ---
    if helpText
        text = 'fix3';
        DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
    end
    % ---
    
    if prestimNoise
        % draw random noise
        for i_periph = 1:4
            Screen('DrawTexture', w, gab_stim_periph(i_periph).bg, [], p.rects.periphFG{2}(:,i_periph));
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
    expt_takeScreenshot(w, 'prestimNoise');
end


%% PRESENT precue
%  random pedestal w/ aperture, fixation cross, 3 inactive cues, and 1 active cue (or 4 active cues on neutral trials)

for f = 1:p.timing.precueDur_inFrames

    % ---
    if helpText 
        text = 'precue';
        DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
    end
    % ---
    
    if prestimNoise
        % draw random noise
        for i_periph = 1:4
            Screen('DrawTexture', w, gab_stim_periph(i_periph).bg, [], p.rects.periphFG{2}(:,i_periph));
        end
    end
    
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

    if helpText
        text = 'pre-periph';
        DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
    end
    
    if prestimNoise
        % draw random noise
        for i_periph = 1:4
            Screen('DrawTexture', w, gab_stim_periph(i_periph).bg, [], p.rects.periphFG{2}(:,i_periph));
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
        % BG (noise) 
        % Screen('DrawTexture', w, gab_stim_periph(i_periph).bg, [], p.rects.periphFG{2}(:,i_periph));

        Screen('DrawTexture', w, gab_stim_periph(i_periph).fg, [], p.rects.periphFG{2}(:,i_periph));
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
    expt_takeScreenshot(w, 'grating');
end

if helpText
    text = 'periph stim';
    DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
        noiseIm = Screen('GetImage',w);
        noiseFilename = sprintf('%s/screenshot/screenshot_%d.png',cd, i_trial);
        imwrite(noiseIm,noiseFilename)
end

%% PRESENT fixation4
%  blank BG w/ fixation cross and 4 inactive cues

for f = 1:p.timing.fixation4Dur_inFrames

    if helpText
        text = 'fix4';
        DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
    end
    
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

if helpText
    text = 'postcue';
    DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
end

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

    if helpText
        text = 'post-response processing';
        DrawFormattedText(w, text, p.text.sx, p.text.sy, 0, p.text.wrapat);
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
    data.q( data.qID(i_trial) ) = QuestUpdate( data.q( data.qID(i_trial) ), log10(data.contrast_postcue(i_trial)), data.correctDis(i_trial) );
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
if p.setup.isThresholding && (data.correctDis(i_trial) >= 0)
    disp(['estimated threshold = ' num2str(contrast)]);
end
disp(' ');


%% feedback

if b.practiceStage == 2
    
    % show text feedback
    stimText = upper( {'no grating', 'counterclockwise (-45 deg)', 'clockwise (+45 deg)'} );
    respText = upper( {'counterclockwise (-45 deg) - saw orientation',...
        'counterclockwise (-45 deg) - saw a grating but not its shape',...
        'counterclockwise (-45 deg) - didn''t see a grating',... 
        'clockwise (+45 deg) - didn''t see a grating',...
        'clockwise (+45 deg)- saw a grating but not its orientation',...
        'clockwise (+45 deg)- saw orientation'} );
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
for i_loc = 1:4
    if ~isempty(gab_stim_periph(i_loc).bg)
        Screen('Close', gab_stim_periph(i_loc).bg);
    end
    if ~isempty(gab_stim_periph(i_loc).fg)
        Screen('Close', gab_stim_periph(i_loc).fg);
    end
end

