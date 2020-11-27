function allCoords = fixCrossCoord(fixCrossDimPix)
%FIXCROSSSIZE [allCoords] = fixCrossCoord(fixCrossDimPix)
%   Makes a fixation cross according to its inputs

%fixCrossDimPix => Size of each arm of fixation cross
xCoords   = [-fixCrossDimPix,fixCrossDimPix,0,0]; 
yCoords   = [0,0,-fixCrossDimPix,fixCrossDimPix];
allCoords = [xCoords;yCoords]; %Coordinates of fixation cross

end

