function gratingMatrix = makeSineGrating(size1, size2, spatFreq, tiltInDegrees, pixPerDeg)

tiltInRadians = tiltInDegrees * pi / 180; % The tilt of the grating in radians.

pixelsPerPeriod = pixPerDeg/spatFreq; %spatfreq = periods per degree
spatialFrequency = 1/ pixelsPerPeriod;
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)

% *** If the grating is clipped on the sides, increase widthOfGrid.
widthOfGrid = size2-1;
heightOfGrid = size1-1;
halfWidthOfGrid = widthOfGrid / 2;
halfHeightOfGrid = heightOfGrid / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.
heightArray = (-halfHeightOfGrid) : halfHeightOfGrid;

[x, y] = meshgrid(widthArray, heightArray);

a=cos(tiltInRadians)*radiansPerPixel;
b=sin(tiltInRadians)*radiansPerPixel;

% Converts meshgrid into a sinusoidal grating. Each entry of gratingMatrix varies between minus one and one: -1 <= gratingMatrix(x0, y0)  <= 1
gratingMatrix = sin(a*x+b*y);

% imagesc(gratingMatrix);
%colormap(gray(256));
