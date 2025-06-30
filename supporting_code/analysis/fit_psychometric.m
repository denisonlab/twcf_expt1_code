function [paramsFitted, logL, searchGridlog] = fit_psychometric(stimLevels, outOfNum, numPos, taskType, fixedLambda)
% [paramsFitted, logL, searchGridlog] = fit_psychometric(stimLevels, outOfNum, numPos, taskType, fixedLambda)
% 
% Fit a Gumbel psychometric function to data using Palamedes toolbox. See 
% http://www.palamedestoolbox.org/weibullandfriends.html for more information. 
% This function essentially serves as a wrapper that pre-defines the search 
% grid and performs the fit, taking into account whether the data to be fitted 
% comes from a detection or discrimination task.
% 
% inputs
% ------
% stimLevels  - A 1xN vector holding the values of the stimulus used at each 
%               of the N data points along the psychometric function, e.g. contrast 
%               or line length. Input these as actual physical values, not as
%               log-transformed values.
% outOfNum    - A 1xN vector holding the total number of trials at each data point.
% numPos      - A 1xN vector holding the number of positive outcomes at each 
%               data point (i.e. a "yes" response in a detection task, or a correct 
%               response in a discrimination task).
% taskType    - A string denoting the type of task, 'detection' or 'discrimination'.
% fixedLambda - If specified, the fitting procedure assumes a fixed value for 
%               lambda, the lapse rate (i.e. the asymptotic value of the psychometric 
%               function, which may be less than 1 due to e.g. occasional lapses of 
%               attention). e.g. if fixedLambda is entered as 0.01, then the fitting 
%               procedure will use a fixed value of 0.01 for lambda.
%               If unspecified, the fitting procedure treats lambda as a free 
%               parameter to be estimated from the data.
%               
% outputs
% -------
% paramsFitted  - A 1x4 vector holding the psychometric function parameters 
%                 [alpha, beta, gamma, lambda] as returned by PAL_PFML_Fit.
% logL          - Log-likelihood of the psychometric function fit as returned
%                 by PAL_PFML_Fit.
% searchGridlog - A copy of the search grid struct used as input to PAL_PFML_Fit.
%                 Note that stimulus values in the search grid have been
%                 log transformed.

%% define search grid

% search through this grid of parameter values for seed to be used in iterative parameter search
searchGrid.alpha = .05:.05:3;
searchGrid.beta  = 10.^[-1:.1:1];

switch taskType
    case 'detection',      searchGrid.gamma = 0;
    case 'discrimination', searchGrid.gamma = 0.5;
end

if exist('fixedLambda','var')
    % set lambda to a fixed value
    paramsFree        = [1 1 0 0];
    searchGrid.lambda = fixedLambda;

else
    % leave lambda as free parameter
    paramsFree        = [1 1 0 1];
    searchGrid.lambda = 0:.001:.1;
end

% prepare for Gumbel fit
logStimLevels = log10(stimLevels);
searchGridlog = searchGrid;
searchGridlog.alpha = log10(searchGridlog.alpha);


%% fit Gumbel

[paramsFitted, logL] = PAL_PFML_Fit(logStimLevels, numPos, outOfNum, searchGridlog, paramsFree, @PAL_Gumbel);