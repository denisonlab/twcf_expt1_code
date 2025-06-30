function [timing_badFixation, gaze_badFixation] = expt_updateBadFixationTrialData(setup, i_trial, nRepetitions, timing_badFixation, gaze_badFixation, timing, gaze)
% [timing_badFixation, gaze_badFixation] = expt_updateBadFixationTrialData(setup, i_trial, nRepetitions, timing_badFixation, gaze_badFixation, timing, gaze)
%
% Update timing and gaze data for trials that are exited early due to bad fixation

%% get next index for bad fixation data

ind = length(timing_badFixation) + 1;

%% store timing data for this trial

timing_badFixation(ind).i_trial      = i_trial;
timing_badFixation(ind).nRepetitions = nRepetitions;

trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

for i_stage = 1:length(trialStages)
    eval(['timing_badFixation(ind).' trialStages{i_stage} '.VBL     = timing.' trialStages{i_stage} '.VBL(i_trial);']);
    eval(['timing_badFixation(ind).' trialStages{i_stage} '.onset   = timing.' trialStages{i_stage} '.onset(i_trial);']);
    eval(['timing_badFixation(ind).' trialStages{i_stage} '.flip    = timing.' trialStages{i_stage} '.flip(i_trial);']);
    eval(['timing_badFixation(ind).' trialStages{i_stage} '.missed  = timing.' trialStages{i_stage} '.missed(i_trial);']);
    eval(['timing_badFixation(ind).' trialStages{i_stage} '.beampos = timing.' trialStages{i_stage} '.beampos(i_trial);']);
end

timing_badFixation(ind).randTexCreationTime = timing.randTexCreationTime(i_trial);
timing_badFixation(ind).stimCreationTime    = timing.stimCreationTime(i_trial);


%% store gaze data for this trial

gaze_badFixation(ind).i_trial      = i_trial;
gaze_badFixation(ind).nRepetitions = nRepetitions;

trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

for i_stage = 2:length(trialStages)-1
    eval(['gaze_badFixation(ind).' trialStages{i_stage} '.gazeLoc_inPix   = gaze.' trialStages{i_stage} '.gazeLoc_inPix(:, :, i_trial);']);
    eval(['gaze_badFixation(ind).' trialStages{i_stage} '.gazeInFix       = gaze.' trialStages{i_stage} '.gazeInFix(:, i_trial);']);
    eval(['gaze_badFixation(ind).' trialStages{i_stage} '.pDroppedSamples = gaze.' trialStages{i_stage} '.pDroppedSamples(:, i_trial);']);
    eval(['gaze_badFixation(ind).' trialStages{i_stage} '.anyBadFixations = gaze.anyBadFixations(i_trial);']);
end