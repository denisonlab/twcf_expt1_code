function [p, exitNow] = eyetracker_calibrate(w, p)

exitNow = 0;
switch p.setup.site
    case 'UCI'
        viewDist = p.screen.distFromScreen_inCm*10;
        WindowID = p.screen.screenNum;
        winStim = w;
        
        fixtext = ['Let''s calibrate the eyetracker.\n\n' ...
                   'You''ll see a series of white circles with black dots in the middle. ' ...
                   'When they appear, look at the black dot and hold your eyes steady until that dot disappears.\n\n' ...
                   'Press any key to begin.'];
        Screen('FillRect', w, p.stim.BGcolor);
        DrawFormattedText(w, fixtext, 'center', 'center', 0, p.text.wrapat);
        Screen('Flip', w);

        % wait for keypress
        KbWait(p.kb.kbNum);
        [k, secs, key] = KbCheck(p.kb.kbNum);
        if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end        
        
        % Calibrate the eyetracker
        exitNow = crsLiveTrackCalibrate_mp(viewDist, WindowID, winStim, p);
        if exitNow, return; end
        
        % Clear buffer after calibration so we can start the buffer fresh
        crsLiveTrackClearDataBuffer;
        
        % Start buffering data to the library and timestamp the beginning
        % of the buffer
        p.eyetracker.clockStart = GetSecs();
        crsLiveTrackStartTracking;
        
    case 'BU'
        rd_eyeLink('calibrate', w, p.eyetracker.el);
end
