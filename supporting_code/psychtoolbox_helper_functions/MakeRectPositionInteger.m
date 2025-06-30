function newRect = MakeRectPositionInteger(rect)

x_rem = rem( rect(RectLeft), 1 );
y_rem = rem( rect(RectTop), 1 );

newRect = OffsetRect(rect, -x_rem, -y_rem);