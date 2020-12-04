function [rmpToneNoise,rmpToneDetect,sampRate,FTpower,nrchannels,trigger,playerRFT] = audVars 
% [rmpToneNoise,rmpToneDetect,sampRate,FTpower,nrchannels,trigger,playerRFT] = audVars 
%This function introduces auditory variables for both stimulus and
%frequency tagging sounds

rng('shuffle')

%Basic sound vars
sampRate      = 48000;                     %Frequency of the sound
rampDur       = ms2sec(15);                %Duration of fade in/out (in secs)
duration      = ms2sec(50)-rampDur*2;      %Duration (in secs)
audTimeVec    = 0:1/sampRate:duration;     %Auditory duration in sf steps
audRampVec    = 0:1/sampRate:rampDur;
indivAmp      = 1;                         %Calculated from staircase 
toneFreq      = 1000;                      %Should be decided

%Create rampd sound
toneRhythm = randn(1,length(audTimeVec));            %Gausian noise
toneDetect = indivAmp*sin(2*pi*toneFreq*audTimeVec);
rmpRhythm  = toneRhythm(1:length(audRampVec));       %Auditory data for ramped part
rmpDetect  = toneDetect(1:length(audRampVec));  

%Construct ramps
ampEnv = [linspace(0,1,length(rmpRhythm)),ones(1,length(toneRhythm)),linspace(1,0,length(rmpRhythm))];

%Multiply the amplitude envelope by the original waveform and normalize
%according to the max/min of auditory hardware (-1 1)
rmpToneNoise  = ([rmpRhythm,toneRhythm,rmpRhythm].*ampEnv)/max(abs([rmpRhythm,toneRhythm,rmpRhythm]));
rmpToneDetect = ([rmpDetect,toneDetect,rmpDetect].*ampEnv)/(max(abs([rmpDetect,toneDetect,rmpDetect]))*2);
rmpToneDetect = rmpToneNoise./2+rmpToneDetect;

%Make frequency tagging noise
FTduration = 200;                       %Duration of a trial
tagFreq    = 40;                        %Frequency you want to tag auditory signal
FTpower    = 2;                         %Check this on Screen%
nrchannels = 2;                         %Number of channels
[FTAuditory,trigger]  = create_AM(tagFreq,FTpower,FTduration,sampRate,1); %Trigger is not used here
playerRFT             = audioplayer(FTAuditory,sampRate);
end

