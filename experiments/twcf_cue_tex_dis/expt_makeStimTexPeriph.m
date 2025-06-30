function tex_stim = expt_makeStimTexPeriph(w, p, s)
% tex_stim = twcf_makeStimTexPeriph(w, p, s)
%
% w - psychtoolbox window pointer
% p - parameter struct
% s - stimulus struct, e.g. s = p.stim.periph
%
% s must also have the fields listed below, where each field is a 1x4 vector.
% indeces 1-4 corresponding to upper left, upper right, lower right, and 
% lower left quadrants of the screen, respectively.
%
% s.angle_FG_all         - angles of lines in FG in each quadrant
% s.angle_BG_all         - angles of lines in BG in each quadrant
% s.lineLength_inPix_all - length of lines in each quadrant
% % % s.lineLengthID_all     - index of s.lineLength_inPix_list for each quadrant
% s.stimID_all           - type of FG figure presented in each quadrant
%                          0 --> none, 1 --> vertical oval, 2 --> horizontal oval, 3 --> circle


%% draw BG lines

for i = 1:4
    
    % get nLines
%     nLines = p.calibration.periphBG.nLines( s.lineLengthID_all(i) );
    ind = find( p.calibration.periphBG.lineLength_inPix_list == s.lineLength_inPix_all(i) );
    nLines = p.calibration.periphBG.nLines(ind);
    
    % define line positions in current quadrant
    xy = defineLinesInRect(p.rects.periphBG(:,i), nLines, s.lineLength_inPix_all(i), s.angleBG_all(i));
    
    % draw lines to the backbuffer and save textures
    Screen('FillRect', w, p.stim.lineBGcolor);
    Screen('DrawLines', w, xy, p.stim.periph.lineWidth_inPix, p.stim.lineColor);
    bg = Screen('GetImage', w, p.rects.periphBG(:,i), 'backBuffer');
    tex_stim(i).bg = Screen('MakeTexture', w, bg);

end


%% draw FG lines

% s.stimID_all - type of FG figure presented in each quadrant
%                0 --> none, 1 --> vertical oval, 2 --> horizontal oval, 3 --> circle

for i = 1:4
    
    if s.stimID_all(i) == 0
        tex_stim(i).fg = [];
        
    else
    
        rectFG = p.rects.periphFG{ s.stimID_all(i) }(:,i);
        mask   = p.masks.periphFG{ s.stimID_all(i) }{i};

        % get nLines
%         nLines = p.calibration.periphFG_oval.nLines( s.lineLengthID_all(i) );
        ind = find( p.calibration.periphFG_oval.lineLength_inPix_list == s.lineLength_inPix_all(i) );
        nLines = p.calibration.periphFG_oval.nLines(ind);
        
        % define line positions in current quadrant
        xy = defineLinesInRect(rectFG, nLines, s.lineLength_inPix_all(i), s.angleFG_all(i));

        % draw lines to the backbuffer and save textures
        Screen('FillRect', w, p.stim.lineBGcolor);
        Screen('DrawLines', w, xy, p.stim.periph.lineWidth_inPix, p.stim.lineColor);

        fg = Screen('GetImage', w, rectFG, 'backBuffer');

        % add oval alpha blending layer to FG stim
        fg(:,:,end+1) = mask;

        tex_stim(i).fg = Screen('MakeTexture', w, fg);
    end
end


% reset BG color
Screen('FillRect', w, p.stim.BGcolor);

end