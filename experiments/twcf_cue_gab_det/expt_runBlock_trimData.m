function [data, timing, gaze] = expt_runBlock_trimData(data, timing, gaze)
% [data, timing, gaze] = expt_runBlock_trimData(data, timing, gaze)
%
% Remove excess NaN entries at the end of the data structs.

%% determine the trim starting point

nTrials = max(data.i_trial);
t       = nTrials + 1;

%% trim the data struct

% index variables
data.i_index(t:end)                  = [];
data.indexCounter(t:end)             = [];
data.i_trial(t:end)                  = [];
data.i_blockTrial(t:end)             = [];
data.i_block(t:end)                  = [];
data.pass(t:end)                     = [];

% stimulus variables
data.RNGseed(t:end)                  = [];

data.stimID_all(:,t:end)             = [];
data.contrastID_all(:,t:end)         = []; 
data.contrast_all(:,t:end)           = []; 

data.precueLoc(t:end)                = [];
data.postcueLoc(t:end)               = [];
data.cueValidity(t:end)              = [];
data.stimID_postcue(t:end)           = [];
data.contrastID_postcue(t:end)       = []; 
data.contrast_postcue(t:end)         = []; 

% response variables
data.respDis(t:end)                  = [];
data.respDet(t:end)                  = [];
data.ratingDis(t:end)                = [];
data.resp(t:end)                     = [];
data.RT(t:end)                       = [];
data.correctDis(t:end)               = [];
data.correctDet(t:end)               = [];

% data quality variables
data.validKeypress(t:end)            = [];
data.goodFixation(t:end)             = [];
data.goodTrial(t:end)                = [];

% quest track ID
if isfield(data, 'qID')
    data.qID(t:end) = [];
end

%% trim the timing struct

% trialStages = {'fixation1', 'preCenterStim', 'centerStim', 'fixation2', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};
trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

for i_stage = 1:length(trialStages)
    eval(['timing.' trialStages{i_stage} '.VBL(t:end)     = [];']);
    eval(['timing.' trialStages{i_stage} '.onset(t:end)   = [];']);
    eval(['timing.' trialStages{i_stage} '.flip(t:end)    = [];']);
    eval(['timing.' trialStages{i_stage} '.missed(t:end)  = [];']);
    eval(['timing.' trialStages{i_stage} '.beampos(t:end) = [];']);
end

timing.keypress(t:end)            = [];
timing.randTexCreationTime(t:end) = [];
timing.stimCreationTime(t:end)    = [];

%% trim the gaze struct

if ~isempty(gaze)

    % trialStages = {'fixation1', 'preCenterStim', 'centerStim', 'fixation2', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};
    trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

    for i_stage = 2:length(trialStages)-1
        eval(['gaze.' trialStages{i_stage} '.gazeLoc_inPix(:,:,t:end) = [];']);
        eval(['gaze.' trialStages{i_stage} '.gazeInFix(:,t:end)       = [];']);
        eval(['gaze.' trialStages{i_stage} '.pDroppedSamples(:,t:end) = [];']);
        eval(['gaze.' trialStages{i_stage} '.anyBadFixations(t:end)   = [];']);
    end

end

end