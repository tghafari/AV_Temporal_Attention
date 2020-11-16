function [trigOff,trigStart,trigVisOn,trigVisOff,trigAud,trigFrqTag,trigTrialInfo] = triggerIntro
%[trigOff,trigStart,trigVisOn,trigVisOff,trigAud,trigFrqTag,trigTrialInfo] = triggerIntro
% trigger bits and codes for triggerInit and triggerSend
STI001 = 1;  STI002 = 2;  STI003 = 4;  STI004 = 8; 
STI005 = 16; STI006 = 32; STI007 = 64; STI008 = 128;
trigOff       = 0;
trigStart  = STI001;
trigVisOn  = STI002;
trigVisOff = STI003;
trigAud    = STI004;
trigFrqTag = STI005;
trigTrialInfo = []; %Not sure if necessary 
end
