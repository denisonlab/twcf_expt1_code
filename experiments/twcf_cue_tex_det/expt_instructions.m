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

nLineLengths = length( p.stim.periph.lineLength_inDeg_list );

%%% after page 1, show random texture and oriented texture
% random textures
s0 = p.stim.rand;
for i = 1:3
    tex_stim_rand(i) = expt_makeStimTexRand(w, p, s0);
end

% peripheral textures
s1 = p.stim.periph;
    
% get unique properties for peripheral stim on this trial
s1.angleBG_all          = [pi/4; 3*pi/4; pi/4; 3*pi/4]; % alternating orientaion
s1.angleFG_all          = s1.angleBG_all + pi/2;
s1.stimID_all           = [1; 2; 1; 2];                 % no figures
s1.lineLengthID_all     = [nLineLengths-1; nLineLengths-3; nLineLengths; nLineLengths-2];
s1.lineLength_inPix_all = s1.lineLength_inPix_list( s1.lineLengthID_all );

tex_stim_periph    = expt_makeStimTexPeriph(w, p, s1);


%% make sample stimuli for pg 3

angles     = [pi/4; 3*pi/4; pi/4; 3*pi/4];
stimIDs{1} = [0; 1; 0; 0];
stimIDs{2} = [1; 0; 2; 0];
stimIDs{3} = [0; 0; 0; 0];
stimIDs{4} = [2; 2; 1; 2];

for i = 1:4

    % peripheral textures
    s2(i).s = p.stim.periph;

    % get unique properties for peripheral stim on this trial
    s2(i).s.angleBG_all          = angles(i) * ones(4,1);
    s2(i).s.angleFG_all          = s2(i).s.angleBG_all + pi/2;
    s2(i).s.stimID_all           = stimIDs{i};
    s2(i).s.lineLengthID_all     = [nLineLengths-1; nLineLengths-3; nLineLengths; nLineLengths-2];
    s2(i).s.lineLength_inPix_all = s2(i).s.lineLength_inPix_list( s2(i).s.lineLengthID_all );

    s2(i).tex_stim_periph        = expt_makeStimTexPeriph(w, p, s2(i).s);
end

%% make stimuli for keyboard practice

% make captions
fontSizeMult = 0.8;
% vertical [1 2 3]
[textTextureOval(1), textRectOval{1}] = makeTextTexture(w, ['1 key\n\nsaw figure\nsaw shape\nsaw vertical'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));
[textTextureOval(2), textRectOval{2}] = makeTextTexture(w, ['2 key\n\nsaw figure\nguess shape\nguess vertical'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));
[textTextureOval(3), textRectOval{3}] = makeTextTexture(w, ['3 key\n\ndidn''t see figure\nguess shape\nguess vertical'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));
% horizontal [8 9 0]
[textTextureOval(4), textRectOval{4}] = makeTextTexture(w, ['8 key\n\ndidn''t see figure\nguess shape\nguess horizontal'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));
[textTextureOval(5), textRectOval{5}] = makeTextTexture(w, ['9 key\n\nsaw figure\nguess shape\nguess horizontal'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));
[textTextureOval(6), textRectOval{6}] = makeTextTexture(w, ['0 key\n\nsaw figure\nsaw shape\nsaw horizontal'], 0, p.stim.BGcolor,ceil(p.text.fontSize*fontSizeMult));

% set up oval schematics
ori = [1 1 1 2 2 2];
centers = round( linspace(0, RectWidth(p.rects.window), 9) );
ind = [2 3 4 6 7 8];
for i = 1:6
    [oval, ~, alpha] = imread(['supporting_files/oval' num2str(i)], 'png');
    oval(:, :, 4)    = alpha;
    ovalTex(i)       = Screen('MakeTexture', w, oval);
    ovalRect{i}      = CenterRectOnPoint( ceil(p.rects.periphFG{ori(i)}(:,1)'*.75), centers(ind(i)), p.rects.midH);

    offset = RectHeight(ovalRect{1})/2 + .3*RectHeight(ovalRect{1});
    textRectOval{i} = CenterRectOnPoint( textRectOval{i}, centers(ind(i)), p.rects.midH);
    textRectOval{i} = OffsetRect( textRectOval{i}, 0, offset);
end
                

%% write text

%% page 1

i = 1;
page{i}     = ['INSTRUCTIONS\n\n* Overview\n\n' ...
               'In this experiment you will be asked to make judgments about visual stimuli.\n\n' ...
               'Specifically, you will be pointed or "cued" to a particular location on the screen and will have to respond:\n' ...
               '(1) Did you see a "figure" popping out from the background in the cued location?\n' ...
               '(2) If yes, did you see what shape this figure was?\n' ...
               '(3) What was the shape of the figure?\n\n' ...
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
page{i}     = ['PART 1 - example images\n\n* Textures\n\n' ...
               'OK, let''s start getting into the details!\n\n' ...
               'On each trial, you will see many black lines on a white background. We''ll call these stimuli "textures."\n\n' ...
               'Sometimes these lines will be drawn randomly and sometimes the lines will all have the same leftward or rightward ' ...
               'tilt. We''ll call these "random textures" and "oriented textures," respectively.\n\n' ...
               'Let''s take a look at some examples of random textures and oriented textures.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of random textures and oriented textures.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 4, show examples of random textures and oriented textures

%% page 5

i = i + 1;
page{i}     = ['* Oval figures\n\nSometimes the oriented textures will contain an oval-shaped region where the lines ' ...
               'are tilted in the opposite direction. This creates the perception of an oval "figure" popping out ' ...
               'from the background. This oval can be oriented either vertically (tall and narrow) or horizontally (short and wide).\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of oval figures "popping out" from the background in oriented textures.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 5, show examples of vertical and horizontal ovals

%% page 6

i = i + 1;
page{i}     = ['* Quadrants\n\nIn the main experiment, the screen will be split into 4 sections, called quadrants. ' ...
               '4 different oriented textures will be shown in each quadrant ' ...
               'of the screen. Each quadrant may or may not contain a figure. The figure may be a horizontal oval or a vertical oval.\n\n'];
prompt{i}   = ['__________\nPress any key to see examples of textures in the 4 quadrants.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 6, show an example of the 4 quadrant stimuli

%% page 7

i = i + 1;
page{i}     = ['* Fixation and black lines\n\nIn the main experiment, a circular cutout will be shown at the center of the screen.\n\n' ...
               'The circular cutout contains a fixation cross at its center. The fixation cross is just a plus sign, like this: +. ' ...
               'When the fixation cross appears, you should lock your eyes onto it and resist any temptation to move your eyes around ' ...
               'on the screen.\n\nThe circular cutout also contains 4 black lines pointing to each quadrant.\n\n'];
               
prompt{i}   = ['__________\nPress any key to see examples of textures with the circular cutout containing the fixation cross and black lines.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 7, show examples of the aperture w/ fixation and cues

%% page 8

i = i + 1;
page{i}     = ['* Attention cue (shown before the 4 quadrants)\n\nBefore the textures in the 4 quadrants are shown, you will be shown an "attention cue." ' ...
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

%% after page 8, show examples of the aperture w/ fixation and pre-cues

%% page 9

i = i + 1;
page{i}     = ['* Response cue (shown after the 4 quadrants)\n\nAfter the textures in the 4 quadrants are shown, one of ' ...
               'the 4 black lines will once again briefly flash white. ' ...
               'The flashing white response cue indicates which quadrant you will have to make judgments about. ' ...
               'For instance, if the lower left response cue flashes, that means you''ll have to provide judgments about the texture that was ' ...
               'shown on the lower left.\n\n' ...
               'For the response-cued texture, you will enter your response about whether you saw a figure there, ' ...
               'whether you saw its shape, and what its shape was. More detail on response entry will be coming up shortly.\n\n' ...
               'When the computer has recorded your response, the response cue returns to black and the crosshair at fixation ' ...
               'turns gray. This lets you know that your response was entered successfully and the next trial is going to begin soon.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 10

i = i + 1;
page{i}     = ['PART 2 - Sample trial sequence\n\nNow let''s take a look at the sequence of events that will occur on every trial.\n\n' ...
               'As a reminder, a "trial" is a sequence of events beginning with the presentation of a new set of textures and ending when ' ...
               'you''ve provided your response for the texture in the response-cued quadrant.\n\n' ...
               'In the following screen you''ll have a chance to take a self-paced tour through all the trial stages. ' ...
               'Captions will provide additional information as you go.\n\n' ...
               'To prevent confusion, there will be no option to go back to the previous screen using the left arrow key ' ...
               'during this sample sequence. If you wish to view the sample sequence again, you can press the left arrow ' ...
               'key on the next page of text.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% after page 10, show a self-paced sample trial sequence

%% page 11

i = i + 1;
page{i}     = ['* Response entry\n\nOn each trial you have to decide three things about the texture in the response-cued quadrant:\n' ...
               '(1) Did you see a texture-defined figure in the response-cued location?\n' ...
               '(2) If you did see a figure, did you see what shape it was?\n' ...
               '(3) Was the figure a vertical oval (tall and narrow) or a horizontal oval (short and wide)?\n\n' ...
               'On the following screen we''ll show you how to enter your response.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back and see the trial sequence again.'];
waitTime(i) = shortWait;

%% after page 11, show keyboard practice

%% page 12

i = i + 1;
page{i}     = ['PART 3 - doing the task\n\n* About the "saw figure" / "saw shape" judgments\n\n' ...
               'We ask separate questions about whether you saw a figure and whether you saw its shape ' ...
               'because sometimes you may clearly see some kind of figure "popping out" from the background, ' ...
               'without being able to see clearly the exact shape of this figure.\n\n' ...
               'When we ask about whether you saw a figure and its shape, we''re interested to know ' ...
               'about what your actual visual experience was like. Did it actually look like ' ...
               'there was a figure popping out of the background in the response-cued location? ' ...
               'If so, could you actually see whether it was a vertical or horizontal oval?\n\n' ...
               'Don''t try to answer this question based on any information other than ' ...
               'what your actual visual experience of the texture was like.\n\n'];
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

%% page 13

i = i + 1;
page{i}     = ['* About the "vertical" / "horizontal" judgment\n\n' ...
               'Sometimes you may not be very sure whether the figure was a vertical or horizontal oval. ' ...
               'This may be especially the case when you didn''t see a figure to begin with!\n\n' ...
               'On trials where the response-cued quadrant didn''t contain an oval figure to begin with, obviously the vertical / ' ...
               'horizontal judgment has no meaning. However, just because you didn''t see an oval ' ...
               'doesn''t mean there wasn''t one there! In cases where an oval was objectively present ' ...
               'but you didn''t see it, the orientation judgment is still meaningful and your response ' ...
               'may be meaningful too, even if it "feels" like a wild guess.\n\n' ...
               'For this reason, we ask that ' ...
               'you take the vertical / horizontal question seriously on each trial and give the best ' ...
               'response you can, even when you didn''t see a figure. On such trials, try to make the orientation ' ...
               'judgment *as if* an oval had been presented but you just didn''t see it.\n\n' ...
               'If you''re not sure about the oval''s orientation, just make your best gut instinct guess without ' ...
               'spending too much time deliberating.\n\nIf you have to guess, it''s important that ' ...
               'you don''t guess based on a strategy (like always responding the opposite of what you chose ' ...
               'last, or always responding "vertical"). Try to keep your "vertical" and "horizontal" guesses ' ...
               'roughly balanced, based on your best hunch. If you have no idea at all, try to pick randomly, ' ...
               'as if you were flipping a coin.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 14

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

%% page 15

i = i + 1;
page{i}     = ['* Stimulus frequencies and dependencies\n\n' ...
               'Overall, each quadrant is equally likely to contain an oval. When ovals are present, they are ' ...
               'equally likely to be vertical or horizontal.\n\nIt is very important to note ' ...
               'that oval presence and orientation in each quadrant is completely independent of oval ' ...
               'presence and orientation in the other quadrants. In other words, knowing what was shown in ' ...
               'one quadrant gives you no information whatsoever about what was shown in any other quadrant.\n\n' ...
               'As a consequence, your responses should always be based *only* on what you saw at the response-cued ' ...
               'quadrant, and should never be influenced by what you saw at any of the quadrants that were not cued.\n\n'];
prompt{i}   = ['__________\nPress any key to continue.' ...
               '\nPress the left arrow key to go back.'];
waitTime(i) = shortWait;

%% page 16

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


%% page 17

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

j = 1;
while j <= length(page)
    
    % show main text
    DrawFormattedText(w, page{j}, sx, sy, 0, wrapat);
    Screen('Flip', w);
    
    % after a delay, show prompt to move on
    WaitSecs(waitTime(j));
    [nx, ny] = DrawFormattedText(w, page{j}, sx, sy, 0, wrapat);
    
    promptText = [prompt{j} '\n\npage ' num2str(j) ' of ' num2str(length(page))];
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
            
            %% after page 4 text, show example textures
            
            if j == 4
                
                i = 1;
                while i >= 1 && i <= 6
                    
                    % random texture examples                    
                    if i <= 3
                        if i==1
                            caption = ['random texture example #' num2str(i) '\nin these examples, press any key to move on,\nor press the left arrow key to go back'];
                            [textTexture, textRect] = makeTextTexture(w, caption, .3, p.stim.BGcolor);
                        else                    
                            [textTexture, textRect] = makeTextTexture(w, ['random texture example #' num2str(i)], .9, p.stim.BGcolor);
                        end
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        Screen('DrawTexture', w, tex_stim_rand(i).bg, [], p.rects.window);  
                        Screen('DrawTexture', w, textTexture, [], textRect);
                        Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                        
                    % oriented texture examples                        
                    else
                        [textTexture, textRect] = makeTextTexture(w, ['oriented texture example #' num2str(i-3)], .9, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        Screen('DrawTexture', w, tex_stim_periph(i-3).bg, [], CenterRect( p.rects.periphBG(:,i-3)', p.rects.window ));  
                        Screen('DrawTexture', w, textTexture, [], textRect);
                        Screen('FrameRect', w, [255, 0, 0], textRect, 3);
                        
                    end

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
            
            
            %% after page 5 text, show example ovals
            
            if j == 5
                
                % oriented texture + oval examples
                oriText = {'vertical oval', 'horizontal oval'};
                i = 1;
                while i >= 1 && i <= 4
                    [textTexture, textRect] = makeTextTexture(w, ['figure example #' num2str(i) ' (' oriText{s1.stimID_all(i)} ')'], .9, p.stim.BGcolor);
                    textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                    Screen('DrawTexture', w, tex_stim_periph(i).bg, [], CenterRect( p.rects.periphBG(:,i)', p.rects.window ));
                    Screen('DrawTexture', w, tex_stim_periph(i).fg, [], CenterRect( p.rects.periphFG{ s1.stimID_all(i) }(:,i)', p.rects.window ));
                    
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
            
            %% after page 6 text, show example of 4 quadrant stimuli
            
            if j == 6
                
                i = 1;
                while i >= 1 && i <= 4
                   % 4 quadrant example
                    [textTexture, textRect] = makeTextTexture(w, ['4 quadrant example #' num2str(i)], .9, p.stim.BGcolor);
                    textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH );
                
                    for i_periph = 1:4
                        Screen('DrawTexture', w, s2(i).tex_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
                        if s2(i).s.stimID_all(i_periph) > 0
                            Screen('DrawTexture', w, s2(i).tex_stim_periph(i_periph).fg, [], p.rects.periphFG{ s2(i).s.stimID_all(i_periph) }(:,i_periph));
                        end
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
            
            %% after page 7 text, show examples of stimuli w/ aperture
            
            if j == 7
                
                i = 1;
                while i >= 1 && i <= 2
                
                    % random texture w/ aperture
                    if i == 1
                        [textTexture, textRect] = makeTextTexture(w, ['random texture\ncircular cutout with fixation cross and black lines'], .45, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);
                        
                    % 4 quadrant stim w/ aperture
                    elseif i == 2
                
                        [textTexture, textRect] = makeTextTexture(w, ['4 quadrant textures\ncircular cutout with fixation cross and black lines'], .45, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        i_screen = 4;
                        for i_periph = 1:4
                            Screen('DrawTexture', w, s2(i_screen).tex_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
                            if s2(i_screen).s.stimID_all(i_periph) > 0
                                Screen('DrawTexture', w, s2(i_screen).tex_stim_periph(i_periph).fg, [], p.rects.periphFG{ s2(i_screen).s.stimID_all(i_periph) }(:,i_periph));
                            end
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
            
            
            %% after page 8 text, show examples of precues
            
            if j == 8
                
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

                        Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);
                        
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
                                       'one attention (lower left) flashes white\n\n' ...
                                       'This means you should focus attention on the lower left quadrant,\n' ...
                                       'while keeping your eyes on the fixation cross.\n\n' ...
                                       'Try it now! Practice keeping your eyes on the fixation cross,\n' ...
                                       'while simultaneously focusing attention on the lower left quadrant.'];
                        [textTexture, textRect] = makeTextTexture(w, captionText, .15, p.stim.BGcolor);
                        textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                        Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);
                        
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

                        Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);
                        
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
            
            
            %% after page 10 text, show a self-paced sample trial sequence
            
            if j == 10
                
                %% random texture w/ aperture
                
                i = 1;
                caption = ['stage ' num2str(i) '\nfollowing your response on the last trial,\na random texture appears at the start of the current trial'];
                [textTexture, textRect] = makeTextTexture(w, caption, .3, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);

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
                caption = ['stage ' num2str(i) '\nnow cues (black lines) are added to the circular cutout'];
                [textTexture, textRect] = makeTextTexture(w, caption, .45, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);

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

                Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);

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

                Screen('DrawTexture', w, tex_stim_rand(1).bg, [], p.rects.window);

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
                caption = ['stage ' num2str(i) '\n4 quadrant textures appear\nremember to keep gaze on fixation!'];
                [textTexture, textRect] = makeTextTexture(w, caption, .25, p.stim.BGcolor);
                textRect = CenterRectOnPoint( textRect, p.rects.midW, p.rects.midH/3 );

                i_screen = 2;
                for i_periph = 1:4
                    Screen('DrawTexture', w, s2(i_screen).tex_stim_periph(i_periph).bg, [], p.rects.periphBG(:,i_periph));
                    if s2(i_screen).s.stimID_all(i_periph) > 0
                        Screen('DrawTexture', w, s2(i_screen).tex_stim_periph(i_periph).fg, [], p.rects.periphFG{ s2(i_screen).s.stimID_all(i_periph) }(:,i_periph));
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
                KbWait(p.kb.kbNum);
                
                %% blank BG w/ fixation cross and 4 inactive cues
                
                i = i + 1;
                caption = ['stage ' num2str(i) '\ntextures disappear, but fixation and cues remain'];
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
            
            %% after page 11 text, give response entry practice
            
            if j == 11
                                
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
            
            
            %% require entry of special code "twcf" on last page to exit instruction screen

%             if j == length(page)
%                 while 1
%                     [k, secs, key] = KbCheck(p.kb.kbNum);
%                     if strcmp(KbName(key),'t'), break, end
%                 end
% 
%                 while 1
%                     [k, secs, key] = KbCheck(p.kb.kbNum);
%                     if strcmp(KbName(key),'w'), break, end
%                 end
% 
%                 while 1
%                     [k, secs, key] = KbCheck(p.kb.kbNum);
%                     if strcmp(KbName(key),'c'), break, end
%                 end
% 
%                 while 1
%                     [k, secs, key] = KbCheck(p.kb.kbNum);
%                     if strcmp(KbName(key),'f'), break, end
%                 end        
%             end

            %% increment page counter

            j = j + 1;

    end

end