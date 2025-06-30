function info = getTypeInfo(type, p)

%% get relevant data for the requested calibration type

switch type
    
    case 'periphBG'
        info.lineRect              = p.rects.periphBG(:,1)'; % upper left BG rect
        info.innerRect             = [];
        info.mask                  = [];
        info.nPixelsTotal          = RectWidth(info.lineRect) * RectHeight(info.lineRect); % # pixels in the BG rect
        info.lineLength_inPix_list = p.calibration.lineLength_inPix_min : 1 : p.calibration.lineLength_inPix_max_periph;
        info.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;
                
    case 'periphFG_oval'
        info.lineRect              = p.rects.periphFG{1}(:,1)'; % upper left FG rect
        info.innerRect             = [];
        info.mask                  = p.masks.periphFG{1}{1};    % vertical oval
        info.nPixelsTotal          = sum(info.mask(:) == 255);  % # of pixels in the FG oval
        info.lineLength_inPix_list = p.calibration.lineLength_inPix_min : 1 : p.calibration.lineLength_inPix_max_periph;
        info.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;
        
    case 'periphFG_circle'
        info.lineRect              = p.rects.periphFG{3}(:,1)'; % upper left FG circle
        info.innerRect             = [];
        info.mask                  = p.masks.periphFG{3}{1};    % circle
        info.nPixelsTotal          = sum(info.mask(:) == 255);  % # of pixels in the FG circle
        info.lineLength_inPix_list = p.calibration.lineLength_inPix_min : 1 : p.calibration.lineLength_inPix_max_periph;
        info.lineWidth_inPix       = p.stim.periph.lineWidth_inPix;
        
    case 'centerBG_annulus'
        info.lineRect              = p.rects.centerBG;
        info.innerRect             = p.rects.centerFG;
        info.mask                  = p.masks.centerBGannulus;
        info.nPixelsTotal          = sum(info.mask(:) == 255); % # of pixels in the BG annulus
        info.lineLength_inPix_list = p.calibration.lineLength_inPix_min : 1 : p.calibration.lineLength_inPix_max_center;
        info.lineWidth_inPix       = p.stim.center.lineWidth_inPix;
        
    case 'centerFG_circle'
        info.lineRect              = p.rects.centerFG;
        info.innerRect             = [];
        info.mask                  = p.masks.centerFG;
        info.nPixelsTotal          = sum(info.mask(:) == 255); % # of pixels in the FG circle
        info.lineLength_inPix_list = p.calibration.lineLength_inPix_min : 1 : p.calibration.lineLength_inPix_max_center;
        info.lineWidth_inPix       = p.stim.center.lineWidth_inPix;
        
    case 'random'
        info.lineRect              = p.rects.window;
        info.innerRect             = [];
        info.mask                  = [];
        info.nPixelsTotal          = RectWidth(info.lineRect) * RectHeight(info.lineRect); % # pixels in the BG rect
        info.lineLength_inPix_list = p.stim.rand.lineLength_inPix_list;
        info.lineWidth_inPix       = p.stim.rand.lineWidth_inPix;
        
end