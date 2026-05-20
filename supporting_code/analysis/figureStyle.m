function figureStyle()
% TWCF FOHO figure styling 
% adjusts fig axis and text styling

hold on 
box off
set(gca,'TickDir','out');
set(gca, 'Layer', 'Top');
set(gca, 'Color', 'w');
ax = gca;
ax.LineWidth = 1; % 1.5;
ax.XColor = 'black';
ax.YColor = 'black';

smlFont = 10;
bigFont = 14; % 24 

ax.FontSize = bigFont;
ax.FontName = 'Helvetica'; 
 
ax.XAxis.FontSize = smlFont;
ax.YAxis.FontSize = smlFont;
