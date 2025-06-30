function expt_makeStimGabPeriph_screenshot(w, p, s, noiseContrast, contrast)

% Screenshot only - delete or incorporate with expt_takeScreenshot.m
% w - psychtoolbox window pointer
% p - parameter struct
% s - stimulus struct, e.g. s = p.stim.periph
%
% s must also have the fields listed below, where each field is a 1x4 vector.
% indeces 1-4 corresponding to upper left, upper right, lower right, and
% lower left quadrants of the screen, respectively.
% 
% s.stimID_all           - type of gabor presented in each quadrant
%                        - 0 --> none, 
%                        - 1 --> tilt -45 from vertical 
%                        - 2 --> tilt +45 from vertical 

%% TO DELETE, from texture version 
% s.angle_FG_all         - angles of lines in FG in each quadrant
% s.angle_BG_all         - angles of lines in BG in each quadrant
% s.lineLength_inPix_all - length of lines in each quadrant
% % % s.lineLengthID_all     - index of s.lineLength_inPix_list for each quadrant

%% Make peripheral stimuli textures (noise, noisy grating) 
% s.stimID_all - type of FG figure presented in each quadrant
%                0 --> none, 1 --> vertical oval, 2 --> horizontal oval, 3 --> circle
% for gabor version adjusted to 0 -->none, 1--> -45, 2--> 45
% horizontal patch

for i = 1 % :4 % cycle peripheral quadrants 

    %% Draw noise 
    rectBG = p.rects.periphFG{2}(:,i); % only need FG rects now, same size % p.rects.periphBG(:,i);
    noiseimgSz = [p.stim.periph.circleWidth_inDeg * p.ppd p.stim.periph.circleWidth_inDeg * p.ppd]; % [rectBG(3)-rectBG(1), rectBG(4)-rectBG(2)]; 
    noiseimg = [];
    % noiseContrast = 0.2;
    % need to center noise around 0 
    % p.stim.gabor.noiseType = 'uniform'; % DELETE for debugging only 
    switch p.stim.gab.noiseType
        case 'uniform' %  uniform random noise
            % Center noise on bg color
            % noiseimg = (p.stim.BGcolor/255-noiseContrast/2) + (rand(rectBG(3)-rectBG(1), rectBG(4)-rectBG(2))) .* noiseContrast;
            noiseimg = (0.5-noiseContrast/2) + (rand(noiseimgSz)) .* noiseContrast;
        case 'gaussian' % normally distributed noise centered around mean and sd 
            noiseSD = 0.3;
            noiseimg = (noiseSD*rand(noiseimgSz) + noiseContrast);
        case 'filteredOriSF' % Noise bandpass filtered around gabor properties (orientation and sf) 
            orientation = 45;
            orientBandwidth = 10;
            sfBandLow = p.stim.gab.gratingSF/2;
            sfBandHigh = p.stim.gab.gratingSF*2; % 1.5
            maskWithAperture = 0;

            noiseimg = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrast, ...
                orientation, orientBandwidth, ...
                sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'symmetric');
        case 'filteredSF' % Noise bandpass filtered around gabor properties (sf only)
            orientation = 45;
            orientBandwidth = 10;
            sfBandLow = p.stim.gab.gratingSF/2;
            sfBandHigh = p.stim.gab.gratingSF*2; % 1.5
            maskWithAperture = 0;
            
            noiseimg = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrast, ...
                orientation, orientBandwidth, ...
                sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'allOrientations');
        case 'highPassFilter' % noise filtered to have SFs equal to and greater than the grating SF
            orientation = 45; % needs input but won't be used 
            orientBandwidth = 10; 
            sfBandLow = p.stim.gab.gratingSF;
            sfBandHigh = p.ppd/2; % 1.5 % calculate max sf based on px size, is ppd appropriate? 
            % if period = 1/f and minimum period is 2 pixels, then maximum
            % frequency is p.ppd/2? 
            maskWithAperture = 0;
            
            noiseimg = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrast, ...
                orientation, orientBandwidth, ...
                sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'allOrientations');
        case 'OOF' % 1/f noise (pink noise) 
            error('OOF noise not specified') 
    end

    % Add aperture
    imIn = noiseimg; 
    switch p.stim.gab.aperture
        case 'square'
            [noiseimgap,ap] = rd_aperture(imIn,p.stim.gab.aperture, p.stim.gab.rad);
        case {'gaussian','cosine'}
            [noiseimgap,ap] = rd_aperture(imIn,p.stim.gab.aperture, p.stim.gab.rad, p.stim.gab.apertureEdgeWidth_inPix);
    end

    % Scale grating to 255 color space
    p.stim.max = 255; % 1, 255
    noiseimgap = noiseimgap .* p.stim.max;

    % Turn pixels outside of aperture into BG color
    ap = logical(ap); 
    noiseimgap(~ap) = p.stim.BGcolor;

    % Convert noise matrix to texture
    gab_stim(i).bg = Screen('MakeTexture', w, noiseimgap);
    
%     p.debug = 1; 
%     if p.debug 
%     Screen('DrawTexture',w,gab_stim(i).bg,[], p.rects.periphFG{2}(:,1)) 
%     Screen('Flip', w);
%     end
    
    %% Draw gabor     
    if s.stimID_all(i) == 0
        gab_stim(i).fg = []; % Target absent      
    else 
        % rectFG = p.rects.periphFG{ s.stimID_all(i) }(:,i);
        rectFG = p.rects.periphFG{2}(:,i); % only need one of the FG rects
        
        % Set tilt
        if s.stimID_all(i)==1
            tilt = -45;
        elseif s.stimID_all(i)==2
            tilt = 45;
        end

        % The last var is contrast, currently set to 0.5 for testing
        % will it work to set grating square size to 1 deg more than
        % circleWidth? why did I add a buffer 
        tilt = 45; % delete for debugging only 
        % contrast = 0; % move to params 
        
        % why did I add buffer here p.stim.gab.buffer
        grating = expt_grating(p.ppd, p.stim.periph.circleWidth_inDeg, p.stim.gab.gratingSF,...
            tilt, p.stim.gab.phase, contrast);
    
        % Add noise
        noiseimg = noiseimg - 0.5; % center noise on 0 
        grating = grating+noiseimg; 

        % Add aperture 
        switch p.stim.gab.aperture
            case 'square'
                [im,ap] = rd_aperture(grating,p.stim.gab.aperture, p.stim.gab.rad);
            case {'gaussian', 'cosine'}
                [im,ap] = rd_aperture(grating,p.stim.gab.aperture, p.stim.gab.rad, p.stim.gab.apertureEdgeWidth_inPix);
        end

        % Scale grating to 255 color space 
        p.stim.max = 255; % 1, 255
        im = im .* p.stim.max; 

        % Turn pixels outside of aperture into BG color
        apL = logical(ap); 
        im(~apL) = p.stim.BGcolor;

        % Make texture
        gab_stim(i).fg = Screen('MakeTexture', w, im);
        
        p.debug = 1;
        if p.debug
            Screen('DrawTexture',w,gab_stim(i).fg,[], p.rects.periphFG{2}(:,1))
            Screen('Flip', w);
            
            current_display = Screen('GetImage', w, [555+32; 0; 1038-32; 419]); % , p.rects.periphFG{2}(:,3));
            filename = sprintf('screenshot/%s_%0.2fnoise_%0.2fgrating.png', p.stim.gabor.noiseType,noiseContrast,contrast);
            imwrite(current_display, filename);
            
        end
        
%         Screen('DrawTexture', w, tex, [], rectFG);
%         gab = Screen('GetImage', w, p.rects.window, 'backBuffer');
    
    end
end

% reset BG color
Screen('FillRect', w, p.stim.BGcolor);

end