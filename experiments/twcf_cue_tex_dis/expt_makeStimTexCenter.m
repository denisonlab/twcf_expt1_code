function tex_stim = expt_makeStimTexCenter(w, p, s)
% tex_stim = twcf_makeStimTexCenter(w, p, s)
%
% w - psychtoolbox window pointer
% p - parameter struct
% s - stimulus struct, e.g. s = p.stim.center
%
% s must also have the fields listed below.
%
% s.angle_FG - angle of lines in FG
% s.angle_BG - angle of lines in BG


%% draw BG lines
 
% get nLines
ind    = find( p.calibration.centerBG_annulus.lineLength_inPix_list == s.lineLength_inPix );
nLines = p.calibration.centerBG_annulus.nLines(ind);

% define line positions
xy = defineLinesInRect(p.rects.centerBG, nLines, s.lineLength_inPix, s.angleBG);

% draw lines to the backbuffer and save textures
Screen('FillRect', w, p.stim.lineBGcolor);
Screen('DrawLines', w, xy, p.stim.center.lineWidth_inPix, p.stim.lineColor);

bg = Screen('GetImage', w, p.rects.centerBG, 'backBuffer');

% add oval alpha blending layer to FG stim
bg(:,:,end+1) = p.masks.centerBG;

tex_stim.bg = Screen('MakeTexture', w, bg);


%% draw FG lines
    
% get nLines
ind = find( p.calibration.centerFG_circle.lineLength_inPix_list == s.lineLength_inPix );
nLines = p.calibration.centerFG_circle.nLines(ind);

% define line positions
xy = defineLinesInRect(p.rects.centerFG, nLines, s.lineLength_inPix, s.angleFG);

% draw lines to the backbuffer and save textures
Screen('FillRect', w, p.stim.lineBGcolor);
Screen('DrawLines', w, xy, p.stim.center.lineWidth_inPix, p.stim.lineColor);

fg = Screen('GetImage', w, p.rects.centerFG, 'backBuffer');

% add oval alpha blending layer to FG stim
fg(:,:,end+1) = p.masks.centerFG;

tex_stim.fg = Screen('MakeTexture', w, fg);


% reset BG color
Screen('FillRect', w, p.stim.BGcolor);

end