function fixationAcquired = eyetracker_acquireFixation(w, p, settings, tex_stim_rand)
% fixationAcquired = eyetracker_acquireFixation(w, p, settings, tex_stim_rand)
%
% Acquire fixation, i.e. check that fixation remains within a prescribed
% region of the screen for a prescribed period of time, before resuming.
%
% INPUTS
% ------
% w - psychtoolbox window
% p - parameter struct
% settings - a struct containing settings for fixation duration, radius,
% and timeout duration. can be either p.eyetracker.trial (for pre-trial
% settings) or p.eyetracker.block (for pre-block settings)
% tex_stim_rand - random stimulus texture to be drawn in BG for
% within-trial usage
%
% OUTPUT
% ------
% fixationAcquired - 1 if good fixation for the prescribed time period was
% acquired, 0 otherwise

%% initialize

% during experimental trials, the random texture is drawn in the BG while
% fixation is acquired. but in breaks between blocks, no texture is shown
% during fixation acquisition
if ~exist('tex_stim_rand','var') || isempty(tex_stim_rand)
    drawRandTex = 0;
else
    drawRandTex = 1;
end

gazeCol = {[255 0 0], [0 255 0]};

% draw random texture and aperture if specified
if drawRandTex
    Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
end

% draw fixation cross and flip
Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
Screen('Flip', w);

%% stay in loop until fixation is acquired

fixationAcquired = 0;
timeout          = 0;

T0 = GetSecs; % time started checked for fixation
t0 = T0;      % time since last good fixation
while ~fixationAcquired && ~timeout

    % get current gaze location in PTB pixel coordinates
    gazeLoc_inPix = eyetracker_getGazeLoc(w, p);

    % compute distance of gaze from center of screen
    gazeDist_inPix = sqrt( (gazeLoc_inPix(1) - p.rects.midW)^2 + (gazeLoc_inPix(2) - p.rects.midH)^2 );

    % check if gaze is in the fixation region
    gazeInFix = gazeDist_inPix < settings.fixationRadius_inPix;

    % reset timer if gaze is outside of fixation region
    if ~gazeInFix, t0 = GetSecs; end

    % check for fixation acquisition and timeout
    t = GetSecs;
    if (t - t0) >= settings.fixationDur_inSecs
        fixationAcquired = 1;
    end

    if (t - T0) >= settings.timeoutDur_inSecs
        timeout = 1;
    end    
    
    % optionally draw current gaze location
    if p.eyetracker.drawGazeLoc
        gazeRect = CenterRectOnPoint( p.rects.gaze, gazeLoc_inPix(1), gazeLoc_inPix(2));

        % draw random texture and aperture if specified
        if drawRandTex
            Screen('DrawTexture', w, tex_stim_rand.bg, [], p.rects.window);
            Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
        end

        % draw fixation cross and gaze location
        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
        Screen('FillOval', w, gazeCol{gazeInFix+1}, gazeRect);
        Screen('Flip', w);
    end        
end