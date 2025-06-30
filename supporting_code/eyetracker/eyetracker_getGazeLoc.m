function [gazeLocL_inPix, gazeLocR_inPix, droppedSamples] = eyetracker_getGazeLoc(w, p)
% [gazeLocL_inPix, gazeLocR_inPix, nDroppedSamples] = eyetracker_getGazeLoc(w, p)
%
% Get current gaze location for each eye, expressed in terms of the
% psychtoolbox pixel coordinate system where (0,0) is the upper-left-most
% pixel and values > 1 indicate rightward and downward shifts from the
% origin. This is computed separately for the UCI and BU sites.
%
% gazeLocL_inPix is a 2x1 array holding the x (rightward shift) and y
% (downward shift) pixel coordinates of the current gaze location for the
% left eye. 
%
% gazeLocR_inPix is the same for the right eye. Note that currently
% separate eye locations are computed only for the UCI setup. For BU setup,
% both gazeLocL_inPix and gazeLocR_inPix return eye position of an single
% eye.
%
% droppedSamples is a struct with the following fields:
% * nL : the number of dropped samples for the left eye. At UCI, there are 
% 15 samples collected with each fixation check, so droppedSamples.nL <= 15. 
% At BU, there is only 1 sample collected with each fixation check, so 
% droppedSamples.nL <= 1.
% * nR : same as droppedSamples.nL but for right eye.
% * pL : proportion of dropped samples in left eye.
% * pR : proportion of dropped samples in right eye.

switch p.setup.site
    case 'UCI'
        
        % get current eye position for most recent sample
        bufferLength = 15; % corresponds to a buffer of 30 ms @ 500 Hz sampling, consistent w/ value used in LiveTrack demo scripts
        Data = crsLiveTrackGetLatestEyePosition(bufferLength);

        % crsLiveTrack marks blinks / missing data for a sample s by
        % setting Data.mmPositions(s,:) = 0. unfortunately this can give
        % the mistaken impression that fixation in the x and y coordinates
        % (i.e. Data.mmPositions(s,1:2)) is perfectly at fixation when
        % actually the data is missing! to control for this, we can set the
        % values for these samples to NaN.
        f = Data.mmPositions(:,3) == 0;     % third column (distance from screen in mm) is only 0 when sample is missing
        Data.mmPositions(f,:)     = NaN;    % replace dropped samples with NaN
        droppedSamples.nL         = sum(f); % count # of dropped samples
        
        f = Data.mmPositionsRight(:,3) == 0;     % third column (distance from screen in mm) is only 0 when sample is missing
        Data.mmPositionsRight(f,:)     = NaN;    % replace dropped samples with NaN
        droppedSamples.nR              = sum(f); % count # of dropped samples

        droppedSamples.pL = droppedSamples.nL / bufferLength;
        droppedSamples.pR = droppedSamples.nR / bufferLength;
        
        % compute gaze location in psychtoolbox pixel coordinates
        % - crsLiveTrack returns eye position in terms of mm from the center
        % of the screen, which functions as the (0,0) origin
        % - thus we need to convert mm position to pixel position, then
        % shift the origin (0,0) to the upper left of the screen, to
        % express gaze location in the PTB pixel coordinate system
        gazeLocL_inPix = round( nanmean(Data.mmPositions(:,[1,2]))      .* p.screen.pixels_perMm_WH + [p.rects.midW, p.rects.midH] );
        gazeLocR_inPix = round( nanmean(Data.mmPositionsRight(:,[1,2])) .* p.screen.pixels_perMm_WH + [p.rects.midW, p.rects.midH] );
        
    case 'BU'

        % Check that we are recording
        err=Eyelink('CheckRecording');
        if err~=0
            rd_eyeLink('startrecording', w, p.eyetracker.el);
        end

        % determine recorded eye
        evt = Eyelink('newestfloatsample');
        domEye = find(evt.gx ~= -32768);
        
        % if tracking binocularly, just select one eye to be dominant
        if numel(domEye)>1
            domEye = domEye(1);
        end
        
        %Eyelink('Message', 'FIX_CHECK');
        
        % get eye position
        if ~isempty(evt.gx(domEye))
            x = evt.gx(domEye);
        else
            x = -Inf;
        end
        
        if ~isempty(evt.gy(domEye))
            y = evt.gy(domEye);
        else
            y = -Inf;
        end
        
        % gaze location is already expressed in the PTB pixel coordinate
        % system, so no conversion is necessary
        gazeLocL_inPix = [x, y];
        gazeLocR_inPix = gazeLocL_inPix;
        
        if any(isinf(gazeLocL_inPix))
            droppedSamples.nL = 1;
            droppedSamples.nR = 1;
            droppedSamples.pL = 1;
            droppedSamples.pR = 1;            
        else
            droppedSamples.nL = 0;
            droppedSamples.nR = 0;
            droppedSamples.pL = 0;
            droppedSamples.pR = 0;    
        end            

end

end