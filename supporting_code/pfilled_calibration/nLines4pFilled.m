function nLines = nLines4pFilled(type, pFilledTarget, lineLength_inPix, lineWidth_inPix, lineRect, innerRect)
% nLines = nLines4pFilled(type, pFilledTarget, lineLength_inPix, lineWidth_inPix, lineRect, innerRect)


%% reconstruct data path and filename
%  as saved by pfilled_calibration

% determine the data directory
currentFile       = mfilename('fullpath');
currentFileFolder = fileparts(currentFile);
compName          = getComputerName;
dataDir           = [currentFileFolder '/results/' compName '/'];

% define filename
typeU = regexprep(type, ' +', '_');

switch type
    case 'random'
        lineLengthText = regexprep(num2str(lineLength_inPix), ' +', ',');
        filename = ['pfc_type=' typeU '_ll=' lineLengthText '_lw=' num2str(lineWidth_inPix) ...
                    '_rh=' num2str(RectHeight(lineRect)) '_rw=' num2str(RectWidth(lineRect))];
        
    otherwise
        filename = ['pfc_type=' typeU '_ll=' num2str(lineLength_inPix) '_lw=' num2str(lineWidth_inPix) ...
                    '_rh=' num2str(RectHeight(lineRect)) '_rw=' num2str(RectWidth(lineRect))];
                
        if strcmp(type, 'center BG annulus')
            filename = [filename '_irh=' num2str(RectHeight(innerRect)) '_irw=' num2str(RectWidth(innerRect))];
        end
end


%% load calibration data

try
    load([dataDir filename]);
catch
    nLines = nan;
    return
end


%% solve for nLines yielding pFilledTarget

% quadratic formula
a = fit.coeff(1);
b = fit.coeff(2);
c = fit.coeff(3) - pFilledTarget;

x(1) = (-b + sqrt(b^2 - 4*a*c)) / (2*a);
x(2) = (-b - sqrt(b^2 - 4*a*c)) / (2*a);

nLines = round(x(1));
