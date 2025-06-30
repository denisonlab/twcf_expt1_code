function k = getKeyboardNumber()
% k = getKeyboardNumber()
% 
% returns the first device listed by PsychHID('Devices') that is a USB
% keyboard. if no USB KB is found, the function returns the first listed
% device that is a KB, regardless of transport type.
%
% this function is only necessary for Macs.

d = PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard')
        if strcmp(d(n).transport,'USB')
            k = n; return
        elseif k == 0
            k = n;
        end
    end
end