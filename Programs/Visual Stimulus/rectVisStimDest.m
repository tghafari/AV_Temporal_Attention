function rectVisStim = rectVisStimDest(width,height,display,windowRect)

%RECTVISSTIMDEST Summary of this function goes here
%Define the destination rectangle in which visStim will be presented

%width and height should be in visual degrees
%display.dist (distance from screen (cm))
%display.width (width of screen (cm))
%display.resolution (number of pixels of display in horizontal direction)
%windowRect -> output of PsychImaging('OpenWindow',...), is the size of 
%the window

rectVisStim = [0,0,angle2pix(display,width),angle2pix(display,height)];
rectVisStim = CenterRect(rectVisStim,windowRect);

end

