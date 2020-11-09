function [condMat,stimpahandle,noStimpahandle] = PTBSoundSetuper(condMat,deviceID,sampRate,nrchannels,FTpower,toneSoundofRhythm,toneSoundofDetect)
%[condMat,stimpahandle,noStimpahandle] = PTBSoundSetuper(condMat,deviceID,sampRate,nrchannels,FTpower,toneSoundofRhythm,toneSoundofDetect)
%   Setups sound for PTB and makes buffers for both rhythm and to-detect
%   sounds

InitializePsychSound(1);

%Create not-to-detect sound
noStimpahandle = PsychPortAudio('Open',deviceID,1,3,sampRate,nrchannels,1);
PsychPortAudio('Volume',noStimpahandle,FTpower);
PsychPortAudio('FillBuffer',noStimpahandle,repmat(toneSoundofRhythm,nrchannels,1));     %Loads data into buffer
condMat((condMat(:,8)==0),10) = noStimpahandle;

%Create to-detect sound
stimpahandle = PsychPortAudio('Open',deviceID,1,3,sampRate,nrchannels,1);
PsychPortAudio('Volume',stimpahandle,FTpower);
PsychPortAudio('FillBuffer',stimpahandle,repmat(toneSoundofDetect,nrchannels,1));       %Loads data into buffer
condMat((condMat(:,8)==1),10) = stimpahandle;

end

