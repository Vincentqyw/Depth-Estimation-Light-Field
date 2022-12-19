function imtight

axis image off;

xMult = 1;
yMult = 1;
borderSize = 0;
PLOTBASESIZE = 500;

set(gca, 'PlotBoxAspectRatio', [xMult yMult 1])
set(gcf, 'Position', get(gcf, 'Position') .* [1 1 0 0] + [0 0 PLOTBASESIZE*xMult PLOTBASESIZE*yMult]);
set(gca, 'Position', [borderSize borderSize 1-2*borderSize 1-2*borderSize]);