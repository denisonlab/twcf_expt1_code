function k = getKeyboardNumber_UCR()

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard') && strcmp(d(n).transport,'USB')
        k=n;
        break
    end
end