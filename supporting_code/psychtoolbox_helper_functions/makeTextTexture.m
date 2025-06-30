function [textTexture, textRect] = makeTextTexture(window, textString, padAmount, resetBGcolor, textSize, fontNameOrNumber)
% makeTextTexture(window, textString, padAmount, resetBGcolor, textSize, fontNameOrNumber)
% turns text and padding into a psychtoolbox texture  

%% handle inputs

% change text font and size if specified
if exist('textSize','var') && ~isempty(textSize)
    oldTextSize = Screen('TextSize',window,textSize);
end

if exist('fontNameOrNumber','var') && ~isempty(fontNameOrNumber)
    oldFontName = Screen('TextFont',window,fontNameOrNumber);
end

if ~exist('padAmount','var') || isempty(padAmount)
    padAmount = 0;
end

%% draw text to back buffer and convert it to a matrix

DrawFormattedText(window,textString,'center','center');
textMatrix = Screen('GetImage',window,[],'backBuffer',[],1);
textMatrix = trimMatrixBorders(textMatrix, 128, '<');


%% pad the text matrix

% if pad amount is a fraction, compute padding as padAmount * height of text matrix
if padAmount > 0 && padAmount < 1
    padAmount = round( size(textMatrix,1) * padAmount );
end

if padAmount > 0
    textMatrix = padarray(textMatrix, padAmount*[1,1], resetBGcolor);
end

%% get text texture and rect

textRect = RectOfMatrix(textMatrix);
textTexture = Screen('MakeTexture',window,textMatrix);

%% clean up

% reset text font and size
if exist('textSize','var') && ~isempty(textSize)
    Screen('TextSize',window,oldTextSize);
end

if exist('fontNameOrNumber','var') && ~isempty(fontNameOrNumber)
    Screen('TextFont',window,oldFontName);
end

% reset BG color if specified
if exist('resetBGcolor','var') && ~isempty(resetBGcolor)
    Screen('FillRect',window,resetBGcolor);
end
