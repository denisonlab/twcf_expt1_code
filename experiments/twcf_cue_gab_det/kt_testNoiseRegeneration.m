% April 14, 2023 

for i = 1:10000

orientation = 45;
orientBandwidth = 10;
sfBandLow =1/2;
sfBandHigh = 1*2; % 1.5
maskWithAperture = 0;
noiseContrastRaw = 1;

[filteredNoiseIm, numGenerated(i), pass] = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrastRaw, ...
    orientation, orientBandwidth, ...
    sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'allOrientations');
end

%% plot 
figure
hold on 
figureStyle
histogram(numGenerated)
ylabel('Count')
xlabel('Number of noise generations until pass')
figTitle = sprintf('mean luminance criteria: 0.5 ± 0.02\nmax # generated = %d, mean # generated = %0.2f', max(numGenerated), mean(numGenerated)); 
title(sprintf(figTitle))

%% check test threshold data 
filename = '/Users/kantian/Dropbox/github/TWCF_FOHO/twcf_expt1_data_offsite/twcf_cue_gab_det/testrand/thresholding/twcf_cue_gab_det_offsite_testrand_thresholding_20230414_175839_trial_6_of_block_1.mat'; 
load(filename)

%% 
for i_trial = 1:6
    rng(data.RNGseed{i_trial})
    [stimRegen(i_trial).gab_stim, numGenerated] = expt_remakeStimGabPeriph(p, data); 

%     orientation = 45;
%     orientBandwidth = 10;
%     sfBandLow =1/2;
%     sfBandHigh = 1*2; % 1.5
%     maskWithAperture = 0;
%     noiseContrastRaw = 1;
% 
%     [filteredNoiseIm, numGenerated(i_trial), pass] = expt_makeFilteredNoise(p.stim.periph.circleWidth_inDeg, noiseContrastRaw, ...
%         orientation, orientBandwidth, ...
%         sfBandLow, sfBandHigh, p.ppd, maskWithAperture,'allOrientations');
end

%% diplay and save
for i_trial = 1:6
    figure
    sgtitle(sprintf('regenerated noise\ntrial = %d',i_trial))
    for i_quad = 1:4
        if i_quad==1
            i_plot = 1; 
        elseif i_quad==2
            i_plot = 2; 
        elseif i_quad==3
            i_plot = 4; 
        elseif i_quad==4
            i_plot = 3; 
        end
        subplot (2,2,i_plot)
        hold on 
        axis square 
        figureStyle
        clims = [0 255]; 
        im = stimRegen(i_trial).gab_stim(i_quad).fg; 
        imagesc(flipud(im),clims)
        colormap(gray)
        xlim([0 size(im,1)])
        ylim([0 size(im,1)])

    end
    noiseFilename = sprintf('%s/screenshot/regenerate_%d.png',cd, i_trial);
    saveas(gcf,noiseFilename)
end





