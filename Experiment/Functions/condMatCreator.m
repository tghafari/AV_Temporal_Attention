function [condMatPrim,condCell,condMat,eventTimer] = condMatCreator(blockInd,numBlock,numTrial,numStim,SOARef,rhythmicSOA,faceRand,correctResp)
% [condMatPrim, condCell, condMat] = condMatCreator(blockInd, numBlock, numStim, SOARef, rhythmicSOA, faceRand,correctResp)
%   Creates conition matrix for audioVisTempAtt program

%unnecessary columns are to be removed

%Preallocation
condCell=cell(length(blockInd)*numBlock,1);

for blockType=1:length(blockInd)
    for block=1:numBlock
        condMatPrim=nan(numStim,19);
        for trials=1:numStim
            condMatPrim(trials,:)=[blockType,block,trials,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
            %4audSOA,5aud ar/rhythmic,6visSOA,7vis ar/rhythmic,
            %8target presence,9face img index,10aud sound(pahandle),
            %11subj resp,12subj RT,13IBIcheck,
            %14audSOA check,15trialStartTime,
            %16audStimCheck,17visStimCheck,18visStimOff,19trialLength
        end
        %Put SOAs in condMatPrim
        rng('shuffle');
        SOARandAud=randperm(length(SOARef));
        SOARandVis=randperm(length(SOARef));        
        arrhythmicAudSOA=[1000*0.001;SOARef(SOARandAud)]; %SOA for arrhythmic auditory stimuli
        arrhythmicVisSOA=[1000*0.001;SOARef(SOARandVis)]; %SOA for arrhythmic visual stimuli
        if blockType==1; condMatPrim(:,4)=rhythmicSOA; else; condMatPrim(:,4)=arrhythmicAudSOA; end
        if blockType==2; condMatPrim(:,6)=rhythmicSOA; else; condMatPrim(:,6)=arrhythmicVisSOA; end
        %Define presence of target
        condMatPrim(:,8)=correctResp;
        %Randomize trials in each block and put them in condCell
        rng('shuffle');
        randomInd=randperm(numStim-1); %Do not randomize first row(because of fix.cross 1000ms)
        condCell{block+(numBlock*(blockType-1)),1}=condMatPrim([1 randomInd+1],:); 
    end
end

%Randomize blocks and put them in the property matrix
condCell=condCell(randperm(length(condCell))); condMat=cell2mat(condCell);

%Label aud and vis type
condMat(condMat(:,1)==1,5)=1; condMat(condMat(:,1)==1,7)=0; %auditory rhythmic visual arrhythmic
condMat(condMat(:,1)==2,5)=0; condMat(condMat(:,1)==2,7)=1; %auditory arrhythmic visual rhythmic 
condMat(condMat(:,1)==3,[5 7])=0; %both auditory and visual arrhythmic

%Define which face stim is presented in each trial
condMat(:,9)=faceRand;

%50ms visual presentation is added to the visual on trigger
condMat(:,18)=condMat(:,6)+.05;

%zeors just to keep the ~columns as is
condMat(:,19)=0;

%Creat a timer for events

%Calculate stimuli presentation times with elapsed time
for blkNr=1:(numBlock*length(blockInd))
    for stim=1:11
        condMat(stim+(12*(blkNr-1))+1,20)=sum(condMat((12*(blkNr-1)+1):stim+(12*(blkNr-1)),4))+condMat(stim+(12*(blkNr-1))+1,4);
        condMat(stim+(12*(blkNr-1))+1,21)=sum(condMat((12*(blkNr-1)+1):stim+(12*(blkNr-1)),6))+condMat(stim+(12*(blkNr-1))+1,6);
    end
end
condMat(:,20)=round(condMat(:,20),5); condMat(:,21)=round(condMat(:,21),5); 

%Define the modality (aud/vis) of each event (trigger)
eventTimer=zeros(numTrial*2,2);
for blkNr=1:(numBlock*length(blockInd))
    timrtmp=horzcat([condMat(12*(blkNr-1)+1:12*(blkNr-1)+12,20);condMat(12*(blkNr-1)+1:12*(blkNr-1)+12,21)],...
        [ones(12,1);3*ones(12,1)]);
    eventTimer(24*(blkNr-1)+1:24*(blkNr-1)+24,:)=sortrows(timrtmp);
end
% eventTimer=round(eventTimer,5); %compensate for very very small numbers that have been added without any apparent reasons

%Define where to present both stimulus types
for dbl=1:length(eventTimer)-1
    if eventTimer(dbl,1)==eventTimer(dbl+1,1) && eventTimer(dbl,2)~=eventTimer(dbl+1,2)
        eventTimer(dbl,2)=2;
        eventTimer(dbl+1,2)=nan;
    end        
end

eventTimer(eventTimer(:,1)==0,1)=1;
eventTimer(isnan(eventTimer(:,2)),:)=[];

end