function exitNow = expt_takeBreak(w, p, b, i_block)

exitNow = 0;

if i_block < b.nBlocks

    %% break text in Matlab prompt for experimenter

    disp(['Block ' num2str(i_block) ' of ' num2str(b.nBlocks) ' has been completed.']);
    disp(['time completed: ' datestr(now)])
    disp(' ')


    %% break screen shown to subject

    brem = b.nBlocks - i_block;
    if i_block == 1
        plural_text1='';
    else
        plural_text1='s';
    end

    if brem==1
        plural_text2='';
    else
        plural_text2='s';
    end

    breaktext = ['Break time!\n\n' num2str(i_block) ' block' plural_text1 ' down, ' num2str(brem) ' block' plural_text2 ' remaining.'];

    Screen('FillRect', w, p.stim.BGcolor);
    DrawFormattedText(w, breaktext, 'center', 'center', 0);
    Screen('Flip', w);


    %% after a pause, allow subject to continue with a keypress

    % minimum break time
    WaitSecs(10);

    % notify experimenter
    disp('Participant now has the option of continuing to the next block.');

    % notify subject
    breaktext = [breaktext '\n\nPress any key to continue.'];

    Screen('FillRect', w, p.stim.BGcolor);
    DrawFormattedText(w, breaktext, 'center', 'center',0);
    Screen('Flip', w);


    %% continue after keypress

    KbWait(p.kb.kbNum);
    [k, secs, key] = KbCheck(p.kb.kbNum);
    if strcmp(KbName(key), p.kb.exitKey), exitNow = 1; return; end

    Screen('FillRect', w, p.stim.BGcolor);
    Screen('Flip', w);
    
    disp('Participant has begun the next block.');
    disp(' ')
    
    WaitSecs(1);

    
else

    DrawFormattedText(w, 'All done!', 'center', 'center', 0);
    Screen('Flip', w);

    WaitSecs(3);
%     KbWait(p.kb.kbNum);

end