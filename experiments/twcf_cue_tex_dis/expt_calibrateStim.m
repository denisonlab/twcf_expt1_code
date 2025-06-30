clear 

t0 = GetSecs;

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
makePlot  = 1; % make plot of the p(filled) vs nLines fit for each calibration type
savePlot  = 1; % save the plot
closePlot = 1; % close plot after saving?
saveFit   = 1; % save the fitting results. this will overwrite old fitting results
showLines = 1; % show lines used for the calibration procedure on screen

% open psychtoolbox window and get parameters
Screen('Preference', 'SkipSyncTests', 1);
screenNum = max(Screen('Screens'));
w         = openScreen(screenNum, 1);

w_ecc     = 0.5;
p         = expt_param(w, setup, w_ecc);

% deg1_inPix = degrees2pixels(1, p.screen.distFromScreen_inCm, p.screen.pixels_perCm);
% p.stim.periph.lineLength_inPix_list = 3:1:deg1_inPix;

% % to manually overwrite line length and width settings stored in expt_param,
% % uncomment the lines below and edit as desired
% p.stim.periph.lineLength_inPix_list = 10:10:50;
% p.stim.periph.lineWidth_inPix       = 1;
% p.stim.center.lineLength_inPix      = 10;
% p.stim.center.lineWidth_inPix       = 1;
% p.stim.rand.lineLength_inPix_list   = 10:10:50;
% p.stim.rand.lineWidth_inPix         = 1;


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
    
    switch type
        case 'random'
            
            % calibrate using all line lengths
            fit = pfilled_calibration(w, p, type, info.lineLength_inPix_list, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);
            
        otherwise
        
            % calibrate separately for each individual line length
            for i_line = 1:length(info.lineLength_inPix_list)
                lineLength_inPix = info.lineLength_inPix_list(i_line);
                fit = pfilled_calibration(w, p, type, lineLength_inPix, info.lineWidth_inPix, makePlot, savePlot, saveFit, showLines);
            end
    end
    
    if closePlot, close all; end
            
 end


Screen('CloseAll')

% return to original directory
cd(currDir);

tf = GetSecs - t0;
disp(['run time = ' tf/60 ' min'])