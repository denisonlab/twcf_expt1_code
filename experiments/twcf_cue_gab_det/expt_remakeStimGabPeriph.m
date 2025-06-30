function [gab_stim, numGenerated] = expt_remakeStimGabPeriph(p, data)
% tex_stim = twcf_makeStimGabPeriph(w, p, s)
%
% w - psychtoolbox window pointer
% p - parameter struct
% s - stimulus struct, e.g. s = p.stim.periph
%
% s must also have the fields listed below, where each field is a 1x4 vector.
% indeces 1-4 corresponding to upper left, upper right, lower right, and
% lower left quadrants of the screen, respectively.
% 
% saves state of rng seed to recreate noise ims 
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

for i = 1:4 % cycle peripheral quadrants 
    noiseContrast = p.stim.gab.noiseContrast;

    %% Generate noise
    rectBG = p.rects.periphFG{2}(:,i); % only need FG rects now, same size % p.rects.periphBG(:,i);
    noiseimgSz = round([p.stim.periph.circleWidth_inDeg * p.ppd p.stim.periph.circleWidth_inDeg * p.ppd]); % [rectBG(3)-rectBG(1), rectBG(4)-rectBG(2)]; 
    % need to center noise around 0 
    % p.stim.gabor.noiseType = 'uniform'; % DELETE for debugging only 
    % make 2 noiseimgRaws, 1 for prestim pedetal, and 1 during target
    for iNoise = 1:2 % Generate prestim and target noise 
        clear noiseimgRaw % noise scaled 0-1
        clear noiseimg % noise scaled by noise contrast
        % save state of rng
%         if iNoise==1
%             % rngstate_prestim(i) = rng; % do not save rng for speed 
%         elseif iNoise==2
%             % rngstate_stim(i) = rng; 
%         end
        switch p.stim.gab.noiseType
            case 'uniform' %  uniform random noise
                % Center noise on bg color
                % noiseimg nnn= (p.stim.BGcolor/255-noiseContrast/2) + (rand(rectBG(3)-rectBG(1), rectBG(4)-rectBG(2))) .* noiseContrast;
                noiseimgRaw = (rand(noiseimgSz));

            case 'gaussian' % normally distributed noise centered around mean and sd
                noiseSD = 0.3;
                noiseimgRaw = noiseSD*rand(noiseimgSz);
                noiseimgRaw = noiseimgRaw + noiseContrast;
                error('gaussian noise not fully defined')

            case 'filteredOriSF' % Noise bandpass filtered around gabor properties (orientation and sf)
                orientation = 45;
                orientBandwidth = 10;
                sfBandLow = p.stim.gab.gratingSF/2;
                sfBandHigh = p.stim.gab.gratingSF*2; % 1.5
                maskWithAperture = 0;
                noiseContrastRaw = 1;

                noiseimgRaw = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrastRaw, ...
                    orientation, orientBandwidth, ...
                    sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'symmetric');

            case 'filteredSF' % Noise bandpass filtered around gabor properties (sf only)
                orientation = 45; % arbitrary, will override with 'allOrientations'
                orientBandwidth = 10; % arbitrary, will override with 'allOrientations'
                sfBandLow = p.stim.gab.gratingSF/2;
                sfBandHigh = p.stim.gab.gratingSF*2; % 1.5
                maskWithAperture = 0;
                noiseContrastRaw = 1;
                [noiseimgRaw, numGenerated] = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrastRaw, ...
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
                noiseContrastRaw = 1;

                noiseimgRaw = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrastRaw, ...
                    orientation, orientBandwidth, ...
                    sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'allOrientations');
                error('high pass filter noise - check before using')

            case 'OOF' % 1/f noise (pink noise)
                error('OOF noise not yet defined')
        end
        noiseimgRaws(iNoise,:,:) = noiseimgRaw; % save the 0-1 scaled noise
    end

    noisePrestim = squeeze(noiseimgRaws(1,:,:)); 
    noiseTarget  = squeeze(noiseimgRaws(2,:,:)); 
    
    % Center noise on 0.5 and scale to specified contrast 
    noiseimg = (0.5-noiseContrast/2) + noisePrestim .* noiseContrast;

    % Add aperture
    switch p.stim.gab.aperture
        case 'square'
            [noiseimgap,ap] = rd_aperture(noiseimg,p.stim.gab.aperture, p.stim.gab.rad);
        case {'gaussian','cosine'}
            [noiseimgap,ap] = rd_aperture(noiseimg,p.stim.gab.aperture, p.stim.gab.rad, p.stim.gab.apertureEdgeWidth_inPix);
    end

    % Scale noise from [0,1] to [0,255[ color space
    p.stim.max = 255; % 1, 255, move to parameters? 
    noiseimgap = noiseimgap .* p.stim.max;

    % Turn pixels outside of aperture into BG color
    ap = logical(ap); 
    noiseimgap(~ap) = p.stim.BGcolor;

    % Save noise array 
    gab_stim(i).bg = noiseimgap; 

    % Convert noise matrix to texture
    % gab_stim(i).bg = Screen('MakeTexture', w, noiseimgap);
    
%     p.debug = 1; 
%     if p.debug 
%     Screen('DrawTexture',w,gab_stim(i).bg,[], p.rects.periphFG{2}(:,1)) 
%     Screen('Flip', w);
%     end
    
    %% Draw gabor  
    % Get contrasts
    gratingContrast = data.contrast_all(i);
    noiseContrast = p.stim.gab.noiseContrast;
%     if p.setup.isPiloting
%         % noiseContrast = 1 - gratingContrast; % independent pre-target and target noise contrasts
%         noiseContrast = p.stim.gab.noiseContrast;
%     else
%         noiseContrast = p.stim.gab.noiseContrast; % 0.2
%     end
    clear noiseimg

    if data.stimID_all(i) == 0 % Target absent
        % Center noise on 0.5 and scale to specified contrast 
        noiseimg = (0.5-noiseContrast/2) + noiseTarget .* noiseContrast;

        grating = noiseimg; % Target is updated noise, no grating
        % gab_stim(i).fg = [];     
    else % Target present
        % rectFG = p.rects.periphFG{ s.stimID_all(i) }(:,i);
        % rectFG = p.rects.periphFG{2}(:,i); % only need one of the FG rects
        
        % Center noise on 0 and scale to specified contrast 
        noiseimg = (0-noiseContrast/2) + noiseTarget .* noiseContrast;

        % Set tilt
        if data.stimID_all(i)==1
            tilt = -45;
        elseif data.stimID_all(i)==2
            tilt = 45;
        end

        grating = expt_grating(p.ppd, p.stim.periph.circleWidth_inDeg, p.stim.gab.gratingSF,...
            tilt, p.stim.gab.phase, gratingContrast);
    
        % Add grating and noise
        grating = grating + noiseimg;
    end

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

    % Save texture array 
    gab_stim(i).fg = im; 

    % Make texture
    % gab_stim(i).fg = Screen('MakeTexture', w, im);

    %         p.debug = 1;
    %         if p.debug
    %             Screen('DrawTexture',w,gab_stim(i).fg,[], p.rects.periphFG{2}(:,1))
    %             Screen('Flip', w);
    %
    %             current_display = Screen('GetImage', w, [555+32; 0; 1038-32; 419]); % , p.rects.periphFG{2}(:,3));
    %             filename = sprintf('screenshot/%s_%0.2fnoise_%0.2fgrating.png', p.stim.gabor.noiseType,noiseContrast,contrast);
    %             imwrite(current_display, filename);
    %
    %         end

    %         Screen('DrawTexture', w, tex, [], rectFG);
    %         gab = Screen('GetImage', w, p.rects.window, 'backBuffer');

end

% reset BG color
% Screen('FillRect', w, p.stim.BGcolor);

end