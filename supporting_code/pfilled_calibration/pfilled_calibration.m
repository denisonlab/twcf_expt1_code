function fit = pfilled_calibration(w, p, type, lineLength_inPix, lineWidth_inPix, makePlot, savePlot, saveFit, showLines)
% fit = pfilled_calibration(w, p, type, lineLength_inPix, lineWidth_inPix, makePlot, savePlot, saveFit, showLines)

%% settings

tic

if ~exist('makePlot', 'var')
    makePlot = 1;
end

if ~exist('savePlot', 'var')
    savePlot = 1;
end

if ~exist('showLines', 'var')
    showLines = 1;
end

BGcolor   = p.stim.lineBGcolor;
lineColor = p.stim.lineColor;

% save settings
currentFile       = mfilename('fullpath');
currentFileFolder = fileparts(currentFile);
compName          = getComputerName;

saveDir  = [currentFileFolder '/results/' compName '/'];
mkdir(saveDir);


%% get relevant data for the requested calibration type

info = getTypeInfo(type, p);
v2struct(info);


%% define nLines search space

% estimate # of pixels per line
switch type
    case 'random'
        
        % for random textures, estimate average line length across line
        % length and orientation values
        theta_list = linspace(0, 2*pi, 100);
        for i_line = 1:length(lineLength_inPix)
            for i_theta = 1:length(theta_list)
                
                % # pixels per line is computed as the length of the largest leg of the right 
                % triangle whose hypotenuse is lineLength_inPix tilted at angle theta
                theta          = theta_list(i_theta);
                lineLengthProj = max( abs( lineLength_inPix(i_line) * [cos(theta), sin(theta)] ) );
                nFilledPerLine_list(i_line, i_theta) = round( lineLengthProj * lineWidth_inPix );
                
            end
        end

        nFilledPerLine = mean(nFilledPerLine_list(:));
        
    otherwise
        
        % # pixels per line is computed as the length of the largest leg of the right 
        % triangle whose hypotenuse is lineLength_inPix tilted at angle theta
        theta          = pi / 4;
        lineLengthProj = max( abs( lineLength_inPix * [cos(theta), sin(theta)] ) );
        nFilledPerLine = round( lineLengthProj * lineWidth_inPix );
end

% search up to nLinesToFill/2, i.e. # of lines required to fill half of the 
% relevant region of the screen, assuming no line overlap or passing outside 
% the aperture
nLinesToFill = nPixelsTotal / nFilledPerLine;
nLines_list  = round( linspace(0, nLinesToFill/2, 50) );
nLines_list  = nLines_list(2:end); 


%% compute p(filled) as a function of nLines

for i = 1:length(nLines_list)
    nLines = nLines_list(i);
    
    switch type
        %% draw lines for the random texture
        case 'random'
            % define line positions
            xy = defineRandomLinesInRect(lineRect, nLines, lineLength_inPix);
            
            % draw lines to the backbuffer and take screenshot
            Screen('FillRect', w, BGcolor);
            Screen('DrawLines', w, xy, lineWidth_inPix, lineColor);
            lineScreenShot = Screen('GetImage', w, lineRect, 'backBuffer', [], 1);
            

        %% draw lines for non-random textures
        otherwise
            % define line positions
            xy = defineLinesInRect(lineRect, nLines, lineLength_inPix, theta);

            % draw lines to the backbuffer and take screenshot
            Screen('FillRect', w, BGcolor);
            Screen('DrawLines', w, xy, lineWidth_inPix, lineColor);
            lineScreenShot = Screen('GetImage', w, lineRect, 'backBuffer', [], 1);
            
            
            %% add alpha blending layers for non-'periph BG' calibration
            if ~strcmp(type, 'periphBG')

                % add alpha blending layer to create aperture
                lineScreenShot(:,:,end+1) = mask;

                % redraw the lines w/ aperture and take screenshot
                Screen('FillRect', w, BGcolor);
                lineTex = Screen('MakeTexture', w, lineScreenShot);
                Screen('DrawTexture', w, lineTex, [], lineRect);
                lineScreenShot = Screen('GetImage', w, lineRect, 'backBuffer', [], 1);
            
            end

    end
    
    % count filled pixels
    pFilled(i) = sum(lineScreenShot(:) == lineColor) / nPixelsTotal;


    if showLines
        Screen('FrameRect', w, [255 0 0], lineRect, 1);
        Screen('Flip', w);
    else
        Screen('FillRect', w, p.stim.BGcolor);
        DrawFormattedText(w, 'Calibrating...', 'center', 'center');
        Screen('Flip', w);
    end
end


%% fit p(filled) to nLines

% 2nd order polynomial fit
coeff = polyfit(nLines_list, pFilled, 2);
pFilledFit = coeff(1)*nLines_list.^2 + coeff(2)*nLines_list + coeff(3);

R2   = corr(pFilled', pFilledFit')^2;
RMSE = sqrt( mean((pFilled - pFilledFit).^2) );


%% use fit to derive nLines needed for pFilledTarget

pFilledTarget = p.stim.pFilled;

% quadratic formula
a = coeff(1);
b = coeff(2);
c = coeff(3) - pFilledTarget;

x(1) = (-b + sqrt(b^2 - 4*a*c)) / (2*a);
x(2) = (-b - sqrt(b^2 - 4*a*c)) / (2*a);

nLinesFit = round(x(1));


%% package output 

fit.nLines_list   = nLines_list;
fit.pFilled       = pFilled;
fit.pFilledFit    = pFilledFit;
fit.pFilledTarget = p.stim.pFilled;
fit.nLinesFit     = nLinesFit;
fit.coeff         = coeff;
fit.R2            = R2;
fit.RMSE          = RMSE;
fit.runtime_inSec = toc;


%% plot and save results

switch type
    case 'random'
        lineLengthText = regexprep(num2str(lineLength_inPix), ' +', ',');
        filename = ['pfc_type=' type '_ll=' lineLengthText '_lw=' num2str(lineWidth_inPix) ...
                    '_rh=' num2str(RectHeight(lineRect)) '_rw=' num2str(RectWidth(lineRect))];
        
    otherwise
        filename = ['pfc_type=' type '_ll=' num2str(lineLength_inPix) '_lw=' num2str(lineWidth_inPix) ...
                    '_rh=' num2str(RectHeight(lineRect)) '_rw=' num2str(RectWidth(lineRect))];
                
        if strcmp(type, 'center BG annulus')
            filename = [filename '_irh=' num2str(RectHeight(innerRect)) '_irw=' num2str(RectWidth(innerRect))];
        end
end


% plot fit
if makePlot
    figure; hold on;
    
    % plot data points and curve fit
    plot(nLines_list, pFilled, 'r.');
    plot(nLines_list, pFilledFit, 'b-');
    
    % plot nLines fit for pFilledTarget
    plot(nLinesFit*[1,1], pFilledTarget*[0,1], 'k--')
    plot(nLinesFit*[0,1], pFilledTarget*[1,1], 'k--')
    
    legendstr = {'data','fit'};
    
    typeText       = regexprep(type, '_+', ' ');
    lineRectText   = regexprep(num2str(lineRect), ' +', ',');
    lineLengthText = regexprep(num2str(lineLength_inPix), ' +', ',');

    titlestr{1} = ['p(filled) calibration for type ''' typeText ''''];
    titlestr{2} = ['lineRect = [' lineRectText '], line length = ' lineLengthText ', line width = ' num2str(lineWidth_inPix)];
    titlestr{3} = ['R^2 = ' num2str(R2) ', RMSE = ' num2str(RMSE)];
    
    xlabel('# lines')
    ylabel('p(filled)')
    title(titlestr);
    legend(legendstr, 'location', 'northwest')

    if savePlot
        savefile = [saveDir filename '.png'];
        saveas(gcf, savefile, 'png');
        close(gcf);
    end
end


% save fit
if saveFit
    savefile = [saveDir filename  '.mat'];
    save(savefile, 'fit');
end

end