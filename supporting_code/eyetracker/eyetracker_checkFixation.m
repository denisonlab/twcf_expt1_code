function gaze = eyetracker_checkFixation(w, p, gaze, stage, f, i_trial)
% gaze = eyetracker_checkFixation(w, p, gaze, stage, f, i_trial)

%% collect fixation data

% get current gaze location in PTB pixel coordinates    
[gazeLocL_inPix, gazeLocR_inPix, droppedSamples] = eyetracker_getGazeLoc(w, p);

% compute distance of gaze from center of screen
gazeDist_inPix = sqrt( (gazeLocL_inPix(1) - p.rects.midW)^2 + (gazeLocL_inPix(2) - p.rects.midH)^2 ); 

% compute summary metrics of good fixation
fixationOK = gazeDist_inPix < p.eyetracker.trial.fixationRadius_inPix; % is gaze in fixation region?
samplesOK  = droppedSamples.pL <= 0.5;                                 % is the proportion of dropped samples <= 0.5?

% save gaze info
eval(['gaze.' stage '.gazeLoc_inPix(:, f, i_trial) = gazeLocL_inPix'';']);
eval(['gaze.' stage '.gazeInFix(f, i_trial)        = fixationOK;']);
eval(['gaze.' stage '.pDroppedSamples(f, i_trial)  = droppedSamples.pL;']);


%% display warning screen if fixation is bad

if ~fixationOK || ~samplesOK
    
    % notify the experimenter of a bad fixation by printing to Matlab prompt
    disp('BAD FIXATION WARNING!')
    disp(['trial # ' num2str(i_trial) ' was exited due to a bad fixation at the "' stage '" stage of the trial.']);
    disp(' ')
    
    
    % notify the participant of a bad fixation
    gaze.anyBadFixations(i_trial) = 1;
    
    sx     = p.text.sx;
    sy     = round(p.rects.window(4) / 6); % place text above fixation
    wrapat = p.text.wrapat;
    
%     fixtext = ['Bad eye fixation detected.\n\n' ...
%                'This could be due to moving your eyes too far from the fixation cross, or from blinking.\n\n' ...
%                'Make sure that you''re sitting upright and that you keep your eyes open and close to the fixation cross while stimuli are presented on the screen.\n\n' ...
%                'This trial will be repeated at the end of the block.\n\n'];

    fixtext = ['Lost fixation :(\n\n' ...
               'Try to keep your eyes on the cross at all times during the trial, sit up straight, and try not to blink!\n\n' ...
               'This trial will repeat at the end of the block.\n\n'];

    prompt  = 'Press any key to continue.';
           
    DrawFormattedText(w, fixtext, sx, sy, 0, wrapat);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    Screen('Flip', w);
    
    % after a delay, show prompt to move on
    WaitSecs(1);
    [nx, ny] = DrawFormattedText(w, fixtext, sx, sy, 0, wrapat);
    DrawFormattedText(w, prompt, sx, ny, 0, wrapat);
    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
    Screen('Flip', w);

    % listen for KB input
    KbWait(p.kb.kbNum);

else
    
    gaze.anyBadFixations(i_trial) = 0;

end