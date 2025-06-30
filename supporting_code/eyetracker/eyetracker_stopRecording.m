function eyetracker_stopRecording(w, p)
%eyeData = eyetracker_stopRecording(w, p) % makp removed the output
%argument 4/14/2022

%eyeData = [];

%if dir for eyedata doesn't exist, create it
if ~exist([p.setup.dataDir '/eyedata/'],'dir')
    mkdir([p.setup.dataDir '/eyedata/'])
end

switch p.setup.site
    case 'UCI'

        % Stop buffering data to the library
        crsLiveTrackStopTracking;
        
        % Get ALL the data we collected through this whole block
        eyeData = crsLiveTrackGetBufferedEyePositions;

        % Clear the data in the buffer
        crsLiveTrackClearDataBuffer;
        
        % Close LiveTrack
        crsLiveTrackClose;
        
        % Save the entire eyetracking buffer to a file
        dataFilename = [p.setup.dataFilename '_eyefile.mat'];
        save([p.setup.dataDir '/eyedata/' dataFilename], 'p','eyeData');
    
    case 'BU'

        % makp edited to move this outside the switch 4/14/2022
%         %if dir for eyedata doesn't exist, create it
%         if ~exist([p.setup.dataDir '/eyedata/'],'dir')
%             mkdir([p.setup.dataDir '/eyedata/'])
%         end
        
        %use same eyefile name as when initializing
        if length(p.setup.subjectID) < 3 
            subjectID = p.setup.subjectID; 
        else
            subjectID = p.setup.subjectID(1:3);
        end
        eyeFile = sprintf('%s%s', subjectID, p.setup.exptDate(5:end));

        %grab eyedata
        rd_eyeLink('eyestop',w,{eyeFile, [p.setup.dataDir '/eyedata/']});
        
        %convert to informative name
        dataFilename = [p.setup.dataFilename '_eyefile.edf'];
        movefile([p.setup.dataDir 'eyedata/' eyeFile '.edf'], [p.setup.dataDir 'eyedata/'  dataFilename]);

end