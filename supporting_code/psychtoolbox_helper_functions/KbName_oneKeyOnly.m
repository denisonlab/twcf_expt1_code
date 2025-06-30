function kbNameResult = KbName_oneKeyOnly(key)
% kbNameResult = KbName_oneKeyOnly(key)
% 
% This function works the same as KbName, except that if multiple keys are 
% pressed at once, rather than returning a cell array, this function
% returns a string output 'MultipleKeysPressed'. This can help streamline
% how multiple simultaneous key presses are handled by subsequent code.

kbNameResult = KbName(key);

if iscell(kbNameResult)
    kbNameResult = 'MultipleKeysPressed';
end