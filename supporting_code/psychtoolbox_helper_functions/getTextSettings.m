function [fontSize, sx, wrapat] = getTextSettings(w, windowRect, nLettersPerCol, widthBuffer)
% [fontSize, sx, sy, wrapat] = getTextSettings(w, windowRect, nLettersPerCol, widthBuffer)
%
% Determine text setting variables for use with DrawFormattedText. The
% output 'fontSize' is determined such that 'nLettersPerCol' letters drawn 
% at 'fontSize' one on top of the other could fill an entire column on the
% screen. 'sx' and 'wrapat' are determined such that, given 'fontSize', a
% typical line of text will leave empty spaces on the left and right side
% of the screens with a width equal to 'widthBuffer'.
%
% inputs
% * w              : psychtoolbox window pointer
% * windowRect     : rect for the PTB window
% * nLettersPerCol : # letters that fit in a column on the screen
% * widthBuffer    : fraction of screen width that is left empty on either
%                    side of the drawn text 

%% get path and filename

debugging = 0;

% get path for pfilled_calibration folder
currentFile       = mfilename('fullpath');
currentFileFolder = fileparts(currentFile);
compName          = getComputerName;

originalDir = cd(currentFileFolder);
newDir      = ['../pfilled_calibration/results/' compName '/']; 

if ~exist(newDir, 'dir')
    mkdir(newDir)
end
cd(newDir);

filename = ['textSettings_nlpc=' num2str(nLettersPerCol) '_wb=' num2str(widthBuffer) '_sw=' num2str(RectWidth(windowRect)) '.mat'];

try
    %% if settings are already saved, load them   

    load(filename)
    cd(originalDir)
    
catch

    %% if settings aren't already saved, figure them out    

    %% show 'working on it' screen

    Screen('FillRect', w, 127);
    DrawFormattedText(w, 'Calbrating text settings...', 'center', 'center'); 
    Screen('Flip', w);

    %% determine font size

    % store original font size
    originalFontSize = Screen('TextSize', w, 10);

    % determine target letter height
    letterHeight_inPixels_target = round( RectHeight(windowRect) / nLettersPerCol );

    % find the font size yielding target letter height
    fontSizes = [20:20:100];
    for i = 1:length(fontSizes)
        Screen('TextSize', w, fontSizes(i));
        DrawFormattedText(w, 'A');
        textMatrix = Screen('GetImage', w, [], 'backBuffer', [], 1);
        textMatrix = trimMatrixBorders(textMatrix);
        letterHeight_inPixels(i) = size(textMatrix, 1);
    end

    B = polyfit(fontSizes, letterHeight_inPixels, 1);
    fontSize = round( (letterHeight_inPixels_target - B(2)) / B(1) ); 

    Screen('TextSize', w, fontSize);

    %% determine sx and wrapat

    % find average letter width at current font size
    testText = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    DrawFormattedText(w, testText);
    textMatrix = Screen('GetImage', w, [], 'backBuffer', [], 1);
    textMatrix = trimMatrixBorders(textMatrix);

    letterWidth_inPixels = ceil( size(textMatrix,2) / length(testText) );
    textWidth = RectWidth(windowRect) - 2*widthBuffer;

    wrapat    = round( textWidth / letterWidth_inPixels );
    sx        = round( widthBuffer * RectWidth(windowRect) );

    %% save results

    save(filename, 'fontSize', 'sx', 'wrapat');

    %% restore original font size and directory

    Screen('TextSize', w, originalFontSize);
    cd(originalDir)
    
    %% save variables for debugging purposes
    if debugging
        save getTextSettings.mat
    end

end