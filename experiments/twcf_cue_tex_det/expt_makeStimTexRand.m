function tex_stim = expt_makeStimTexRand(w, p, s)
% tex_stim = twcf_makeStimTexRand(w, p, s)
%
% w - psychtoolbox window pointer
% p - parameter struct
% s - stimulus struct, e.g. s = p.stim.rand

% get nLines
nLines = p.calibration.random.nLines;

% define line positions in current quadrant
xy = defineRandomLinesInRect(p.rects.window, nLines, s.lineLength_inPix_list);

% draw lines to the backbuffer and save textures
Screen('FillRect', w, p.stim.lineBGcolor);
Screen('DrawLines', w, xy, s.lineWidth_inPix, p.stim.lineColor);
bg = Screen('GetImage', w, p.rects.window, 'backBuffer');
tex_stim.bg = Screen('MakeTexture', w, bg);

% reset BG color
Screen('FillRect', w, p.stim.BGcolor);

end