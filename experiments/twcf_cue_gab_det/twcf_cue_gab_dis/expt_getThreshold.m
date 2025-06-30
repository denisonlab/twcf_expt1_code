function w_tilt = expt_getThreshold(threshDir)
% w_tilt = expt_getThreshold(threshDir)
%
% Returns threshold values for grating tilt 
% based on a subject's most recent thresholding block. The output w_tilt
% ranges from 0 (vertical) to 1 (±45°). The exact value returned is
% intended to yield p(correct) = 0.75 in the orientation discrimination
% task for the median contrast used for the peripheral stimuli.
%
% If there is a problem loading the thresholding data (e.g. because
% thresholding hasn't been performed yet), w_tilt is returned as NaN.
%
% INPUTS
% - threshDir: directory containing the subject's threhsolding data
% - distFromScreen_inCm: subject's distance from screen in cm. if
% unspecified, defaults to the value used at the time of thresholding.
% - pixels_perCm: pixels per cm of the current screen (which depends on the 
% screen resolution). if unspecified, defaults to the value used at the time 
% of thresholding.


%% load most recent QUEST result

try
    % read in the filenames for completed thresholding data sets
    fileID = fopen([threshDir 'completed_thresholding_data.txt'], 'r');
    filenames = textscan(fileID, '%s', 'Delimiter', '\n');
    fclose(fileID);

    % load the most recent thresholding data set
    % (i.e. the last dataset listed in completed_thresholding_data.txt)
    load([threshDir filenames{1}{end}]);

    % find QUEST track with median threshold estimate
    w_tilt = median( 10.^QuestMean(data.q_tilt) );

    if     w_tilt < 0, w_tilt = 0;
    elseif w_tilt > 1, w_tilt = 1; end
    
catch
    w_tilt = NaN;
end

