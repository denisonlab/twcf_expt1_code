clear

t0 = GetSecs;

nreps = 300;

% add paths
addpath(genpath('../../supporting_code'));

%% set distance from screen in cm

distFromScreen_inCm = NaN;
while ~(distFromScreen_inCm > 0 || distFromScreen_inCm <= 120)
    disp(' ')
    distFromScreen_inCm = input('Enter distance from screen in cm (recommended default = 75):   ');
    disp(' ')
end

setup.distFromScreen_inCm = distFromScreen_inCm;
setup.isCalibration       = 1;
setup.threshDir           = [];

%% define calibration settings

% select which texture types to calibrate, using the following numerical code:
% 1 : periph BG
% 2 : periph FG oval
% 3 : periph FG circle
% 4 : center BG annulus
% 5 : center FG circle
% 6 : random texture
types_list = 2;

% calibration options
makePlot  = 0; % make plot of the p(filled) vs nLines fit for each calibration type
savePlot  = 0; % save the plot
closePlot = 1; % close plot after saving?
saveFit   = 0; % save the fitting results. this will overwrite old fitting results
showLines = 1; % show lines used for the calibration procedure on screen

% open psychtoolbox window and get parameters
Screen('Preference', 'SkipSyncTests', 1);
screenNum = max(Screen('Screens'));
w         = openScreen(screenNum, 1);

w_eccs    = 0 : .2 : 1;

for i_rep = 1:nreps

for i_w = 1:length(w_eccs)
    
    w_ecc = w_eccs(i_w);

    p     = expt_param(w, setup, w_ecc);


    %% run the calibration

    currDir = cd('../../supporting_code/pfilled_calibration');

    % set screen properties
    Screen(w, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % define type strings
    types = p.calibration.typeNames;

    % calibrate for each type
    for i_type = types_list

        type = types{i_type};
        info = getTypeInfo(type, p);
        
        % re-define line length list so that we're only ranging over the 7
        % line lengths used in this experiment
        info.lineLength_inPix_list = p.stim.periph.lineLength_inPix_list;

        switch type
            case 'random'

                % calibrate using all line lengths
                fit = pfilled_calibration(w, p, type, info.lineLength_inPix_list, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);

            otherwise

                % calibrate separately for each individual line length
%                 for i_line = 1:length(info.lineLength_inPix_list)
%                     lineLength_inPix = info.lineLength_inPix_list(i_line);
%                     fit = pfilled_calibration(w, p, type, lineLength_inPix, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);
%                     
%                     fit_w_ecc.pFilledTarget            = p.stim.pFilled;
%                     fit_w_ecc.w_ecc(i_line, i_w)       = w_ecc;
%                     fit_w_ecc.nLinesFit(i_line, i_w)   = fit.nLinesFit;
%                     fit_w_ecc.fit_details{i_line, i_w} = fit;
%                 end

                for i_line = 1:length(info.lineLength_inPix_list)
                    lineLength_inPix = info.lineLength_inPix_list(i_line);
                    fit = pfilled_calibration(w, p, type, lineLength_inPix, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);

                    fit_w_ecc.pFilledTarget                   = p.stim.pFilled;
                    fit_w_ecc.w_ecc(i_line, i_w)              = w_ecc;
                    fit_w_ecc.nLinesFit(i_line, i_w, i_rep)   = fit.nLinesFit;
                    fit_w_ecc.fit_details{i_line, i_w, i_rep} = fit;
                end
                save expt_calibrateStim_forThresh_data3.mat fit_w_ecc
        end

        if closePlot, close all; end

    end
   
    % return to original directory
    cd(currDir);
    
end
end

Screen('CloseAll')

tf = GetSecs - t0;
disp(['run time = ' num2str(tf/60) ' min'])


figure; 
for i_line = 1:length(info.lineLength_inPix_list)
    subplot(2,4,i_line); hold on;
    
    n   = (size(fit_w_ecc.nLinesFit,3)-1);
    sigma = std( squeeze( fit_w_ecc.nLinesFit(i_line, :, 1:end-1) ), 0, 2 );
    sem   = sigma / n;
    
    errorbar(fit_w_ecc.w_ecc(i_line, :), mean( fit_w_ecc.nLinesFit(i_line, :, 1:end-1), 3), sem, '.-');
    errorbar(fit_w_ecc.w_ecc(i_line, :), mean( fit_w_ecc.nLinesFit(i_line, :, 1:end-1), 3), sigma, '.-');

    xlabel('w_{ecc}')
    ylabel('avg n lines')
    title(['line len = ' num2str(info.lineLength_inPix_list(i_line)) ' pix'])
    if i_line == 1
        legend('SEM', 'std dev')
    end
end
sgtitle(['avg across ' num2str(n) ' calibration repetitions'])


figure; 
for i_line = 1:length(info.lineLength_inPix_list)
    subplot(2,4,i_line); hold on;
    plot(fit_w_ecc.w_ecc(i_line, :), squeeze( fit_w_ecc.nLinesFit(i_line, :, 1:end-1) ), 'o-');
    xlabel('w_{ecc}')
    ylabel('n lines for each repetition')
    title(['line len = ' num2str(info.lineLength_inPix_list(i_line)) ' pix'])
end
sgtitle(['results across ' num2str(n) ' calibration repetitions'])
