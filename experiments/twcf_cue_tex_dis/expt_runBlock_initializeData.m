function [data, timing, gaze, progress] = expt_runBlock_initializeData(p, b)
% [data, timing, gaze, progress] = expt_runBlock_initializeData(p, b)

%% buffer trials

% initialize with a large # of trials to ensure that we don't have to
% append new entries to the data vectors in the main expt even if trials
% are frequently repeated, since doing so can add significantly to
% computation time
nBuffer = b.nTrials * 2;

%% initialize the data struct

% index variables
data.i_index                  = nan(1, nBuffer);
data.indexCounter             = nan(1, nBuffer);
data.i_trial                  = nan(1, nBuffer);
data.i_blockTrial             = nan(1, nBuffer);
data.i_block                  = nan(1, nBuffer);
data.pass                     = nan(1, nBuffer);
data.passInfo                 = {};

% stimulus variables
data.RNGseed                  = cell(1, nBuffer);

data.angleBG_all              = nan(4, nBuffer);
data.angleFG_all              = nan(4, nBuffer);
data.stimID_all               = nan(4, nBuffer);
data.lineLengthID_all         = nan(4, nBuffer);
data.lineLength_inDeg_all     = nan(4, nBuffer); % updated in expt_runTrial
data.lineLength_inPix_all     = nan(4, nBuffer); % updated in expt_runTrial

data.precueLoc                = nan(1, nBuffer);
data.postcueLoc               = nan(1, nBuffer);
data.cueValidity              = nan(1, nBuffer);
data.stimID_postcue           = nan(1, nBuffer);
data.lineLengthID_postcue     = nan(1, nBuffer);
data.lineLength_inDeg_postcue = nan(1, nBuffer); % updated in expt_runTrial
data.lineLength_inPix_postcue = nan(1, nBuffer); % updated in expt_runTrial
% % % data.lineLength_inDeg_center  = nan(1, nBuffer); % updated in expt_runTrial
% % % data.lineLength_inPix_center  = nan(1, nBuffer); % updated in expt_runTrial

data.ovalEccentricity         = nan(1, nBuffer); % oval eccentricity

% response variables
data.respDis                  = nan(1, nBuffer);
data.ratingDis                = nan(1, nBuffer);
data.resp                     = nan(1, nBuffer);
data.RT                       = nan(1, nBuffer);
data.correctDis               = nan(1, nBuffer);

% data quality variables
data.validKeypress            = nan(1, nBuffer);
data.goodFixation             = nan(1, nBuffer);
data.goodTrial                = nan(1, nBuffer);

% other
data.auditoryFB               = b.auditoryFB;


% make 3 QUEST tracks if this is a thresholding block
if p.setup.isThresholding
    
    data.qID = nan(1, nBuffer);
    
    for i_track = 1:3
        % quest structs for oval eccentricity (ecc)
        data.q_ecc(i_track) = QuestCreate(p.quest_ecc.tGuess, p.quest_ecc.tGuessSD, p.quest_ecc.pThreshold, p.quest_ecc.beta, ...
                                          p.quest_ecc.delta, p.quest_ecc.gamma, p.quest_ecc.grain, p.quest_ecc.range);

% % %         % quest structs for center line length (cll)
% % %         data.q_cll(i_track) = QuestCreate(p.quest_cll.tGuess, p.quest_cll.tGuessSD, p.quest_cll.pThreshold, p.quest_cll.beta, ...
% % %                                           p.quest_cll.delta, p.quest_cll.gamma, p.quest_cll.grain, p.quest_cll.range);
    
    end
end

%% initialize the timing struct

% trialStages = {'fixation1', 'preCenterStim', 'centerStim', 'fixation2', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};
trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

for i_stage = 1:length(trialStages)
    eval(['timing.' trialStages{i_stage} '.VBL     = nan(1, nBuffer);']);
    eval(['timing.' trialStages{i_stage} '.onset   = nan(1, nBuffer);']);
    eval(['timing.' trialStages{i_stage} '.flip    = nan(1, nBuffer);']);
    eval(['timing.' trialStages{i_stage} '.missed  = nan(1, nBuffer);']);
    eval(['timing.' trialStages{i_stage} '.beampos = nan(1, nBuffer);']);
end

timing.keypress            = nan(1, nBuffer);
timing.randTexCreationTime = nan(1, nBuffer);
timing.stimCreationTime    = nan(1, nBuffer);

%% initialize the gaze struct

if p.eyetracker.doEyetracking

    % trialStages = {'fixation1', 'preCenterStim', 'centerStim', 'fixation2', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};
    trialStages = {'fixation1', 'fixation3', 'precue', 'prePeriphStim', 'periphStim', 'fixation4', 'postcue'};

    for i_stage = 2:length(trialStages)-1
        eval(['gaze.' trialStages{i_stage} '.gazeLoc_inPix   = nan(2, p.timing.' trialStages{i_stage} 'Dur_inFrames, nBuffer);']);
        eval(['gaze.' trialStages{i_stage} '.gazeInFix       = nan(p.timing.' trialStages{i_stage} 'Dur_inFrames, nBuffer);']);
        eval(['gaze.' trialStages{i_stage} '.pDroppedSamples = nan(p.timing.' trialStages{i_stage} 'Dur_inFrames, nBuffer);']);
        eval(['gaze.' trialStages{i_stage} '.anyBadFixations = nan(1, nBuffer);']);
    end

else
    gaze = [];
end

%% initialize the progress struct

progress.i_trial      = 0;
progress.i_block      = 0;
progress.i_blockTrial = 0;
progress.indexList    = [];
progress.indexCounter = [];
progress.indexQueue   = [];

end