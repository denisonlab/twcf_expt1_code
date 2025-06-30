function [data, timing, exitNow] = expt_runBlock(w, p, b, setup, incompleteData)
% [data, timing, exitNow] = expt_runBlock(w, p, b, setup)

rng('shuffle')

%% initialize data, timing, gaze, and progress structs

if setup.resumeDataset
    % unpack the incompleteData struct
    v2struct(incompleteData);
    pass = max(data.pass) + 1;
else
    % initialize data
    [data, timing, gaze, progress] = expt_runBlock_initializeData(p, b);
    pass = 1;
end
data.passCurrent = pass; 

% save pass info
data.passInfo{pass} = ['Pass #' num2str(pass) ' started on ' datestr(now)];

% save prestim noise options
data.prestimNoise = setup.prestimNoise; 

%% set initial variable values

if setup.resumeDataset
    % if resuming an incomplete data set, set initial values for trial, block, etc
    % by reference to the previously loaded progress struct
    %
    % N.B. that progress.i_trial is the last *successfully completed* trial, 
    % and so we initialize i_trial to the next uncompleted trial which is 
    % progress.i_trial + 1 (and similarly for the other trial variables)
    init.i_trial       = progress.i_trial + 1;
    init.i_block       = progress.i_block;
    init.i_blockTrial  = progress.i_blockTrial + 1;
    init.indexList     = progress.indexList;
    init.indexCounter  = progress.indexCounter;
    init.indexQueue    = progress.indexQueue;
    
    % if the index queue for resumed data is empty, that means the
    % experiment was exited during a break. in this instance we can skip
    % repeating this break and jump into the next block of trials
    init.skipBreak     = isempty(init.indexQueue);
else
    % if starting from scratch, initial values are intuitive
    init.i_trial       = 1;
    init.i_block       = 1;
    init.i_blockTrial  = 1;
    init.indexList     = [];
    init.indexCounter  = [];
    init.indexQueue    = [];
    init.skipBreak     = 0;
end

prevDataFilename = '';

%% show initial instruction screen

exitNow = expt_runBlock_instructions(w, p, b, setup);
if exitNow, return; end


%% run the blocks

i_trial = init.i_trial; % absolute trial counter which ignores block #
for i_block = init.i_block : b.nBlocks
    
    %% pre-block fixation acquisition
    
    if p.eyetracker.doEyetracking
        exitNow = eyetracker_preBlockFixation(w, p);
        if exitNow, return; end
    end
    
    
    %% run the block
    
    % get trial indeces for the current block
    if isempty(init.indexList)
        indexList    = find(b.i_block == i_block); % saves a static list of trial indeces to b for this block
        indexCounter = zeros(size(indexList));      % counts how many times each index has been chosen
        indexQueue   = indexList;                   % stores indeces that have not yet yielded a good trial
    else
        indexList    = init.indexList;
        indexCounter = init.indexCounter;
        indexQueue   = init.indexQueue;
    end
    
    i_blockTrial = init.i_blockTrial;
    while ~isempty(indexQueue)
        
        % randomly select a trial index from the queue
        i_index = indexQueue( randperm(length(indexQueue),1) );
        
        % run a trial using the current index
        [data, timing, gaze, exitNow] = expt_runTrial(w, p, b, data, timing, gaze, i_index, i_trial);

        % optional early exit
        if exitNow, return; end

        % increment and save the index and trial counters
        indexCounter = indexCounter + double(indexList==i_index);
        data.indexCounter(i_trial) = indexCounter(indexList==i_index);
        data.i_blockTrial(i_trial) = i_blockTrial;
        data.pass(i_trial)         = pass;
        
        % remove index from the queue if this trial was completed
        % successfully, OR if this was the 4th attempt for this index
        if data.goodTrial(i_trial) || indexCounter(indexList==i_index) == 4
            indexQueue = setdiff(indexQueue, i_index);
        end
                
        % save progress
        progress.i_trial      = i_trial;
        progress.i_block      = i_block;
        progress.i_blockTrial = i_blockTrial;
        progress.indexList    = indexList;
        progress.indexCounter = indexCounter;
        progress.indexQueue   = indexQueue;
        
        % save data with filename to reflect trial and block progress
        dataFilename = [setup.dataFilename '_trial_' num2str(i_blockTrial) '_of_block_' num2str(i_block) '.mat'];
        save([setup.dataDir dataFilename], 'p', 'b', 'data', 'timing', 'gaze', 'setup', 'progress');

        % delete previous data with outdated filename
        delete([setup.dataDir prevDataFilename]);
        prevDataFilename = dataFilename;
        
        % increment trial counters
        i_trial      = i_trial + 1;
        i_blockTrial = i_blockTrial + 1;
        
    end
    
    
    %% break between blocks
    
    if ~init.skipBreak
        exitNow = expt_takeBreak(w, p, b, i_block);
        if exitNow, return; end
    end
    
    % reset init variables
    init.i_blockTrial = 1;
    init.indexList    = [];
    init.skipBreak    = 0;
    
end

%% final save

% trim superfluous NaNs from the data structs
[data, timing, gaze] = expt_runBlock_trimData(data, timing, gaze);

% save final dataset
dataFilename = [setup.dataFilename '.mat'];
save([setup.dataDir dataFilename], 'p', 'b', 'data', 'timing', 'gaze', 'setup');

% remove incomplete dataset
delete([setup.dataDir prevDataFilename]);

if setup.isThresholding
    fileID = fopen([setup.dataDir 'completed_thresholding_data.txt'], 'a');
    fprintf(fileID,[setup.dataFilename '.mat\n']);
    fclose(fileID);
end