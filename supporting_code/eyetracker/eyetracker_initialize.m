function [p, exitNow] = eyetracker_initialize(w, p)
% p = eyetracker_initialize(w, p, setup)

exitNow = 0;
switch p.setup.site
    case 'UCI'
        % Initialise LiveTrack
        crsLiveTrackInit;
        
        % Do eyetracker calibration & start streaming to buffer
        [p, exitNow] = eyetracker_calibrate(w,p);
        
    case 'BU'
        window = w;
        
        eyeDataDir = 'eyedata';
        if length(p.setup.subjectID) > 3
            subjectID = p.setup.subjectID(1:3);
        else
            subjectID = p.setup.subjectID;
        end
        eyeFile = sprintf('%s%s', subjectID, p.setup.exptDate(5:end));

        % Initialize eye tracker
        [el exitFlag] = rd_eyeLink('eyestart', window, eyeFile);
        if exitFlag
            return
        end

        % Calibrate eye tracker
        [cal exitFlag] = rd_eyeLink('calibrate', window, el);
        if exitFlag
            return
        end
        
        p.eyetracker.el  = el;
        p.eyetracker.cal = cal;
end

end