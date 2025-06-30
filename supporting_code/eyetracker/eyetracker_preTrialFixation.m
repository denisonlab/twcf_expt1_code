function exitNow = eyetracker_preTrialFixation(w, p, tex_stim_rand)
% function eyetracker_preTrialFixation(w, p, tex_stim_rand)

fixationAcquired = 0;
attemptNum       = 0;

sy = round(p.rects.window(4) / 4); % place text above fixation

fixtext{1} = ''; % no text prior to first attempt
fixtext{2} = 'It looks like you''re taking a break.\n\nPress any key when you''re ready to continue.'; % prior to second attempt
fixtext{3} = 'Eyetracking calibration may be bad. Please get the experimenter.'; % after two failed attempts


%% set up pre-block fixation acquisition

exitNow = 0;
while ~fixationAcquired

    % have up to 2 attempts at acquiring fixation
    if attemptNum < 2
        
        attemptNum = attemptNum + 1;

        % show text and keypress prompt
        DrawFormattedText(w, fixtext{attemptNum}, 'center', sy, 0);
        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
        Screen('Flip', w);

        % wait for keypress following text on attempt #2
        if attemptNum == 2
            KbWait(p.kb.kbNum);
            [k, secs, key] = KbCheck(p.kb.kbNum);
            if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end            
        end
        
        % check for fixation
        fixationAcquired = eyetracker_acquireFixation(w, p, p.eyetracker.trial, tex_stim_rand);
        
    % if first 2 attempts don't work, re-do calibration and try again
    else
        
        % show text and keypress prompt
        DrawFormattedText(w, fixtext{3}, 'center', sy, 0);
        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
        Screen('Flip', w);

        % wait for keypress
        if attemptNum == 2
            KbWait(p.kb.kbNum);
            [k, secs, key] = KbCheck(p.kb.kbNum);
            if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end            
        end
        
        % re-do calibration
        [p, exitNow] = eyetracker_calibrate(w, p);
        if exitNow, return, end
        
        % reset attemptNum to re-enter the acquireFixation loop
        attemptNum = 0;
    end
end
