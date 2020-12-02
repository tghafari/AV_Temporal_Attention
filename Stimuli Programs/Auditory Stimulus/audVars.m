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
indivAmp      = .5;                        
toneFreq      = 2000;                     
detectToneDif = 1.1;                       %Adjuste to individual thresholds- difference between detect and rhythm tone

%Create rampd sound
toneRhythm = indivAmp*sin(2*pi*toneFreq*audTimeVec); %Auditory data for main part
toneDetect = indivAmp*sin(2*pi*toneFreq*detectToneDif*audTimeVec);
rmpRhythm  = toneRhythm(1:length(audRampVec));  %Auditory data for ramped part
rmpDetect  = toneDetect(1:length(audRampVec));  

%Construct ramps
ampEnv = [linspace(0,1,length(rmpRhythm)),ones(1,length(toneRhythm)),linspace(1,0,length(rmpRhythm))];

%Multiply the amplitude envelope by the original waveform
rmpToneNoise = [rmpRhythm,toneRhythm,rmpRhythm] .* ampEnv;
rmpToneDetect = [rmpDetect,toneDetect,rmpDetect] .* ampEnv;

%Make frequency tagging noise
FTduration = 200;                       %Duration of a trial
tagFreq    = 40;                        %Frequency you want to tag auditory signal
FTpower    = 2;                         %Check this on Screen%
nrchannels = 2;                         %Number of channels
[FTAuditory,trigger]  = create_AM(tagFreq,FTpower,FTduration,sampRate,1); %Trigger is not used here
playerRFT             = audioplayer(FTAuditory,sampRate);
end

noise = randn(1,sampRate*duration); %Gausian noise
noise = noise/max(abs(noise)*2); %-.5 to .5 normalization
toneSoundofDetect = indivAmp*sin(2*pi*toneFreq*audTimeVec)+noise;
toneSoundofNoise = noise;
