function numTrial = numTrialCalculator(visType,audType,numBlock,numStim)

%numTrial = numTrialCalculator(visType,audType,numBlock,numStim)
%   Calculates the number of trials according to the input arguments

numTrial=(length(visType)*length(audType)-1)*numBlock*numStim; %Total number of trials

end

