function [visRFTFreq,PCRefreshRate,frmPhaseStep] = RFTVars
%[visRFTFreq,PCRefreshRate,frmPhaseStep,visRFTPhase] = RFTVars(window,visRFTPhase)
%Frequency tagging variables and phase steps

visRFTFreq    = 63;
PCRefreshRate = Screen('NominalFrameRate',window);% Output from PTB - NOT Propixx frame rate
frmPhaseStep  = visRFTFreq*2*pi/PCRefreshRate/12; %12 is the propixx frame rate / screen frame rate

end

