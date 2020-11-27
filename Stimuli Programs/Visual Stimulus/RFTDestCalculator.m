function [destCoordRFT,destRectRFT] = RFTDestCalculator(destVisStim,windowRect)
%[destCoordRFT,destRectRFT] = RFTdestCalculator(destVisStim,windowRect)
% makes four destination rectangles and four coordinates of centres for RFT

scrnWidth = windowRect(3); 
screnHght = windowRect(4);

cntrCoordRect1 = [1*scrnWidth/4,1*screnHght/4];
cntrCoordRect2 = [3*scrnWidth/4,1*screnHght/4];
cntrCoordRect3 = [1*scrnWidth/4,3*screnHght/4];
cntrCoordRect4 = [3*scrnWidth/4,3*screnHght/4];

destCoordRFT   = {cntrCoordRect1,cntrCoordRect2,cntrCoordRect3,cntrCoordRect4};

centreRect1 = CenterRectOnPoint(destVisStim,1*scrnWidth/4,1*screnHght/4);
centreRect2 = CenterRectOnPoint(destVisStim,3*scrnWidth/4,1*screnHght/4);
centreRect3 = CenterRectOnPoint(destVisStim,1*scrnWidth/4,3*screnHght/4);
centreRect4 = CenterRectOnPoint(destVisStim,3*scrnWidth/4,3*screnHght/4);

destRectRFT = {centreRect1,centreRect2,centreRect3,centreRect4};

end

