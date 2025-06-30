function exitNow = expt_instructions(w, p)

%% text settings

sy     = p.text.sy;
sx     = p.text.sx;
wrapat = p.text.wrapat;

%% show 'working on it' screen

DrawFormattedText(w, 'Getting ready...', 'center', 'center'); 
Screen('Flip', w);   

%% wait times

bufferWait = 0.5;
shortWait  = 3;
medWait    = 10;
longWait   = 30;

%% make sample stimuli for pg 1-2

% nLineLengths = length( p.stim.periph.lineLength_inDeg_list );
nContrasts = length( p.stim.gab.contrast_list );

% peripheral textures
s1 = p.stim.periph;
    
% get unique properties for peripheral stim on this trial
% s1.angleBG_all          = [pi/4; 3*pi/4; pi/4; 3*pi/4]; % alternating orientaion
% s1.angleFG_all          = s1.angleBG_all + pi/2;
s1.stimID_all           = [1; 2; 1; 2];                 % figure present 
s1.contrastID_all       = [nContrasts-1; nContrasts-3; nContrasts; nContrasts-2];
s1.contrast_all         = [0.25 0.3 0.35 0.4]; % high contrast for easy s1.gabContrast_list( s1.contrastID_all );

% tex_stim_periph    = expt_makeStimTexPeriph(w, p, s1);
gab_stim_periph = expt_makeStimGabPeriph(w, p, s1);

%% make sample stimuli for pg 3

% angles     = [pi/4; 3*pi/4; pi/4; 3*pi/4];
stimIDs{1} = [0; 1; 0; 0]; 
stimIDs{2} = [1; 0; 2; 0];
stimIDs{3} = [0; 0; 0; 0];
stimIDs{4} = [2; 2; 1; 2]; 

for i = 1:4
    % peripheral textures
    s2(i).s = p.stim.periph;

    % get unique properties for peripheral stim on this trial
    % s2(i).s.angleBG_all          = angles(i) * ones(4,1);
    % s2(i).s.angleFG_all          = s2(i).s.angleBG_all + pi/2;
    s2(i).s.stimID_all           = stimIDs{i};
    % s2(i).s.lineLengthID_all     = [nLineLengths-1; nLineLengths-3; nLineLengths; nLineLengths-2];
    % s2(i).s.lineLength_inPix_all = s2(i).s.lineLength_inPix_list( s2(i).s.lineLengthID_all );
    s2(i).s.contrastID_all        = [nContrasts-1; nContrasts-3; nContrasts; nContrasts-2];
    s2(i).s.contrast_all          = [0.25 0.3 0.35 0.4]; % s2(i).s.gabContrast_list( s2(i).s.contrastID_all );

    s2(i).gab_stim_periph        = expt_makeStimGabPeriph(w, p, s2(i).s);
end

p3                        = p;
p3.stim.gab.noiseContrast = 0; 
s3                        = s2; 
stimIDs{1} = [1; 1; 1; 1]; 
stimIDs{2} = [1; 1; 1; 1];
stimIDs{3} = [2; 2; 2; 2];
for i = 1:3 % gratings with no noise
    s3(i).s.stimID_all           = stimIDs{i};
    s3(i).contrast_all           = repmat(1,[1,7]); 
    s3(i).gab_stim_periph        = expt_makeStimGabPeriph(w, p3, s3(i).s);
end

%% make stimuli for keyboard practice

% make captions
fontSizeMult = 0.6;
fontScaleMult = ceil(p.text.fontSize*fontSizeMult); 
padding = 0; 
resetBGcolor = p.stim.BGcolor; %  p.stim.BGcolor; % 
textOval = {'1 key\n\nsaw grating\n\nsaw orientation\n\nsaw counterclockwise\n-45 deg from vertical',...
    '2 key\n\nsaw grating\n\nguess orientation\n\nguess counterclockwise\n-45 deg from vertical',...
    '3 key\n\ndidn''t see grating\n\nguess orientation\n\nguess counterclockwise\n-45 deg from vertical',...
    '8 key\n\ndidn''t see grating\n\nguess orientation\n\nguess clockwise\n+45 deg from vertical',...
    '9 key\n\nsaw grating\n\nguess orientation\n\nguess clockwise\n+45 deg from vertical',...
    '0 key\n\nsaw grating\n\nsaw orientation\n\nsaw clockwise\n+45 deg from vertical'};
for i = 1:numel(textOval)
    [textTextureOval(i), textRectOval{i}] = makeTextTexture(w, textOval{i}, padding, resetBGcolor, fontScaleMult);
end

% set up oval schematics
ori = [1 1 1 2 2 2];
centers = round( linspace(0, RectWidth(p.rects.window), 9) );
ind = [2 3 4 6 7 8];
for i = 1:6
    [oval, ~, alpha] = imread(['supporting_files/oval' num2str(i)], 'png');
    oval(:, :, 4)    = alpha;
    ovalTex(i)       = Screen('MakeTexture', w, oval);
    ovalRect{i}      = CenterRectOnPoint( ceil(p.rects.periphFG{ori(i)}(:,1)'*.85), centers(ind(i)), p.rects.midH);

    offset = RectHeight(ovalRect{1})/2 + .8*RectHeight(ovalRect{1});
    textRectOval{i} = CenterRectOnPoint( textRectOval{i}, centers(ind(i)), p.rects.midH);
    textRectOval{i} = OffsetRect( textRectOval{i}, 0, offset);
end

%% write text

%% page 1

i = 1;
page{i}     = ['INSTRUCTIONS\n\n* Overview\n\n' ...
               'In this experiment you will be asked to make judgments about visual stimuli.\n\n' ...
               'Specifically, you will be pointed or "cued" to a particular location on the screen and will have to respond:\n' ...
               '(1) Did you see a grating embedded in the noise patch in the cued location?\n' ...
               '(2) If yes, did you see what direction the grating was oriented?\n' ...
               '(3) Was the grating oriented counterclockwise (-45 deg) or clockwise (+45 deg) from vertical?\n\n' ...
               'The experiment is organized into "trials". Each trial begins with the presentation of new visual stimuli ' ...
               'and ends when you enter your response. Trials take about 3-5 seconds to complete.\n\n'];
prompt{i}   =  '__________\nPress any key to continue.';
waitTime(i) = shortWait;

%% page 2

i = i + 1;
page{i}     = ['* Outline\n\n' ...
               'In the first part of the upcoming instructions, we''ll show you examples of the images ' ...
               'you''ll see on each trial.\n\n' ...
               'In the second part, we''ll show you an example of the full sequence of events that occurs on each trial.\n\n' ...
               'In the third part, we''ll mention a few things to keep in mind while doing the task.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 3

i = i + 1;
page{i}     = ['* Details\n\n' ...
               'There''s going to be a lot of information coming at you, but we''ll take things slow, one step at a time. ' ...
               'At any point during the instructions, if you want to go back to read a previous page, you can press the ' ...
               'left arrow key.\n\n' ...
               'After you''ve finished reading the instructions, you will have a chance to ask the experimenter questions. ' ...
               'You''ll also have a chance to practice so that you get used to doing the task before the main experiment begins.\n\n' ...
               'So hang in there! Once you get the hang of it, the task is actually pretty simple to do.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 4

i = i + 1;
page{i}     = ['PART 1 - example images\n\n* Noise patches\n\n' ...
               'OK, let''s start getting into the details!\n\n' ...
               'On each trial, you will see patches of random noise.\n\n' ...
               'Let''s take a look at some examples of noise patches.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of noise patches.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 4, show examples of random textures and oriented textures

%% page 5

i = i + 1;
page{i}     = ['* Gratings\n\nSometimes the noise patches will contain a grating.\n\n' ...
               'A grating is a set of oriented lines.\n\n' ...
               'In the experiment, a grating can be oriented either counterclockwise (-45 deg) or clockwise (+45 deg) from vertical.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of gratings.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 5, show examples of vertical, counterclockwise (-45 deg) and clockwise (+45 deg) gratings

%% page 6 

i = i + 1;
page{i}     = ['* Noisy gratings\n\nIn the experiment, gratings will be embedded in noise.\n\n' ...
               'The noise makes the gratings more challenging to see.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of noisy gratings.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 7

i = i + 1;
page{i}     = ['* Quadrants\n\nIn the main experiment, the screen will be split into 4 sections, called quadrants.\n\n' ...
               'A different noise patch will be shown in each quadrant. Each quadrant may or may not contain a grating.\n\n' ...
               'The grating may be oriented counterclockwise (-45 deg) or clockwise (+45 deg) from vertical.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of noise patches in the 4 quadrants.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 7, show an example of the 4 quadrant stimuli

%% page 8

i = i + 1;
page{i}     = ['* Fixation and black lines\n\nIn the main experiment, a fixation cross will be shown at the center of the screen.\n\n' ...
               'The fixation cross is just a plus sign, like this: +. ' ...
               'When the fixation cross appears, you should lock your eyes onto it and resist any temptation to move your eyes around ' ...
               'on the screen.\n\nAround the fixation cross will be 4 black lines pointing to each quadrant.\n\n'];
               
prompt{i}   = ['__________\nPress any key to see examples of the fixation cross and black lines.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 8, show examples of the aperture w/ fixation and cues

%% page 9

i = i + 1;
page{i}     = ['* Attention cue (shown before the 4 quadrants)\n\nBefore the noise patches in the 4 quadrants are shown, you will be shown an "attention cue." ' ...
               'One or all of the black lines will briefly flash white. These flashes tell you where to direct your attention ' ...
               'for the upcoming stimuli.\n\n' ...
               'Most of the time, only one line will flash white. This tells you which quadrant to attend to. For instance, if the upper left line ' ...
               'flashes white, you should focus your attention on the upper left quadrant.\n\n' ...
               'Most of the time (but not always), you will be asked to provide judgments about stimuli shown in the cued quadrant. ' ...
               'Therefore, attending to the cued quadrant will help prepare you for doing the task.\n\n' ...
               'IMPORTANT: When you are instructed to attend to one part of the screen, shift your attention there without moving your eyes from fixation. ' ...
               'If you move your eyes away from fixation, the trial will end and will be repeated later.\n\n' ...
               'Sometimes, all four lines will flash white. When this happens, you should spread your visual attention evenly over all four quadrants, ' ...
               'while still keeping your gaze locked on the fixation cross. The quadrant you will be asked to provide judgments about will ' ...
               'be chosen randomly in these cases.\n\n'];
               
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 9, show examples of the aperture w/ fixation and pre-cues

%% page 10

i = i + 1;
page{i}     = ['* Response cue (shown after the 4 quadrants)\n\nAfter the noise patches in the 4 quadrants are shown, one of ' ...
               'the 4 black lines will once again briefly flash white. ' ...
               'The flashing white response cue indicates which quadrant you will have to make judgments about. ' ...
               'For instance, if the lower left response cue flashes, that means you''ll have to provide judgments about the patch that was ' ...
               'shown on the lower left.\n\n' ...
               'For the response-cued patch, you will enter your response about whether you saw a grating there, ' ...
               'whether you saw its orientation, and what its shape orientation. More detail on response entry will be coming up shortly.\n\n' ...
               'When the computer has recorded your response, the response cue returns to black and the crosshair at fixation ' ...
               'turns gray. This lets you know that your response was entered successfully and the next trial is going to begin soon.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 11

i = i + 1;
page{i}     = ['PART 2 - Sample trial sequence\n\nNow let''s take a look at the sequence of events that will occur on every trial.\n\n' ...
               'As a reminder, a "trial" is a sequence of events beginning with the presentation of a new set of patches and ending when ' ...
               'you''ve provided your response for the patch in the response-cued quadrant.\n\n' ...
               'In the following screen you''ll have a chance to take a self-paced tour through all the trial stages. ' ...
               'Captions will provide additional information as you go.\n\n' ...
               'To prevent confusion, there will be no option to go back to the previous screen using the left arrow key ' ...
               'during this sample sequence. If you wish to view the sample sequence again, you can press the left arrow ' ...
               'key on the next page of text.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 11, show a self-paced sample trial sequence

%% page 12

i = i + 1;
page{i}     = ['* Response entry\n\nOn each trial you have to decide three things about the patch in the response-cued quadrant:\n' ...
               '(1) Did you see a grating in the response-cued location?\n' ...
               '(2) If you did see a grating, did you see its orientation?\n' ...
               '(3) Was the grating oriented counterclockwise (-45 deg) or clockwise (+45 deg) from vertical?\n\n' ...
               'On the following screen we''ll show you how to enter your response.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back and see the trial sequence again.'];
waitTime(i) = shortWait;

%% after page 12, show keyboard practice

%% page 13

i = i + 1;
page{i}     = ['PART 3 - doing the task\n\n* About the "saw grating" / "saw orientation" judgments\n\n' ...
               'We ask separate questions about whether you saw a grating and whether you saw its orientation ' ...
               'because sometimes you may clearly see some kind of grating in the noise, ' ...
               'without being able to see clearly the exact orientation of this grating.\n\n' ...
               'When we ask about whether you saw a grating and its orientation, we''re interested to know ' ...
               'about what your actual visual experience was like. Did it actually look like ' ...
               'there was a grating embedded in the noise patch in the response-cued location? ' ...
               'If so, could you actually see whether the grating was oriented counterclockwise or clockwise from vertical?\n\n' ...
               'Don''t try to answer this question based on any information other than ' ...
               'what your actual visual experience of the patch was like.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%                'It is supposed to be a ' ...
%                'question about your subjective experience, not a question about the objective presence or ' ...
%                'abscence of the oval.\n\nFor instance, ' ...
%                'suppose that for some reason, on a certain trial you suspect that that an oval was likely presented ' ...
%                'at the cued location, even though you didn''t have an actual visual experience of one. ' ...
%                'In such cases you should reply "didn''t see" in order to faithfully report what your ' ...
%                'visual experience was like.\n\n'];

%% page 14

i = i + 1;
page{i}     = ['* About the "counterclockwise" / "clockwise" judgment\n\n' ...
               'Sometimes you may not be very sure whether the grating was oriented counterclockwise or clockwise from vertical. ' ...
               'This may be especially the case when you didn''t see a grating to begin with!\n\n' ...
               'On trials where the response-cued quadrant didn''t contain a grating to begin with, obviously the counterclockwise / ' ...
               'clockwise judgment has no meaning. However, just because you didn''t see a grating ' ...
               'doesn''t mean there wasn''t one there! In cases where a grating was objectively present ' ...
               'but you didn''t see it, the orientation judgment is still meaningful and your response ' ...
               'may be meaningful too, even if it "feels" like a wild guess.\n\n' ...
               'For this reason, we ask that ' ...
               'you take the counterclockwise / clockwise question seriously on each trial and give the best ' ...
               'response you can, even when you didn''t see a grating. On such trials, try to make the orientation ' ...
               'judgment *as if* a grating had been presented but you just didn''t see it.\n\n' ...
               'If you''re not sure about the grating''s orientation, just make your best gut instinct guess without ' ...
               'spending too much time deliberating.\n\nIf you have to guess, it''s important that ' ...
               'you don''t guess based on a strategy (like always responding the opposite of what you chose ' ...
               'last, or always responding "counterclockwise"). Try to keep your "counterclockwise" and "clockwise" guesses ' ...
               'roughly balanced, based on your best hunch. If you have no idea at all, try to pick randomly, ' ...
               'as if you were flipping a coin.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 15

i = i + 1;
page{i}     = ['* Time limit\n\n' ...
               'After the response cue appears, you will have ' num2str(p.timing.postcueDur_inSecs) ' seconds to enter your response. ' ...
               'If you don''t enter a response in time, the trial will end without your response and the ' ...
               'next one will begin. Such trials cannot be used for data analysis, so please do ' ...
               'your very best to enter a response within the time limit on every trial!\n\n' ...
               'The time limit is another reason why, if you have to make a guess, you should not spend ' ...
               'too much time deliberating, but just must a relatively quick guess based on your gut instinct, ' ...
               'or a quick "coin flip" response if you have no idea at all how to respond.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 16

i = i + 1;
page{i}     = ['* Stimulus frequencies and dependencies\n\n' ...
               'Overall, each quadrant is equally likely to contain a grating. When a grating is present, it is ' ...
               'equally likely to be oriented counterclockwise or clockwise from vertical.\n\nIt is very important to note ' ...
               'that grating presence and orientation in each quadrant is completely independent of grating ' ...
               'presence and orientation in the other quadrants. In other words, knowing what was shown in ' ...
               'one quadrant gives you no information whatsoever about what was shown in any other quadrant.\n\n' ...
               'As a consequence, your responses should always be based *only* on what you saw at the response-cued ' ...
               'quadrant, and should never be influenced by what you saw at any of the quadrants that were not cued.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 17

i = i + 1;
page{i}     = ['* Gaze fixation and rest\n\n' ...
               'Recall that the purpose of the crosshair presented in the center of the screen is to give ' ...
               'your eyes a natural spot to lock on to during the trial. It''s very important for our data ' ...
               'analysis that you keep your gaze fixed on the crosshair during each trial, to the best of ' ...
               'your ability. In particular, resist the temptation to move your eyes to any of the 4 quadrants ' ...
               'when the 4 quadrant textures are shown.\n\n' ...
               'The trial will start when you are fixating for 1/2 a second. If you think you''re fixating ' ...
               'and the trial still isn''t starting, get the experimenter.\n\n' ...
               'There is a natural mini-break on each trial after the response cue has been shown. ' ...
               'You can feel free to move your eyes or blink during this time if you need to. Make sure to bring ' ...
               'your eyes back quickly though, since the next trial will begin soon!\n\n' ...
               'In the main experiment, you will also get frequent longer break periods where you can rest as ' ...
               'long as you need to.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;


%% page 18

i = i + 1;
page{i}     = ['* Task difficulty and doing your best\n\n' ...
               'The difficulty of the task will vary from trial to trial, ranging from "obvious" to "uncertain" to ' ...
               '"no clue". This is normal! In fact, the task is *intended* to be challenging. We learn best in our ' ...
               'research by investigating perception in difficult tasks like this one.\n\n' ...
               'So if you feel like you''re doing poorly, keep your spirits up and give your best on each trial. ' ...
               'In experiments like these, it is actually common for people''s performance to be better than ' ...
               'they think it is. Even if it seems like you''re struggling, chances are you''re actually doing ' ...
               'a lot better than you think, provided that you''re continuing to be attentive and giving each trial ' ...
               'your best effort. For us, this is actually "good" data that we''ll learn from the best, so thank you ' ...
               'for hanging in there!\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% last page

i = i + 1;
page{i}     = ['That''s all for the instructions!\n\nPlease take the opportunity now to turn off the volume on ' ...
               'your cell phone and shut down any other devices that might distract you during the experiment.\n\n'];
prompt{i}   = ['Please inform the experimenter that you''ve finished reading the instructions. If anything is ' ...
               'still unclear, please discuss with the experimenter.\n\n'];
waitTime(i) = shortWait;


%% 


exitNow = 0;

switch p.setup.instructionStage
    case 1 % day 1 (full instructions) 
        page_start = 1; % start from page 1 
    case 2 % day 2 and beyond (refresher)  
        page_start = 9; % start from attention page 
end
j = page_start;

while j <= length(page)
    
    % show main text
    DrawFormattedText(w, page{j}, sx, sy, 0, wrapat);
    Screen('Flip', w);
    
    % after a delay, show prompt to move on
    WaitSecs(waitTime(j));
    [nx, ny] = DrawFormattedText(w, page{j}, sx, sy, 0, wrapat);
    
    % show page progress (page current of pages total)
    switch p.setup.instructionStage
        case 1
            promptText = [prompt{j} '\n\npage ' num2str(j) ' of ' num2str(length(page))];
        case 2
            promptText = [prompt{j} '\n\npage ' num2str(j-page_start+1) ' of ' num2str(length(page)-page_start+1)];
    end

    DrawFormattedText(w, promptText, sx, ny, 0, wrapat);
    Screen('Flip', w);
    
    % listen for KB input
    KbWait(p.kb.kbNum);
    [k, secs, key] = KbCheck(p.kb.kbNum);
    
    % Don't progress until keys are released
    while KbCheck(p.kb.kbNum), ; end
        
    switch KbName_oneKeyOnly(key)
        
        % if multiple keys are pressed, ignore and wait for an unambiguous single key press
        case 'MultipleKeysPressed', ;
            
        % option to exit
        case p.kb.exitKey, exitNow = 1; return;
        
        % option to go back
        case 'LeftArrow'
            if j > 1, j=j-1; end
            
        % show between-text visuals
        otherwise
            
            %% after page 4 text, show example noise patches
            
            if j == 4
                
                i = 1;
                while i >= 1 && i <= 3
                             
                    % if i <= 3
                        if i==1
                            caption = ['noise patch example #' num2str(i) '\nin these examples, press any key to move on,\nor press the left arrow key to go back'];
                            [textTexture, textRect] = makeTextTexture(w, caption, .3, p.stim.BGcolor);
                        else                    
                            [textTexture, textRect] = makeTextTexture(w, ['noise patch example #' num2str(i)], .9, p.stim.BGcolor);
                        end
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                         Screen('DrawTexture', w, gab_stim_periph(i).bg, [], CenterRect( p.rects.periphFG{ s1.stimID_all(i) }(:,i)', p.rects.window ));

                         % Screen('DrawTexture', w, CenterRect( p.rects.periphFG{ 1 }(:,1) )', [], p.rects.window);  % 

                         Screen('DrawTexture', w, textTexture, [], textRect);
                         Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                        
                    % end

                    Screen('Flip',w);
                    WaitSecs(bufferWait);

                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;
                        
                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end
                        
                    else
                        i = i + 1;
                    end                    
                end               
            end
            
            
            %% after page 5 text, show example gratings
            
            if j == 5
                
                % grating examples
                oriText = {'vertical grating', 'counterclockwise (-45 deg from vertical) grating', 'clockwise (+45 deg from vertical) grating'};
                i = 1;
                while i >= 1 && i <= 3
                    [textTexture, textRect] = makeTextTexture(w, ['grating example #' num2str(i) ' : ' oriText{i} ], .9, p.stim.BGcolor);
                    textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );
                    
                    if i==1
                        Screen('DrawTexture', w, s3(i).gab_stim_periph(i).fg, [], CenterRect( p.rects.periphFG{ s1.stimID_all(i) }(:,i)', p.rects.window ), 45);
                    else
                        Screen('DrawTexture', w, s3(i).gab_stim_periph(i).fg, [], CenterRect( p.rects.periphFG{ s1.stimID_all(i) }(:,i)', p.rects.window ));
                    end

                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    WaitSecs(bufferWait);
                    
                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;
                        
                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end
                        
                    else
                        i = i + 1;
                    end                     
                end                  
            end
            
            %% after page 6 text, show example noisy gratings

            if j == 6

                % noisy grating examples
                oriText = {'counterclockwise (-45 deg from vertical) grating', 'clockwise (+45 deg from vertical) grating'};
                i = 1;
                while i >= 1 && i <= 3
                    [textTexture, textRect] = makeTextTexture(w, ['noisy grating example #' num2str(i) ' : ' oriText{ s1.stimID_all(i)} ], .9, p.stim.BGcolor);
                    textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                    Screen('DrawTexture', w, gab_stim_periph(i).fg, [], CenterRect( p.rects.periphFG{ s1.stimID_all(i) }(:,i)', p.rects.window ));

                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    WaitSecs(bufferWait);

                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;

                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end

                    else
                        i = i + 1;
                    end
                end
            end

            %% after page 7 text, show example of 4 quadrant stimuli
            
            if j == 7 %6
                
                i = 1;
                while i >= 1 && i <= 4
                   % 4 quadrant example
                    [textTexture, textRect] = makeTextTexture(w, ['4 quadrant example #' num2str(i)], .9, p.stim.BGcolor);
                    textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH );
                
                    for i_periph = 1:4
                            Screen('DrawTexture', w, s2(i).gab_stim_periph(i_periph).fg, [], p.rects.periphFG{ 1 }(:,i_periph));
                    end
                
                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    WaitSecs(bufferWait);

                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;
                        
                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end
                        
                    else
                        i = i + 1;
                    end              
                end                 
                
            end            
            
            %% after page 8 text, show examples of stimuli w/ aperture
            
            if j == 8 % 7
                
                i = 1;
                while i >= 1 && i <= 2
                
                    % random texture w/ aperture
                    if i == 1
                         [textTexture, textRect] = makeTextTexture(w, ['4 quadrant patches\nwith fixation cross and black lines'], .45, p.stim.BGcolor);
                         textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );
% 
                         % Screen('DrawTexture', w, gab_stim_rand(1).bg, [], p.rects.window);
                        
                    % 4 quadrant stim w/ aperture
                    elseif i == 2
                
                        [textTexture, textRect] = makeTextTexture(w, ['4 quadrant patches\nwith fixation cross and black lines'], .45, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        i_screen = 4;
                        for i_periph = 1:4
                            % Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
                            % if s2(i_screen).s.stimID_all(i_periph) > 0
                                Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).fg, [], p.rects.periphFG{ 1 }(:,i_periph));
                            % end
                        end
                    end

                    % draw aperture and fixation cross
                    Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                    Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                    % draw 4 inactive cues
                    for i_loc = 1:4
                        Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                    end

                    % draw caption
                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    WaitSecs(bufferWait);

                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;

                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end

                    else
                        i = i + 1;
                    end
                end
                                    
            end
            
            
            %% after page 9 text, show examples of precues
            
            if j == 9 % 8
                
                i = 1;
                while i >= 1 && i <= 3
                
                    % cue for upper right
                    if i == 1
                        captionText = ['attention cue prior to 4 quadrant stimuli, example #1\n' ...
                                       'one attention cue (upper right) flashes white\n\n' ...
                                       'This means you should focus attention on the upper right quadrant,\n' ...
                                       'while keeping your eyes on the fixation cross.\n\n' ...
                                       'Try it now! Practice keeping your eyes on the fixation cross,\n' ...
                                       'while simultaneously focusing attention on the upper right quadrant.'];
                        [textTexture, textRect] = makeTextTexture(w, captionText, .15, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        % Screen('DrawTexture', w, gab_stim_rand(1).bg, [], p.rects.window);
                        
                        % draw aperture and fixation cross
                        Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                        % draw 4 inactive cues
                        for i_loc = 1:4
                            Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                        end

                        % draw 1 active cue
                        respCueLoc = 2;
                        Screen('DrawTexture', w, p.tex.cue_active, [], p.rects.cueRect(:, respCueLoc), rad2deg(p.rects.angleList_inRadians(respCueLoc))+90);    
                        
                    % cue for upper right
                    elseif i == 2
                        captionText = ['attention cue prior to 4 quadrant stimuli, example #2\n' ...
                                       'one attention cue (lower left) flashes white\n\n' ...
                                       'This means you should focus attention on the lower left quadrant,\n' ...
                                       'while keeping your eyes on the fixation cross.\n\n' ...
                                       'Try it now! Practice keeping your eyes on the fixation cross,\n' ...
                                       'while simultaneously focusing attention on the lower left quadrant.'];
                        [textTexture, textRect] = makeTextTexture(w, captionText, .15, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        % Screen('DrawTexture', w, gab_stim_rand(1).bg, [], p.rects.window);
                        
                        % draw aperture and fixation cross
                        Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                        % draw 4 inactive cues
                        for i_loc = 1:4
                            Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                        end

                        % draw 1 active cue
                        respCueLoc = 4;
                        Screen('DrawTexture', w, p.tex.cue_active, [], p.rects.cueRect(:, respCueLoc), rad2deg(p.rects.angleList_inRadians(respCueLoc))+90);    
                        
                    % neutral precue
                    elseif i == 3
                        captionText = ['attention cue prior to 4 quadrant stimuli, example #3\n' ...
                                       'all 4 attention cues flash white\n\n' ...
                                       'This means you should spread attention evenly across all quadrants,\n' ...
                                       'while keeping your eyes on the fixation cross.\n\n' ...
                                       'Try it now! Practice keeping your eyes on the fixation cross,\n' ...
                                       'while simultaneously spreading your attention evenly over all 4 quadrants.'];
                        [textTexture, textRect] = makeTextTexture(w, captionText, .15, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        % Screen('DrawTexture', w, gab_stim_rand(1).bg, [], p.rects.window);
                        
                        % draw aperture and fixation cross
                        Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                        Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                        % draw 4 active cues
                        for i_loc = 1:4
                            Screen('DrawTexture', w, p.tex.cue_active, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                        end
                        
                    end


                    % draw caption
                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    WaitSecs(bufferWait);

                    % listen for KB input
                    KbWait(p.kb.kbNum);
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    if strcmp(KbName_oneKeyOnly(key), 'MultipleKeysPressed')
                        ;
                    elseif strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        i = i - 1;

                        % if left arrow key was pressed on first example, go back to the previous page
                        if i == 0
                            j = j - 1;
                        end

                    else
                        i = i + 1;
                    end
                end
                                    
            end
            
            
            %% after page 11 text, show a self-paced sample trial sequence
            
            if j == 11 % 10
                
                %% random texture w/ aperture
                
                i = 1;
                caption = ['stage ' num2str(i) '\nfollowing your response on the last trial,\nnoise patches appear at the start of the current trial'];
                [textTexture, textRect] = makeTextTexture(w, caption, .3, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw noise
                i_screen = 2;
                for i_periph = 1:4
                    Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphFG{ 1 }(:,i_periph));
                end

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
                
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                
                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);
                
                
                %% random texture w/ aperture and inactive cues
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\nnow cues (black lines) are added'];
                [textTexture, textRect] = makeTextTexture(w, caption, .45, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw noise
                i_screen = 2;
                for i_periph = 1:4
                    Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphFG{ 1 }(:,i_periph));
                end

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
                
                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
                
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                
                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);                
                
                
                %% random texture w/ aperture and flashing neutral cue
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\none attention cue flashes white\nfocus attention on the indicated quadrant(s) while keeping eyes on fixation'];
                [textTexture, textRect] = makeTextTexture(w, caption, .25, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw noise
                i_screen = 2;
                for i_periph = 1:4
                    Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphFG{ 1 }(:,i_periph));
                end

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
                
                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end

                % draw 1 active cue
                respCueLoc = 1;
                Screen('DrawTexture', w, p.tex.cue_active, [], p.rects.cueRect(:, respCueLoc), rad2deg(p.rects.angleList_inRadians(respCueLoc))+90);    
                
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                
                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);  
                
                
                %% random texture w/ aperture and inactive cues
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\ncues briefly turn black again'];
                [textTexture, textRect] = makeTextTexture(w, caption, .45, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw noise
                i_screen = 2;
                for i_periph = 1:4
                    Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphFG{ 1 }(:,i_periph));
                end

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);
                
                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
                
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                
                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);  
                
                
                %% 4 quadrant stim w/ aperture and inactive cues
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\nnoise patches update, and gratings may or may not appear within them\nremember to keep gaze on fixation!'];
                [textTexture, textRect] = makeTextTexture(w, caption, .25, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                i_screen = 2;
                for i_periph = 1:4
                    % Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
                    % if s2(i_screen).s.stimID_all(i_periph) > 0
                        Screen('DrawTexture', w, s2(i_screen).gab_stim_periph(i_periph).fg, [], p.rects.periphFG{ 1 }(:,i_periph));
                    % end
                end

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
    
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);
                
                %% blank BG w/ fixation cross and 4 inactive cues
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\npatches disappear, but fixation and cues remain'];
                [textTexture, textRect] = makeTextTexture(w, caption, .45, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
    
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);
                
                %% blank BG w/ fixation cross, 3 inactive cues, 1 active cue
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\nresponse cue turns white until response entry\nhere, you''d have to respond about the texture that was presented on the upper right'];
                [textTexture, textRect] = makeTextTexture(w, caption, .25, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                % draw aperture and fixation cross
                Screen('FillOval', w, p.stim.BGcolor, p.rects.aperture);
                Screen('FillRect', w, p.stim.fixationColor{1}, p.rects.fixation);

                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
    
                % draw 1 active cue
                respCueLoc = 2;
                Screen('DrawTexture', w, p.tex.cue_active, [], p.rects.cueRect(:, respCueLoc), rad2deg(p.rects.angleList_inRadians(respCueLoc))+90);    

                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);
                
                
                %% fixation cross turns gray after response entry
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\nwhen the computer successfully records your response,\nthe response cue returns to black and the crosshair turns gray'];
                [textTexture, textRect] = makeTextTexture(w, caption, .25, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                Screen('FillRect', w, p.stim.fixationColor{2}, p.rects.fixation);
                
                % draw 4 inactive cues
                for i_loc = 1:4
                    Screen('DrawTexture', w, p.tex.cue_inactive, [], p.rects.cueRect(:, i_loc), rad2deg(p.rects.angleList_inRadians(i_loc))+90);        
                end
    
                % draw caption
                Screen('DrawTexture', w, textTexture, [], textRect);
                Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                Screen('Flip',w);
                WaitSecs(bufferWait);
                KbWait(p.kb.kbNum);   
                
            end            
            
            %% after page 12 text, give response entry practice
            
            if j == 12 % 11
                                
                [textTexture, textRect] = makeTextTexture(w, ['press 1, 2, 3, 8, 9, or 0 to see corresponding response\npress space to continue'], .3, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/4 );
                
                done = 0;
                pressedKey = [];
                while ~done
                    
                    % draw ovals
                    for i = 1:6
                        Screen('DrawTexture', w, ovalTex(i), [], ovalRect{i});
                        Screen('DrawTexture', w, textTextureOval(i), [], textRectOval{i});                        
                    end
                    
                    % frame selected oval
                    if ~isempty(pressedKey) && pressedKey <= 6
                        Screen('FrameRect', w, [255, 0, 0], ovalRect{pressedKey}, 10);
                    end
                    
                    % draw captions
                    Screen('DrawTexture', w, textTexture, [], textRect);
                    Screen('FrameRect', w, [255, 0, 0], textRect, 3);

                    Screen('Flip',w);
                    
                    [k, secs, key] = KbCheck(p.kb.kbNum);
                    
                    pressedKey = find(strcmp(p.kb.respKeys, KbName_oneKeyOnly(key)));
                    if strcmp(KbName_oneKeyOnly(key), 'space'), done = 1; end
                    if strcmp(KbName_oneKeyOnly(key), 'LeftArrow')
                        done = 1;
                        j = j - 1;
                    end
                    
                end

            end
            

            %% increment page counter

            j = j + 1;

    end

end