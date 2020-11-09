function [toneSoundofRhythm,toneSoundofDetect,sampRate,FTpower,nrchannels,trigger,playerRFT] = audVars 
%[toneSoundofRhythm,toneSoundofDetect,FTpower,nrchannels,trigger,playerRFT] = audVars 

%Make auditory tone to detect--including 5 ms rise and 5 ms fall shaped by a Blackman window (2017- van Diepen)
sampRate   = 48000;                     %Frequency of the sound
duration   = ms2sec(50);                %Duration (time in secs)
audTimeVec = 0:1/sampRate:duration;     %Auditory duration in sf steps
indivAmp   = .5;                        %Adjuste to individual thresholds
toneFreq   = 1000;
toneSoundofRhythm = indivAmp*sin(2*pi*toneFreq*audTimeVec);
toneSoundofDetect = indivAmp*sin(2*pi*toneFreq*1.1*audTimeVec);

%Make frequency tagging noise
FTduration = 200;                       %Duration of a trial
tagFreq    = 40;                        %Frequency you want to tag auditory signal
FTpower    = 2;                         %Check this on Screen%
nrchannels = 2;                         %Number of channels
[FTAuditory,trigger]  = create_AM(tagFreq,FTpower,FTduration,sampRate,1); %Trigger is not used here
playerRFT             = audioplayer(FTAuditory,sampRate);

end

