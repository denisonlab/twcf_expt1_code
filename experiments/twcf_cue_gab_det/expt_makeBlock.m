function b = expt_makeBlock(setup)
% b = expt_makeBlock(setup)
% 
% variables
% ---------
% for 4 x N variables, row index values are (1=upper left, 2=upper right, 3=lower right, 4=lower left)
% N = number of trials
% 
% b.stimID_all           - 4 x N - stimID at each quadrant (0=absent, 1=vertical oval, 2=horizontal oval)
% b.contrastID_all       - 4 x N - contrast at each quadrant (value=index of p.stim.periph.contrast_inDeg_list)
% b.angleBG_all          - 4 x N - angle (in radians) of BG lines at each quadrant
% b.angleFG_all          - 4 x N - angle (in radians) of FG lines at each quadrant
% b.contrastID_all       - 4 x N - contrastID at each quadrant (value=index of p.stim.periph.contrast_list)
%
% b.precueLoc            - 1 x N - quadrant indicated by the precue (0=neutral, 1=upper left, 2=upper right, 3=lower right, 4=lower left)
% b.postcueLoc           - 1 x N - quadrant indicated by postcue (1=upper left, 2=upper right, 3=lower right, 4=lower left)
% b.cueValidity          - 1 x N - validity of precue (1=valid, 0=neutral, -1=invalid)
% b.stimID_postcue       - 1 x N - stimID of stimulus indicated by the postcue
% b.contrastID_postcue   - 1 x N - contrastID of stimulus indicated by the postcue
% b.qID                  - 1 x N - ID of quest track (for thresholding blocks only)
%
% b.nTrials              - 1 x 1 - number of trials in this set of blocks
% b.nTrialsPerBlock      - 1 x 1 - number of trials per block
% b.nBlocks              - 1 x 1 - number of blocks
% b.i_block              - 1 x N - block number of each trial
% b.auditoryFB           - 1 x 1 - auditory feedback (0=FB turned off, 1=FB turned on)

rng('shuffle')

b.practiceStage = setup.practiceStage;


%% set parameters for screenshot

if setup.takeScreenshot
    
    b.auditoryFB = 0;
    
    % stimID at each quadrant (0=absent, 1=vertical oval, 2=horizontal oval)
    % row index values are (1=upper left, 2=upper right, 3=lower right, 4=lower left)
    b.stimID_all = [0; 1; 0; 2];
    
    % contrastID at each quadrant. define the corresponding line length
    % in degrees in expt_param around line 108, in the if statement that reads
    % 
    % if setup.isMainExpt
    %    [...]
    % elseif setup.takeScreenshot
    %     p.stim.periph.contrast_inDeg_list = [ENTER DESIRED VALUES HERE];
    % end
    b.contrastID_all = [5; 7; 1; 2];
    
%     angleBG_all   = [pi/4, 3*pi/4]';
%     b.angleBG_all = angleBG_all(1);
%     b.angleFG_all = b.angleBG_all + pi/2;
    
    b.precueLoc  = 2;
    b.postcueLoc = 2;
    b.cueValidity = b.precueLoc == b.postcueLoc;
    
    % determine stimID and contrastID at postcue
    b.stimID_postcue       = b.stimID_all( b.postcueLoc );
    b.contrastID_postcue = b.contrastID_all( b.postcueLoc );
 
    b.nTrials         = 1;
    b.nTrialsPerBlock = 1;
    b.nBlocks         = 1;
    b.i_block         = 1;

    
%% make practice block
    
elseif setup.isPractice

    nTrials = 10; % must be multiple of 5
    
    % ensure cue validity is 60% valid, 20% neutral, 20% invalid
    cueValidity   = repmat([1 1 1 0 -1], 1, nTrials/5);
    b.cueValidity = Shuffle(cueValidity); 
    
    if setup.practiceStage == 3
        b.auditoryFB = 1;
    else
        b.auditoryFB = 0;
    end
    
    % randomly select stimID in each quadrant
    stimID       = [zeros(1,8), ones(1,4), 2*ones(1,4)]'; % minimal counterbalanced unit of stimIDs
    stimID_all   = Shuffle( repmat(stimID, 1, nTrials) ); % make nTrials copies of stimIDs in the columns and shuffle each column
    b.stimID_all = stimID_all(1:4, :);                    % select only the first 4 rows
    
    % randomly select contrast in each quadrant
    contrastID_all   = [1:7, 1:7, 1:7, 1:7]';
    contrastID_all   = Shuffle( repmat(contrastID_all, 1, nTrials) ); % make nTrials copies of contrastID in the columns and shuffle each column
    b.contrastID_all = contrastID_all(1:4, :);                        % select only the first 4 rows
       
    % randomly select angles for BG and FG
%     angleBG_all   = [pi/4, 3*pi/4]';
%     angleBG_all   = Shuffle( repmat(angleBG_all, 1, nTrials) );
%     angleBG_all   = angleBG_all(1,:);
%     b.angleBG_all = repmat(angleBG_all, 4, 1); % all 4 quadrants have same BG angle on each trial
%     b.angleFG_all = b.angleBG_all + pi/2;      % FG angle is always orthogonal to BG angle
       
    % randomly select postcue location
    postcueLoc   = [1:4]';
    postcueLoc   = Shuffle( repmat(postcueLoc, 1, nTrials) ); % make nTrials copies of postcueLoc in the columns and shuffle each column
    b.postcueLoc = postcueLoc(1, :);                          % select only the first row
    
    % determine precue based on cue validity and postcue
    b.precueLoc = zeros(1, nTrials);
    b.precueLoc(b.cueValidity==1) = b.postcueLoc(b.cueValidity==1);
    
    for i_trial = 1:nTrials
        if b.cueValidity(i_trial) == -1
            nonpostcueLoc = setdiff(1:4, b.postcueLoc(i_trial));
            ind = randperm(3,1);
            b.precueLoc(i_trial) = nonpostcueLoc(ind);
        end
    end
    
    % determine stimID and contrastID at postcue
    for i_trial = 1:nTrials
        b.stimID_postcue(i_trial)       = b.stimID_all( b.postcueLoc(i_trial), i_trial );
        b.contrastID_postcue(i_trial) = b.contrastID_all( b.postcueLoc(i_trial), i_trial );
    end
  
    b.nTrials         = nTrials;
    b.nTrialsPerBlock = nTrials;
    b.nBlocks         = b.nTrials / b.nTrialsPerBlock;

    b.i_block = [];
    for i = 1:b.nBlocks
        b.i_block = [b.i_block, i*ones(1,b.nTrialsPerBlock)];
    end
    
%% make thresholding block

elseif setup.isThresholding
    
    b.auditoryFB = 0;

    %%% counterbalancing strategy
    % exactly counterbalance the following:
    % (i.e. control marginal and conditional probabilities)
    % - postcue location (4)
    % - stim absent/present at cue (2) 
    % - stim horizontal/vertical for stim present trials at cue (2)
    % - QUEST track (3)
    %
    % [NOTE: we include stim absent at cue trials for psychological/perceptual continuity 
    %  w/ main expt, even though such trials do not contribute to the QUEST procedure]
    %
    % pseudo-counterbalance the following:
    % (i.e. control marginal but not conditional probabilities)
    % - stim present/absent at non-cued locations
    % - stim horizontal/vertical for stim present trials at uncued locations
    % - BG angle
    
    % 4 x 2 x 2 x 3 = 48 trials in minimal counterbalanced unit (MCU)
    % 48 trials x 5 reps = 240 trials total (80 per QUEST track, giving 40
    % stim present trials per QUEST track)
    nMCU    = 48;
    nReps   = 5; % 5 1 for debugging only
    nTrials = nMCU * nReps;
    
    %%% exact counterbalancing for postcue loc, stimID at cued loc, and QUEST track
    
    % initialize variables
    stimID_postcue = []; 
    postcueLoc     = []; 
    qID            = [];
    
    for i_qID = 1:3
        for i_postcueLoc = 1:4
             for i_rep = 1:nReps
                 stimID_postcue = [stimID_postcue, 0 0 1 2]; % can change to be all present for debugging only 
                 postcueLoc     = [postcueLoc,     i_postcueLoc * ones(1,4)];
                 qID            = [qID,            i_qID * ones(1,4)];
             end
        end
    end
    
    % apply identical shuffling
    [b.stimID_postcue, shuffleInd] = Shuffle(stimID_postcue);
    b.postcueLoc                   = postcueLoc(shuffleInd);
    b.qID                          = qID(shuffleInd);
    
    %%% pseudo-counterbalance BG angle
    % create even distribution of pi/4 and 3pi/4 angles
    % angleBG_all = [pi/4*ones(1,nTrials/2), 3*pi/4*ones(1,nTrials/2)];

    % shuffle and tile across quadrants 
    % (BG angle is the same across quadrants within each trial)
    % b.angleBG_all = repmat( Shuffle(angleBG_all), 4, 1);
    % b.angleFG_all = b.angleBG_all + pi/2; % FG angle is always orthogonal to BG angle

    %%% pseudo-counterbalance stimID at uncued locations
    for i_cued = 1:4
        for i_uncued = setdiff(1:4, i_cued)
            % for each possible value of cued location,
            % create even distributions of stimID in the remaining uncued locations,
            % then shuffle across trials independently for each location
            stimID_uncued{i_cued}{i_uncued} = repmat([0 0 1 2], 1, nTrials/(4*4));
            stimID_uncued{i_cued}{i_uncued} = Shuffle(stimID_uncued{i_cued}{i_uncued});
        end
    end
    
    % combine stimID_postcue with stimID_uncued
    i_cued_counter = zeros(1,4);
    b.stimID_all = nan(4, nTrials);
    for i_trial = 1:nTrials
        
        % define cued and uncued locations
        i_cued   = b.postcueLoc(i_trial);
        i_uncued = setdiff(1:4, i_cued);
        
        % assign cued location stimID
        b.stimID_all(i_cued, i_trial) = b.stimID_postcue(i_trial);

        % assign uncued location stimIDs
        i_cued_counter(i_cued) = i_cued_counter(i_cued) + 1;
        i_trial_cued = i_cued_counter(i_cued); % which trial # at cued location are we on
        for j = 1:length(i_uncued)
            b.stimID_all(i_uncued(j), i_trial) = stimID_uncued{i_cued}{i_uncued(j)}(i_trial_cued);
        end
    end
    
    
    %%% no counterbalancing needed for these since all trials are neutral cue
    b.precueLoc  = zeros(1, nTrials);
    b.cueValidity = zeros(1, nTrials);

    %%% no contrastIDs are defined since contrast is adjusted dynamically by QUEST
    b.contrastID_all     = nan(4, nTrials);
    b.contrastID_postcue = nan(1, nTrials);
    
    %%% trial and block counts
    b.nTrials         = nTrials;
    b.nTrialsPerBlock = nTrials / 2; % 240 / 2 = 120
    b.nBlocks         = b.nTrials / b.nTrialsPerBlock;

    b.i_block = [];
    for i = 1:b.nBlocks
        b.i_block = [b.i_block, i*ones(1,b.nTrialsPerBlock)];
    end

%% make piloting block

elseif setup.isPiloting

    b.auditoryFB = 0;

    %%% counterbalancing strategy
    % exactly counterbalance the following:
    % (i.e. control marginal and conditional probabilities)
    % - postcue location (4)
    % - stim absent/present at cue (all present) (1) 
    % - stim horizontal/vertical for stim present trials at cue (2)
    % - postcue stim contrast (7) 
    %
    % pseudo-counterbalance the following:
    % (i.e. control marginal but not conditional probabilities)
    % - stim present/absent at non-cued locations
    % - stim horizontal/vertical for stim present trials at uncued locations
    % - BG angle
    
    % 4 x 1 x 2 * 7 = 56 trials in minimal counterbalanced unit (MCU)
    % 56 trials x 7 reps = 392 trials total 
    nMCU    = 56;
    nReps   = 7; % 7, 1 for debugging only
    nTrials = nMCU * nReps;
    
    %%% exact counterbalancing for postcue loc, stimID at cued loc, and QUEST track
    
    % initialize variables
    stimID_postcue = []; 
    postcueLoc     = []; 
    contrastID_all = [];
    contrastID_postcue = []; 

    for i_contrast = 1:7
        for i_stimID_postcue = 1:2 % all present 
            for i_postcueLoc = 1:4
                for i_rep = 1:nReps
                    stimID_postcue = [stimID_postcue, i_stimID_postcue]; 
                    postcueLoc     = [postcueLoc,     i_postcueLoc];
                    contrastID_all = [contrastID_all, i_contrast];
                    contrastID_postcue = [contrastID_postcue, i_contrast]; 
                end
            end
        end
    end

    % apply identical shuffling
    [b.stimID_postcue, shuffleInd] = Shuffle(stimID_postcue);
    b.postcueLoc                   = postcueLoc(shuffleInd);
    % b.contrastID_all               = contrastID_all(shuffleInd);
    b.contrastID_postcue           = contrastID_postcue(shuffleInd); 

    %%% pseudo-counterbalance contrastID and stimID at uncued locations
    for i_cued = 1:4
        for i_uncued = setdiff(1:4, i_cued)
            % for each possible value of cued location,
            % create psuedo even distributions of stimID (present and absent) in the remaining uncued locations,
            % then shuffle across trials independently for each location
            stimID_uncued{i_cued}{i_uncued}       = repmat([0 0 1 2], 1, round(nTrials/(4*4))); 
            stimID_uncued{i_cued}{i_uncued}((nTrials/4)+1:end) = []; % delete extra

            contrastID_uncued{i_cued}{i_uncued}   = repmat(1:7, 1, nTrials/(4*7));

            stimID_uncued{i_cued}{i_uncued}       = Shuffle(stimID_uncued{i_cued}{i_uncued});
            contrastID_uncued{i_cued}{i_uncued}   = Shuffle(contrastID_uncued{i_cued}{i_uncued});
        end
    end
    
    % combine contrastID_postcue with contrastID_uncued, and stimID_postcue with stimID_uncued
    i_cued_counter     = zeros(1,4);
    b.contrastID_all   = nan(4, nTrials);
    b.stimID_all       = nan(4, nTrials);
    for i_trial = 1:nTrials
        
        % define cued and uncued locations
        i_cued   = b.postcueLoc(i_trial);
        i_uncued = setdiff(1:4, i_cued);
        
        % assign cued location contrastID and stimID
        b.contrastID_all(i_cued, i_trial)   = b.contrastID_postcue(i_trial);
        b.stimID_all(i_cued, i_trial)       = b.stimID_postcue(i_trial);

        % assign uncued location stimIDs
        i_cued_counter(i_cued) = i_cued_counter(i_cued) + 1;
        i_trial_cued = i_cued_counter(i_cued); % which trial # at cued location are we on
        for j = 1:length(i_uncued)
            b.contrastID_all(i_uncued(j), i_trial)   = contrastID_uncued{i_cued}{i_uncued(j)}(i_trial_cued);
            b.stimID_all(i_uncued(j), i_trial)       = stimID_uncued{i_cued}{i_uncued(j)}(i_trial_cued);
        end
    end
    
    %%% no counterbalancing needed for these since all trials are neutral cue
    b.precueLoc  = zeros(1, nTrials);
    b.cueValidity = zeros(1, nTrials);

    %%% trial and block counts
    b.nTrials         = nTrials;
    b.nTrialsPerBlock = nTrials / 4; % 240 / 2 = 120
    b.nBlocks         = b.nTrials / b.nTrialsPerBlock;

    b.i_block = [];
    for i = 1:b.nBlocks
        b.i_block = [b.i_block, i*ones(1,b.nTrialsPerBlock)];
    end
    
%% make blocks for the main experiment

else
    
    b.auditoryFB = 0;

    %%% counterbalancing strategy
    % exactly counterbalance the following:
    % (i.e. control marginal and conditional probabilities)
    % - precue type (60% valid / 20% neutral / 20% invalid) (5)
    % - line length at cued location (7 lengths)
    % - stim absent/present at cue (2)
    % - stim horizontal/vertical for stim present trials at cue (2)
    % - postcue location (4)
    %
    % pseudo-counterbalance the following:
    % (i.e. control marginal but not conditional probabilities)
    % - stim present/absent at non-cued locations
    % - oval horizontal/vertical for stim present trials
    % - BG angle
    % - precue location for invalid precues
    
    % 5 x 7 x 2 x 2 x 4 = 560 trials in minimal counterbalanced unit (MCU)
    % 560 trials x 1 reps = 560 trials total, 80 trials per contrast 
    nMCU    = 560;
    nReps   = 1;
    nTrials = nMCU * nReps;
    
    % initialize variables
    stimID_all           = [];
    contrastID_all       = []; 
    % angleBG_all          = [];
    % angleFG_all          = [];

    precueLoc            = [];
    postcueLoc           = []; 
    cueValidity          = [];
    stimID_postcue       = []; 
    contrastID_postcue     = [];

    %%% exact counterbalancing for cue validity, line length at cued loc, 
    %%% stimID at cued loc, and postcue loc
    cueValidity_list    = [1 1 1 0 -1]; % for every 3 valid cues there's 1 neutral and 1 invalid
    stimID_postcue_list = [0 0 1 2];    % 50% stim absent, 25% stim present horizontal, 25% stim present vertical
    contrastID_list     = 1:7; 
    for i_cueValidity = 1:length(cueValidity_list)
        for i_contrastID = 1:numel(contrastID_list)
            for i_stimID = 1:length(stimID_postcue_list)
                for i_postcueLoc = 1:4
                    for i_rep = 1:nReps
                        cueValidity          = [cueValidity,          cueValidity_list(i_cueValidity)];
                        contrastID_postcue   = [contrastID_postcue,   contrastID_list(i_contrastID)];
                        stimID_postcue       = [stimID_postcue,       stimID_postcue_list(i_stimID)];
                        postcueLoc           = [postcueLoc,           i_postcueLoc];
                        
                        % determine precue location based on precue
                        % validity and postcue location
                        switch cueValidity_list(i_cueValidity)
                            case 1
                                i_precueLoc = i_postcueLoc;
                            case 0
                                i_precueLoc = 0;
                            case -1
                                nonpostcueLoc = setdiff(1:4, i_postcueLoc);
                                ind = randperm(3,1);
                                i_precueLoc = nonpostcueLoc(ind);
                        end
                        precueLoc = [precueLoc, i_precueLoc];
                        
                    end
                end
            end
        end
    end
    
    % apply identical shuffling
    [b.cueValidity, shuffleInd] = Shuffle(cueValidity);
    b.contrastID_postcue        = contrastID_postcue(shuffleInd);
    b.stimID_postcue            = stimID_postcue(shuffleInd);
    b.postcueLoc                = postcueLoc(shuffleInd);
    
    b.precueLoc                 = precueLoc(shuffleInd);
   
    
    %%% pseudo-counterbalance BG angle
    % create even distribution of pi/4 and 3pi/4 angles
    % angleBG_all = [pi/4*ones(1,nTrials/2), 3*pi/4*ones(1,nTrials/2)];

    % shuffle and tile across quadrants 
    % (BG angle is the same across quadrants within each trial)
    % b.angleBG_all = repmat( Shuffle(angleBG_all), 4, 1);
    % b.angleFG_all = b.angleBG_all + pi/2; % FG angle is always orthogonal to BG angle
    
    
    %%% pseudo-counterbalance contrastID and stimID at uncued locations
    for i_cued = 1:4
        for i_uncued = setdiff(1:4, i_cued)
            % for each possible value of cued location, create even distributions 
            % of contrastID and stimID in the remaining uncued locations.
            % each of the 4 cued locations has nTrials/4 trials total, so
            % for a variable with N values we need nTrials/(4*N) tilings.
            contrastID_uncued{i_cued}{i_uncued}   = repmat(1:7, 1, nTrials/(4*7));
            stimID_uncued{i_cued}{i_uncued}       = repmat([0 0 1 2], 1, nTrials/(4*4));

            % shuffle across trials independently for each location
            contrastID_uncued{i_cued}{i_uncued}   = Shuffle(contrastID_uncued{i_cued}{i_uncued});
            stimID_uncued{i_cued}{i_uncued}       = Shuffle(stimID_uncued{i_cued}{i_uncued});
        end
    end
    
    
    % combine contrastID_postcue with contrastID_uncued, and stimID_postcue with stimID_uncued
    i_cued_counter     = zeros(1,4);
    b.contrastID_all   = nan(4, nTrials);
    b.stimID_all       = nan(4, nTrials);
    for i_trial = 1:nTrials
        
        % define cued and uncued locations
        i_cued   = b.postcueLoc(i_trial);
        i_uncued = setdiff(1:4, i_cued);
        
        % assign cued location contrastID and stimID
        b.contrastID_all(i_cued, i_trial)   = b.contrastID_postcue(i_trial);
        b.stimID_all(i_cued, i_trial)       = b.stimID_postcue(i_trial);

        % assign uncued location stimIDs
        i_cued_counter(i_cued) = i_cued_counter(i_cued) + 1;
        i_trial_cued = i_cued_counter(i_cued); % which trial # at cued location are we on
        for j = 1:length(i_uncued)
            b.contrastID_all(i_uncued(j), i_trial)   = contrastID_uncued{i_cued}{i_uncued(j)}(i_trial_cued);
            b.stimID_all(i_uncued(j), i_trial)       = stimID_uncued{i_cued}{i_uncued(j)}(i_trial_cued);
        end
    end
    
   
    % trial and block counts
    b.nTrials         = nTrials;
    b.nTrialsPerBlock = nTrials / 5;
    b.nBlocks         = b.nTrials / b.nTrialsPerBlock;
    
    b.i_block = [];
    for i = 1:b.nBlocks
        b.i_block = [b.i_block, i*ones(1,b.nTrialsPerBlock)];
    end

end