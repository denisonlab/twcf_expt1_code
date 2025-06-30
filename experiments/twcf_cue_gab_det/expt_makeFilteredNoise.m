function [filteredNoiseIm, numGenerated, pass] = expt_makeFilteredNoise(imSize, contrast, ...
    orientation, orientBandwidth, ...
    sfBandLow, sfBandHigh, ...
    pixelsPerDegree, maskWithAperture, filterSpecial)

% function filteredNoiseIm = makeFilteredNoise(imSize, contrast, ...
%     orientation, orientBandwidth, ...
%     sfBandLow, sfBandHigh, ...
%     pixelsPerDegree, maskWithAperture, filterSpecial)
%
% INPUTS:
% imSize is the 1-element image size in degrees
% orientation is the main orientation in degrees
% orientBandwidth is the width of orientation bandwidth in degrees
% contrast is the contrast from 0-1
% spatialFrequency is the main spatial frequency in cpd
% sfBandwidth is the width of the spatial frequency bandwidth in cpd
% pixelsPerDegree is pixels per degree of visual angle
% maskWithAperture is 1 if want to mask with an aperture, 0 if not. Note
%   that the imSize will always determine the size of the visible noise
%   patch. If we mask with an aperture, the size of the entire image will be
%   1.3 times larger than if we don't (the aperture is added around the noise patch).
% filterSpecial (optional): 
%   'cross' will give specified orientation + orthogonal orientation
%   'symmetric' will give specific orientation + orientation mirrored across
% vertical 
%   % 'allOrientations' will give all orientations
% applies a correction to fix mean luminance of the im to input contrast 

%% example inputs
if nargin==0
    imSize = 1; % degrees
    contrast = 1;
    orientation = 0;
    orientBandwidth = 10;
    sfBandLow = 1.5/2;
    sfBandHigh = 1.5*2;
    pixelsPerDegree = 100;
    maskWithAperture = 1;
end

if ~exist('filterSpecial','var')
    filterSpecial = 'none';
end

%% minor calculations
samplingRate = pixelsPerDegree;
fNyquist = samplingRate/2;
fLow = sfBandLow/fNyquist;
fHigh = sfBandHigh/fNyquist;
sz = round(imSize*pixelsPerDegree);

%% make smoothing filter
[x1,y1]=meshgrid(-10:10,-10:10);
sigma=1/3*6;
smoothfilter = 1*exp((-2.77*x1.^2)/(2.35*sigma)^2).*exp((-2.77*y1.^2)/(2.35*sigma)^2); 

%% make aperture
if maskWithAperture
    ap = ones(round(sz * 1.3), round(sz * 1.3));
    center = sz * 1.3/2;
    for i=1:sz * 1.3
        for j=1:sz * 1.3
            R(i,j)=sqrt(((i-center).^2)+((j-center).^2));
        end
    end
    out_index_L=find(R>sz/2);
    ap(out_index_L) = 0;
    aperture = filter2(fspecial('gaussian', round(sz/2), round(sz/8)), ap);
else
    aperture = ones(sz);
end

%% make filters
oFilter = OrientationBandpass(length(aperture), orientation - orientBandwidth/2, orientation + orientBandwidth/2);
fFilter = Bandpass2(length(aperture), fLow, fHigh);

switch filterSpecial
    case 'cross'
        oFilter = oFilter | oFilter';
    case 'symmetric'
        oFilter2 = OrientationBandpass(length(aperture), (-orientation)- orientBandwidth/2, (-orientation) + orientBandwidth/2);
        oFilter = oFilter | oFilter2; 
    case 'allOrientations'
        oFilter = ones(size(oFilter)); 
    otherwise 
end
oFilter = filter2(smoothfilter, oFilter);
fFilter = filter2(smoothfilter, fFilter);
filter = oFilter.*fFilter;

%% make noise 
pass = 0; % regenerate until luminance check is passed; 
numGenerated = 0; 

while ~pass
    clear noise 
    noise = normrnd(0, 1, length(aperture), length(aperture));
    fn = fftshift(fft2(noise));
    filteredNoise = real(ifft2(ifftshift(filter.*fn)));

    filteredNoiseS = Scale(filteredNoise);

    filteredNoiseIm = contrast * (filteredNoiseS-0.5) .* aperture + 0.5;

    %% check and correct mean luminance
    correctionType = 'regenerateUntilPass'; % 'regenerateUntilPass' % 'luminanceMeanShift'
    switch correctionType
        case 'luminanceMeanShift'
            buffer = 0.05;
            correctionCenter = 0.5-mean(filteredNoiseIm(filteredNoiseIm<1-buffer | filteredNoiseIm>buffer),'all');
            for iR = 1:size(filteredNoiseIm,1)
                for iC = 1:size(filteredNoiseIm,2)
                    if filteredNoiseIm(iR,iC) < 1-buffer || filteredNoiseIm(iR,iC) > buffer
                        imCorrected(iR,iC) = filteredNoiseIm(iR,iC) + correctionCenter;
                    else
                        imCorrected(iR,iC) = filteredNoiseIm(iR,iC);
                    end
                end
            end
        case 'regenerateUntilPass'
            criteria = 0.02; % mean luminance pass criteria, within ± criteria
            meanLuminance = mean(filteredNoiseIm,'all'); 
            if 0.5 - meanLuminance > criteria || 0.5 - meanLuminance < -criteria 
                pass = 0; 
            else
                pass = 1; 
                imCorrected = filteredNoiseIm; 
            end
    end
    numGenerated = numGenerated+1; 
end

%% Change outputs
clear filteredNoiseIm 
filteredNoiseIm = imCorrected; 

%% show the image
% figure
% subplot(2,1,1)
% imshow(filteredNoiseS)
% subplot(2,1,2)
% imshow(filteredNoiseIm)

        
