function xy = defineRandomLinesInRect(rect, nLines, lineLengths)
% xy = defineRandomLinesInRect(rect, nLines, lineLengths)
% 
% Randomly define line positions within a rect. For use with
% Screen('DrawLines')

xy_center(1,:) = (rect(3)-rect(1)) * rand(1,nLines) + rect(1);
xy_center(2,:) = (rect(4)-rect(2)) * rand(1,nLines) + rect(2);

for i = 1:nLines
    % randomly determine angle and line length
    theta      = 2*pi*rand;
    lineLength = lineLengths( randperm(numel(lineLengths), 1) );
    
    xy_left(:,i)  = xy_center(:,i) + lineLength/2 * [-cos(theta); sin(theta)];
    xy_right(:,i) = xy_center(:,i) + lineLength/2 * [cos(theta); -sin(theta)];
end

xy(1,:) = Interleave(xy_left(1,:), xy_right(1,:));
xy(2,:) = Interleave(xy_left(2,:), xy_right(2,:));

end