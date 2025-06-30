function hh = twcf_errorbar(varargin)
%ERRORBAR Plot error bars along curve
%   ERRORBAR(Y,ERR) plots Y and draws a vertical error bar at each element
%   of Y. ERR specifies the error bar distance above and below the curve so
%   that bars are symmetric with a length of 2*ERR. Specify Y and ERR as
%   vectors of equal length, matrices of equal size, or a combination of
%   vectors and matrices that share a matching size in at least one
%   dimension.
%
%   ERRORBAR(X,Y,ERR) plots Y versus X with symmetric vertical error bars
%   2*ERR long. Specify X, Y, and ERR as vectors of equal length, matrices
%   of equal size, or a combination of vectors and matrices that share a
%   matching size in at least one dimension. ERR specifies the vertical
%   distance of error bars from Y in both the lower and upper directions.
%
%   ERRORBAR(X,Y,NEG,POS) plots Y versus X with vertical error bars with
%   lengths NEG+POS specifying the lower and upper error bar lengths.
%   Specify X, Y, NEG, and POS as vectors of equal length, matrices
%   of equal size, or a combination of vectors and matrices that share a
%   matching size in at least one dimension. NEG or POS can be empty to
%   omit error bars in the lower or upper directions.
%
%   ERRORBAR( ___ ,Orientation) specifies the orientation of the error
%   bars. Orientation can be 'horizontal', 'vertical', or 'both'. When
%   orientation is omitted the default is 'vertical'.
%
%   ERRORBAR(X,Y,YNEG,YPOS,XNEG,XPOS) plots Y versus X with vertical and
%   horizontal error bars. Vertical error bars are YNEG+YPOS long where
%   YNEG and YPOS define the lengths of the lower and upper bar segements,
%   respectively. Horizontal error bars are XNEG+XPOS long where XNEG and
%   YPOS define the lengths of the left and right bar segments,
%   respectively. Specify X, Y, YNEG, YPOS, XNEG, and YPOS as vectors of
%   equal length, matrices of equal size, or a combination of vectors and
%   matrices that share a matching size in at least one dimension. Use
%   empty error values to omit error bar segments.
%
%   ERRORBAR( ___ ,LineSpec) specifies the color, line style, and marker.
%   The color is applied to the data line and error bars. The line style
%   and marker are applied to the data line only.
%
%   ERRORBAR(AX, ___ ) plots into the axes specified by AX instead of the
%   current axes.
%
%   E = ERRORBAR( ___ ) returns a vector of ErrorBar objects created.
%   ERRORBAR creates one object for vector input arguments or one object
%   per column for matrix input arguments.
%
%   Example: Draws symmetric error bars of unit standard deviation.
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2022 The MathWorks, Inc.

matlab.graphics.chart.internal.DDUXLogger(mfilename,varargin);

% Look for a parent among the input arguments
[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);

if isempty(cax) && ~isempty(args) && isa(args{1},'matlab.graphics.Graphics')
    % axescheck will not parse out first arg parents that are not axes,
    % e.g. charts. Manually extract these here so that they are not
    % confused for x/y data. Note that cax will be set back to empty below
    % by cax = ancestor(cax,'axes'); and en error will be thrown by the
    % ErrorBar object if the parent is invalid.
    cax=args{1};
    args(1)=[];
end

% Errorbar requires at least two inputs
narginchk(2, inf);

% Separate Name/Value pairs from data inputs, convert LineSpec to
% Name/Value pairs, and filter out the orientation flag.
[pvpairs,args,nargs,msg,orientation] = parseargs(args);
if ~isempty(msg), error(msg); end
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
% Check that we have the correct number of data input arguments.
if nargs < 2
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 4 && ~isempty(orientation)
    error(message('MATLAB:errorbar:InvalidUseOfOrientation'));
elseif nargs == 5
    error(message('MATLAB:errorbar:InvalidNumberDataInputs'));
elseif nargs > 6
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% Make sure all the data input arguments are real numeric data or a
% recognized non-numeric data type.
args = matlab.graphics.chart.internal.getRealData(args, true);

% Grab the X data if present.
x = [];
autoXData = true;
if nargs >= 3
    % errorbar(x,y,e,...); otherwise errorbar(y,e)
    x = args{1};
    args = args(2:end);
    autoXData = isempty(x);
end
if isempty(x)
    x = args{1}; % borrow y for validation, replace later.
end

y = args{1};
args = args(2:end);

xneg = [];
xpos = [];
yneg = [];
ypos = [];
if numel(args) == 4
    % errorbar(x,y,yneg,ypos,xneg,xpos)
    yneg = args{1};
    ypos = args{2};
    xneg = args{3};
    xpos = args{4};
else
    if numel(args) == 1
        % errorbar(x,y,e) and errorbar(y,e)
        neg = args{1};
        pos = neg;
    elseif numel(args) == 2
        % errorbar(x,y,neg,pos)
        neg = args{1};
        pos = args{2};
    end

    switch orientation
        % errorbar(y,e,orientation) or
        % errorbar(x,y,e,orientation) or
        % errorbar(x,y,neg,pos,orientation)
        case 'horizontal'
            xneg = neg;
            xpos = pos;
        case 'both'
            xneg = neg;
            xpos = pos;
            yneg = neg;
            ypos = pos;
        otherwise
            % Default to vertical if orientation isn't specified.
            yneg = neg;
            ypos = pos;
    end
end

% Validate delta arguments along with x and y. Ignore empty delta arguments
% when validating.
[errorArgMsg, x, y, xneg, xpos, yneg, ypos] = findMatchingDimensionsIgnoreEmptyDeltas(x, y, xneg, xpos, yneg, ypos);
if ~isempty(errorArgMsg)
    throw(MException(message('MATLAB:errorbar:InvalidDataSizes')));
end
% Now that data args have passed validation, we can determine how many
% objects will be created
numSeries = size(y,2);
if autoXData
    % x used for validation and configuration purposes only
    x = (1:numSeries).';
end

% Empty delta arguments must be empties of the correct size and data type.
if isempty(xneg)
    xneg = defaultEmptyDelta(x, numSeries);
end
if isempty(xpos)
    xpos = defaultEmptyDelta(x, numSeries);
end
if isempty(yneg)
    yneg = defaultEmptyDelta(y, numSeries);
end
if isempty(ypos)
    ypos = defaultEmptyDelta(y, numSeries);
end

validateDeltaDataTypes(xneg,xpos,x)
validateDeltaDataTypes(yneg,ypos,y)

% Handle vectorized data sources and display names
extrapairs = cell(numSeries,0);
if ~isempty(pvpairs) && (numSeries > 1)
    [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,numSeries,...
        {'XDataSource','YDataSource',...
        'UDataSource','LDataSource',...
        'XNegativeDeltaSource','XPositiveDeltaSource',...
        'YNegativeDeltaSource','YPositiveDeltaSource',...
        'DisplayName'});
end

% Prepare the parent for plotting.
if isempty(cax) || ishghandle(cax,'axes')
    showInteractionInfoPanel = isempty(cax) && isempty(get(groot,'CurrentFigure'));
    cax = newplot(cax);
    parax = cax;
    if showInteractionInfoPanel
        % Maybe open the Interaction Info Panel
        matlab.graphics.internal.InteractionInfoPanel.maybeShow(cax);
    end
    hold_state = any(strcmp(cax.NextPlot,{'replacechildren','add'}));
else
    parax = cax;
    cax = ancestor(cax,'axes');
    hold_state = true;
end

% Configure the axes for non-numeric data.
matlab.graphics.internal.configureAxes(cax,x,y);

% Determine the Color and LineStyle property names
% If the Color/LineStyle is not specified use the _I property names so that
% the ColorMode or LineStyleMode properties are not toggled.
colorPropName = 'Color';
autoColor = ~any(strcmpi('color',pvpairs(1:2:end)));
if autoColor
    colorPropName = 'Color_I';
end
stylePropName = 'LineStyle';
autoStyle = ~any(strcmpi('linestyle',pvpairs(1:2:end)));
if autoStyle
    stylePropName = 'LineStyle_I';
end

% Cast numeric values to double
[x,y,xneg,xpos,yneg,ypos] = castToDouble(x,y,xneg,xpos,yneg,ypos);

% Create the ErrorBar objects
h = gobjects(1,numSeries);
xdata = {};
for n = 1:numSeries

    stylepv={};
    if ~isempty(cax)
        [ls,c,m] = matlab.graphics.chart.internal.nextstyle(cax,autoColor,autoStyle,true);
        stylepv={colorPropName c stylePropName ls 'Marker_I',m};
    end

    if ~autoXData
        xdata = {'XData', x(:,n)};
    end

    h(n) = matlab.graphics.chart.primitive.ErrorBar('Parent',parax, ...
        'YData',y(:,n),xdata{:},...
        'XNegativeDelta',xneg(:,n),...
        'XPositiveDelta',xpos(:,n),...
        'YNegativeDelta',yneg(:,n),...
        'YPositiveDelta',ypos(:,n),...
        stylepv{:},...
        pvpairs{:},...
        extrapairs{n,:});
    h(n).assignSeriesIndex();
end

if ~hold_state
    set(cax,'Box','on');
end

if nargout>0, hh = h; end

end

%-------------------------------------------------------------------------%
function [pvpairs,args,nargs,msg,orientation] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);

% Check for LineSpec or Orientation strings
% Allow the orientation flag to occur either before or after the LineSpec
% Allow LineSpec and Orientation to occur at most once each.
validOrientations = {'horizontal','vertical','both'};
orientation = '';
keepArg = true(1,numel(pvpairs));
extraPairs = {};
for a = 1:min(2,numel(pvpairs))
    if matlab.graphics.internal.isCharOrString(pvpairs{a})
        % Check for partial matching of the orientation flag using a
        % minimum of 3 characters.
        tf = strncmpi(pvpairs{a},validOrientations,max(3,numel(pvpairs{a})));
        if isempty(orientation) && any(tf)
            orientation = validOrientations{tf};
            keepArg(a) = false;
        else
            % Check for LineSpec string
            [l,c,m,tmsg]=colstyle(pvpairs{a},'plot');
            if isempty(tmsg) && isempty(extraPairs)
                keepArg(a) = false;
                if ~isempty(l)
                    extraPairs = {'LineStyle',l};
                end
                if ~isempty(c)
                    extraPairs = [{'Color',c},extraPairs]; %#ok<AGROW>
                end
                if ~isempty(m)
                    extraPairs = [{'Marker',m},extraPairs]; %#ok<AGROW>
                end
            else
                break;
            end
        end
    else
        % Not a string, so stop looking.
        break
    end
end

linestyleerror = numel(pvpairs)==1;
pvpairs = [extraPairs, pvpairs(keepArg)];
msg = matlab.graphics.chart.internal.checkpvpairs(pvpairs,linestyleerror);
nargs = numel(args);

end

%-------------------------------------------------------------------------%
function [msg, x, y, varargout] = findMatchingDimensionsIgnoreEmptyDeltas(x,y,varargin)
% Check non-empty inputs for matching dims.
nonEmptyInds = cellfun(@(x)~isempty(x),varargin);
varargout = varargin;
[msg, x, y, varargout{nonEmptyInds}] = matlab.graphics.chart.primitive.internal.findMatchingDimensions(x,y,varargin{nonEmptyInds});
end

%-------------------------------------------------------------------------%
function validateDeltaDataTypes(neg, pos, data)
% Make sure deltas' data types are compatible with x/ydata data type.
if iscategorical(data) && ~(isempty(neg) && isempty(pos))
    % Deltas must be empty when data is categorical.
    throwAsCaller(MException(message('MATLAB:errorbar:CategoricalDeltaArgumentNotSupported')));
elseif (isa(data, 'datetime') || isa(data, 'duration')) && ...
        ~(isa(neg, 'duration') && isa(pos, 'duration'))
    % Deltas must be duration when data is datetime or duration.
    throwAsCaller(MException(message('MATLAB:errorbar:DeltaArgumentTypeMustBeDuration')));
elseif isnumeric(data) && ~(isnumeric(neg)  && isnumeric(pos))
    % Deltas must be numeric when data is numeric.
    throwAsCaller(MException(message('MATLAB:errorbar:DeltaArgumentTypeMustBeNumeric')));
end
end

%-------------------------------------------------------------------------%
function delta = defaultEmptyDelta(data,num)
% Create empty delta based on the data type and number of objects.

if isa(data, 'datetime') || isa(data, 'duration')
    % duration delta for datetime or duration data
    delta = duration.empty(0,num);
else
    % numeric delta for numeric or categorical data
    delta = zeros(0,num);
end
end

%-------------------------------------------------------------------------%
function varargout = castToDouble(varargin)
% Cast numeric inputs to double; nargout should == nargin.
varargout = varargin;
for i = 1:nargout
    if isnumeric(varargin{i})
        varargout{i} =  matlab.graphics.chart.internal.datachk(varargin{i});
    end
end
end

