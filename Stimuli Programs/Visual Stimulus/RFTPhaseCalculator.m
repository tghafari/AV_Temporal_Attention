function [visRFTPhase,upcmPhase] = RFTPhaseCalculator(visRFTPhase,frmPhaseStep)
%[visRFTPhase,upcmPhase] = RFTPhaseCalculator(visRFTPhase,frmPhaseStep)
%frmPhaseStep => output of RFTVars
%visRFTPhase => equals zero in the first execution
% What is the phase of the RFT flicker at each "Propixx-frame"?

upcmPhase   = visRFTPhase+(frmPhaseStep*1:12);
upcmPhase   = wrapTo2Pi(upcmPhase);
visRFTPhase = upcmPhase(end); % Keep track of the last phase

end

