function xy = defineLinesInRect(rect, nLines, lineLength, theta)
% xy = defineLinesInRect(rect, nLines, lineLength, theta)
% 
% Randomly define line positions within a rect. For use with
% Screen('DrawLines')

xy_center(1,:) = (rect(3)-rect(1)) * rand(1,nLines) + rect(1);
xy_center(2,:) = (rect(4)-rect(2)) * rand(1,nLines) + rect(2);

leftDisplacement = lineLength/2 * [-cos(theta); sin(theta)];
xy_left  = xy_center + repmat( leftDisplacement, 1, size(xy_center, 2) );

rightDisplacement = lineLength/2 * [cos(theta); -sin(theta)];
xy_right = xy_center + repmat( rightDisplacement, 1, size(xy_center, 2) );

xy(1,:) = Interleave(xy_left(1,:), xy_right(1,:));
xy(2,:) = Interleave(xy_left(2,:), xy_right(2,:));
    
end