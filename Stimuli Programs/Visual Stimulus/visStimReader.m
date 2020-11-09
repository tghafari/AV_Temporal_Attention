function [visStim, faceRand]=visStimReader(fileDirStim,numTrial)


%Read visual stimuli
fileDirFace=dir(fileDirStim); 

modNumTrialZero=mod(numTrial,1:numTrial);
quotient=find(modNumTrialZero==0);
repmatDecider=quotient(find(numTrial./quotient<=(length(fileDirFace)-2),1)); %Just making sure the number of images correspond to numTrial--there is no misshape error
faceMatInd=repmat((1:numTrial/repmatDecider)',repmatDecider,1); %Choose the first appropriate number of images
faceRand=faceMatInd(randperm(length(faceMatInd)));

visStim=cell(numTrial,1);

for stim=1:numTrial
    visStim{stim,1}=imread([fileDirStim,num2str(faceRand(stim))],'tif');
end

end