function colorChannelL = sRGBtoLin(colorChannel)
% Send this function a decimal sRGB gamma encoded color value
% between 0.0 and 1.0, and it returns a linearized value.

if colorChannel<=0.04045
    colorChannelL = colorChannel/12.92;
else
    colorChannelL = ((colorChannel + 0.055)/1.055)^2.4;
end

