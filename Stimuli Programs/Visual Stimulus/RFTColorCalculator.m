function clrByQuad = RFTColorCalculator(upcmBrghtnss)
%clrByQuad = RFTColorCalculator(upcmBrghtnss)
% Builds images according to the brighness (calculated using phase)
clrByQuad = nan(3, 4); % RGB by quadrant
for clrChnlCntr = 1:3
    for quadCntr = 1:4
        nxtBrghtnss = upcmBrghtnss(1); % Take the next brightness level
        upcmBrghtnss(1) = [];          % And delete it from the list
        clrByQuad(clrChnlCntr, quadCntr) = nxtBrghtnss;
    end
end
end

