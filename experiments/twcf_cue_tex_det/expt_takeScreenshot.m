function expt_takeScreenshot(w, trialStage)

% take screenshot
screenShot = Screen('GetImage', w);

% get date and time for unique filename
exptDate = datestr(clock,'yyyymmdd');
exptTime = datestr(clock,'HHMMSS');
filenameSuffix = [exptDate '_' exptTime];

screenshotDir = 'screenshot/';
mkdir(screenshotDir);
imwrite(screenShot, [screenshotDir 'screenshot_' trialStage '_' filenameSuffix '.png'], 'PNG');