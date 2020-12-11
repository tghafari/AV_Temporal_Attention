function [visRFTFreq,PCRefreshRate,frmPhaseStep,photoDiodePatch] = RFTVars(window,windowRect,display,MEGLab)
%[visRFTFreq,PCRefreshRate,frmPhaseStep,photoDiodePatch] = RFTVars(window,windowRect,display)
%Frequency tagging variables and phase steps
%photodiode patch with size 1 degree * 1 degree

visRFTFreq    = 63;
if MEGLab, PCRefreshRate = 120; else, PCRefreshRate =60; end 
%Screen('NominalFrameRate',window);% Output from PTB - NOT Propixx frame
%rate -> doesn't work

frmPhaseStep  = visRFTFreq*2*pi/PCRefreshRate/12; %12 is the propixx frame rate / screen frame rate

photoDiodePatch = [windowRect(3)-angle2pix(display,1),windowRect(4)-angle2pix(display,1),windowRect(3),windowRect(4)];
end

