function expt_plotQuestResults(threshDir, runNum)

%% load data

% read in the filenames for completed thresholding data sets
fileID = fopen([threshDir 'completed_thresholding_data.txt'], 'r');
filenames = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

% if runNum is unspecified, set it to the most recent thresholding run
% (i.e. the last dataset listed in completed_thresholding_data.txt)
if ~exist('runNum', 'var') || isempty(runNum)
    runNum = length(filenames{1});
end

% load the specified thresholding data set
load([threshDir filenames{1}{runNum}]);


%% plot

figure;

sgtitle({['expt: ' setup.exptName ' | subject: ' setup.subjectID], ...
         ['QUEST run #' num2str(runNum) ' (started on ' setup.exptDate ' ' setup.exptTime ')']}, ...
         'Interpreter', 'none');

subplot(1,2,1); hold on;
for i_qID = 1:3
    plot( data.q_ecc(i_qID).intensity(1:40) );
end
plot([1,40], p.quest_ecc.tGuess*[1,1], 'k--')
xlabel('trial #')
ylabel('log_{10} w_{ecc} (aspect ratio fraction)')
title(['prior = ' num2str(p.quest_ecc.tGuess) ', final = ' num2str(median(QuestMean(data.q_ecc)))])
legend('track 1', 'track 2', 'track 3', 'prior')

subplot(1,2,2); hold on;
for i_qID = 1:3
    plot( 10.^data.q_ecc(i_qID).intensity(1:40) );
end
plot([1,40], 10.^p.quest_ecc.tGuess*[1,1], 'k--')
xlabel('trial #')
ylabel('w_{ecc} (aspect ratio fraction)')
title(['prior = ' num2str(10.^p.quest_ecc.tGuess) ', final = ' num2str(median(10.^QuestMean(data.q_ecc)))])