function upcmBrghtnss = RFTBrghtnssCalculator(upcmPhase)
%upcmBrghtnss = RFTBrghtnssCalculator(upcmPhase)
% Given the RFT phase calculates the brightness
    upcmBrghtnss = 1/2*(1+sin(upcmPhase));
end

