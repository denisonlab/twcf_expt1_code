function lineLength_inDeg_list = expt_getThresholds(threshDir, distFromScreen_inCm, pixels_perCm, makePlot)
% lineLength_inDeg_list = expt_getThresholds(threshDir, distFromScreen_inCm, pixels_perCm, makePlot)
%
% Returns threshold values for line length based on a subject's most recent
% thresholding block. The output lineLength_inDeg_list contains line length
% thresholds in visual degrees for the following 7 points:
%
% - Lower extreme: line length midway between minimum line length (3 pixels) and 
% line length yielding nearly-chance performance (.51) on a log10 scale. Define 
% displacement D = (log10(len(pcorr=0.51)) - log10(len(3 pixels)))/2. Then 
% log10(len(lower extreme)) = log10(len(pcorr=0.51)) - D
% - p(correct oval orientation discrimination) = 0.6
% - p(correct oval orientation discrimination) = 0.675
% - p(correct oval orientation discrimination) = 0.75
% - p(correct oval orientation discrimination) = 0.825
% - p(correct oval orientation discrimination) = 0.9
% - Upper extreme: define the distance b/t the lower extreme and the
% pcorr=0.6 point as D2 = log10(len(pcorr=0.6)) - log10(len(lower extreme)).
% then define upper extreme as having same distance D2 from pcorr=0.9
% point, log10(len(upper extreme)) = log10(len(pcorr=0.9)) + D2
%
% If there is a problem loading the thresholding data (e.g. because
% thresholding hasn't been performed yet), lineLength_inDeg_list is
% returned as NaN.
%
% INPUTS
% - threshDir: directory containing the subject's threhsolding data
% - distFromScreen_inCm: subject's distance from screen in cm. if
% unspecified, defaults to the value used at the time of thresholding.
% - pixels_perCm: pixels per cm of the current screen (which depends on the 
% screen resolution). if unspecified, defaults to the value used at the time 
% of thresholding.
% - makePlot: if set to 1, makes a plot showing the thresholds plotted on 
% the psychometric function derived from thresholding. default value is 0.

if ~exist('makePlot','var') || isempty(makePlot)
    makePlot = 0;
end

%% load most recent QUEST result

try
    % read in the filenames for completed thresholding data sets
    fileID = fopen([threshDir 'completed_thresholding_data.txt'], 'r');
    filenames = textscan(fileID, '%s', 'Delimiter', '\n');
    fclose(fileID);

    % load the most recent thresholding data set
    % (i.e. the last dataset listed in completed_thresholding_data.txt)
    load([threshDir filenames{1}{end}]);
catch
    lineLength_inDeg_list = NaN;
end


%% define min (3 pixels) and max (3 deg) line lengths in visual degrees

% default distFromScreen and pixels_perCm to values used during thresholding
if ~exist('distFromScreen_inCm','var') || isempty(distFromScreen_inCm)
    distFromScreen_inCm = p.screen.distFromScreen_inCm;
end

if ~exist('pixels_perCm','var') || isempty(pixels_perCm)
    pixels_perCm = p.screen.pixels_perCm;
end

x_min_inPix = 3;
x_min_inDeg = pixels2degrees(x_min_inPix, distFromScreen_inCm, pixels_perCm);
x_min       = log10(x_min_inDeg); 

x_max       = log10(3);

%% find QUEST track with median threshold estimate

thresholds  = QuestMean(data.q);
[t, ind]    = sort(thresholds);
ind_median  = ind(2);
q           = data.q(ind_median);
thresh      = QuestMean(q);


%% get thresholds

x    = min(q.x) : .001 : max(q.x);  
weib = QuestP(q, x);
x    = x + thresh; % shift x-axis so that threshold (previously at x=0) is at x=thresh

pcorr_target = [0.6, 0.675, 0.75, 0.825, 0.9];
for i = 1:length(pcorr_target)
    [m, ind] = min(abs(weib - pcorr_target(i)));
    x_target(i) = x(ind);
    pcorr_at_x_target(i) = weib(ind);
end

% determine the two extreme endpoint line lenghts as follows:
%
% - Lower extreme: select line length midway between minimum (3 pixels) and 
% line length yielding nearly-chance performance (.51) on a log10 scale. Define 
% displacement D = (log10(len(nearly chance)) - log10(len(3 pixels)))/2. Then 
% log10(len(lower extreme)) = log10(len(nearly chance)) - D.
%
% It may occur that this procedure yields a value lower than the minimum, i.e. 
% log10(len(lower extreme)) < log10(len(3 pixels)). If so, then define 
% log10(len(lower extreme)) = log10(len(3 pixels)). 
%
% - Upper extreme: define the distance b/t the lower extreme and the
% pcorr=0.6 point as D2 = log10(len(pcorr=0.6)) - log10(len(lower extreme)).
% then define upper extreme as having same distance D2 from pcorr=0.9
% point, log10(len(upper extreme)) = log10(len(pcorr=0.9)) + D2

% compute line length corresponding to 51% correct
pcorr_target_extr = 0.51;
[m, ind] = min(abs(weib - pcorr_target_extr));
x_target_extr(1) = x(ind);

% define lower extreme
D = (x_target_extr(1) - x_min)/2;
x_target_extr_D(1) = x_target_extr(1) - D;

if x_target_extr_D(1) < x_min
    x_target_extr_D(1) = x_min; 
end
    
% define upper extreme
D2 = x_target(1) - x_target_extr_D(1);
x_target_extr_D(2) = x_target(end) + D2;
pcorr_at_x_target_extr_D = QuestP(q, x_target_extr_D - thresh);

x_target_all = [x_target_extr_D(1), x_target, x_target_extr_D(2)];

lineLength_inDeg_list = 10.^x_target_all;



%% plot

if makePlot
    figure; hold on;
    plot(x, weib, '-', 'LineWidth', 1)
    for i = 1:length(pcorr_target)
        plot( x_target(i)*[1,1], [.5, pcorr_at_x_target(i)], 'k--')
        plot( [x(1), x_target(i)], pcorr_at_x_target(i)*[1,1], 'k--')
    end

    plot( thresh*[1,1], [.5, .75], 'r--')
    plot( [x(1), thresh], .75*[1,1], 'r--')

    xlim([min(x), max(x)])
    xlabel('log_{10}(line length) at cued loc (deg)')
    ylabel('p(correct discrim)')
    
    plot(x_target_extr_D, pcorr_at_x_target_extr_D, 'r.', 'MarkerSize', 10);
    for i = 1:2
        plot( [x(1), x_target_extr_D(i)], pcorr_at_x_target_extr_D(i)*[1,1], 'k--')
    end

    plot(x_min*[1,1], ylim, 'b-') % minimum line length
    plot(x_max*[1,1], ylim, 'b-') % maximum line length
   
    xlim([x_min, x_max])
end