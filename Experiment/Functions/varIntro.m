function [numStim,numBlock,blockInd,correctResp,SOARef,rhythmicSOA,numTrial,restTrials,respTimOut,indivAmp]=varIntro
%[numStim,numBlock,blockInd,correctResp,SOARef,rhythmicSOA,numTrial,restTrials]=varIntro
%   Introduces variables of interest for audioVisTempAtt task
%   to change any repetition you should edit this function

repetition  = 1; %Number of repetitions of each stimulus
numStim     = (11*repetition)+1; %Number of stimuli in each block
numBlock    = 7; %Total number of blocks in each condition
visType     = [0,1]; %is visual stimulus rhythmic?
audType     = [0,1]; %is auditory stimulus rhythmic?
blockInd    = [1,2,3]; %block type: 1)AudRhythm*VisArrhythm; 2)AudArrhythm*VisRhythm; 3)AudArrhythm*VisArrhythm
correctResp = zeros(numStim,1); %1=>target present 0=>target absent
correctResp(2:5:end,:) = 1;
SOARef      = repmat(500:100:1500,1,(numStim-1)/11)'*0.001; %All SOAs
rhythmicSOA = 1000*ones(numStim,1)*0.001; %SOA for rhythmic stimuli

numTrial    = numTrialCalculator(visType,audType,numBlock,numStim); %Calculate the number of trials (stimuli)
restTrials  = (1:20)*numTrial/(numBlock*blockInd(end)); %Rest for every 20 trials

respTimOut  = .6; %time during which subject can respond

indivAmp    = .3; %individual beep volume-output of staircase

end
