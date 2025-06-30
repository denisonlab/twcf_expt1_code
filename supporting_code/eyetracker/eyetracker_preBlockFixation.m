function exitNow = eyetracker_preBlockFixation(w, p)
% function eyetracker_preBlockFixation(w, p)

fixationAcquired = 0;
attemptNum       = 0;

sy = round(p.rects.window(4) / 4); % place text above fixation

fixtext{1} = 'When you''re ready, fixate on the crosshair below and press any key to proceed.'; % prior to first attempt
fixtext{2} = 'Unable to acquire fixation! Let''s try again.\n\nWhen you''re ready, fixate on the crosshair below and press any key to proceed.'; % prior to second attempt
fixtext{3} = 'Unable to acquire fixation! Please get experimenter to help with eyetracker setup.'; % after two failed attempts


%% set up pre-block fixation acquisition

exitNow = 0;
while ~fixationAcquired

    % have up to 2 attempts at acquiring fixation
    if attemptNum < 2
        
        attemptNum = attemptNum + 1;

        % show text and keypress prompt
        Screen('FillRect', w, p.stim.BGcolor);
        DrawFormattedText(w, fixtext{attemptNum}, 'center', sy, 0);
        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
        Screen('Flip', w);

        % wait for keypress
        KbWait(p.kb.kbNum);
        [k, secs, key] = KbCheck(p.kb.kbNum);
        if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end

        % check for fixation
        fixationAcquired = eyetracker_acquireFixation(w, p, p.eyetracker.block);
        
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


%% proceed

fixtext = 'Fixation acquired! The next block of trials is coming up.'; 

Screen('FillRect', w, p.stim.BGcolor);
DrawFormattedText(w, fixtext, 'center', sy, 0);
Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
Screen('Flip', w);

WaitSecs(2);

Screen('FillRect', w, p.stim.BGcolor);
Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
Screen('Flip', w);

WaitSecs(2);
