%% First thing's first

clear; clc
%Lets change the frequency of vis and aud to their preferred frequency (.7 & 1.4 -- nature comm 2020- Zalta)
%% Handle on-screen errors

% try
%     windowPtr = Screen('OpenWindow', 0);
%     %Place a bad line of code here...
% catch ME
%     Screen('CloseAll');
%     rethrow(ME);
% end
% Screen('CloseAll');

%% Input and OS folder preparations

answer = InputPrompt;
[fileDirStim,fileDirRes] = fileDirCreator(answer); %needs to be adjusted to MEG PC folder

%% Make variables

[numStim,numBlock,blockInd,correctResp,SOARef,rhythmicSOA,numTrial,restTrials,respTimOut] = varIntro;
[trigOff,trigStart,trigVisOn,trigVisOff,trigAud,trigFrqTag,~] = triggerIntro;               %introduce triggers
%% Matrix of images and conditions

[visStim,faceRand] = visStimReader(fileDirStim,numTrial); %Bring visual stimuli from the function
[~,~,condMat,~]    = condMatCreator(blockInd,numBlock,numTrial,numStim,SOARef,rhythmicSOA,faceRand,correctResp); %Conditions Matrix
%% Preallocation -- remove the unnecessaries and functionize at eventually

presentingVisStim = cell(numTrial,1);  %Visual stimuli for PTB
blckHistory       = cell(numBlock,1);  %Confirms the order of blocks presented
audStatus         = cell(numTrial,1);  %PsychPortAudio status cell
vblVisFrms        = zeros(725,1);      %Flip time of fixation cross after visual stimulus
afterWhile        = zeros(3,1);
afterAud          = zeros(numTrial,1); 

% audStartTime      = zeros(numTrial,1); %PsychPortAudio start time
% visPresCheck      = zeros(numTrial,1); %Start of each timer
% visPresTime       = zeros(numTrial,1); %Flip time of visual stimulus
% stimOnset         = zeros(numTrial,1); %Approximate visual onset time

%% Setup Auditory Variables

if strcmp(answer{5},'Mac'); deviceID=[]; elseif strcmp(answer{5},'Win'), deviceID=1; 
elseif strcmp(answer{5},'MEG'), deviceID=20; end

[toneNoise,toneDetect,sampRate,FTpower,nrchannels,trigger,playerRFT] = audVars;
%Initializes Sound Driver- PTB
[condMat,stimpahandle,noStimpahandle] = PTBSoundSetuper(condMat,deviceID,sampRate,nrchannels,FTpower,toneNoise,toneDetect);
%% Screen Setup

if strcmp(answer{5},'MEG'), MEGLab = 1; else, MEGLab = 0; end % MEG lab computer-> 1 PC->0
if MEGLab == 1, Screen('Preference', 'SkipSyncTests', 0); 
else, Screen('Preference', 'SkipSyncTests', 1); end % must be 0 during experiment

%Introduce visual variables
[display,screenNumber,black,~,grey] = visVars(answer);

%Open Screen
[window,windowRect] = PsychImaging('OpenWindow',screenNumber,grey,[100,100,1000,1000]); %Open an on screen window and color it grey
Screen('BlendFunction',window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');                 %Blend funciton on

%Query the frame duration
ifi         = Screen('GetFlipInterval',window);
FRDatapixx  = Screen('NominalFrameRate',window); %Datapixx frame rate -- decide how to not mix up with PC screen FR

% Propixx
% Datapixx('Close')
if MEGLab == 1
propixx_mode = 5;
Datapixx('Open');
Datapixx('SetPropixxDlpSequenceProgram',propixx_mode);
Datapixx('RegWrRd')
end

%Retreive the maximum priority for this program
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

Screen('TextSize',window,50);
HideCursor();
%% Stimuli Introduction

for readImg = 1:size(condMat,1) %Create an openGL texture for face images
    presentingVisStim{readImg} = Screen('MakeTexture',window,visStim{readImg}(5:end,:,:));
end
%% Visual stimulus and fixation cross characteristics and hardware timing -- functionize

[visRFTFreq,PCRefreshRate,frmPhaseStep,photoDiodePatch] = RFTVars(window,windowRect,display);
destVisStim                = rectVisStimDest(5,5,display,windowRect);   %Destination rectangle to present the stimulus
[destCoordRFT,destRectRFT] = RFTDestCalculator(destVisStim,windowRect); %Calculates centres of rectangles for RFT

%time and frame conversions
visStimPresSecs = ms2sec(50);                  %Visual stimulus presentation time in secs
visStimFrames   = round(visStimPresSecs/ifi);
condMat(:,17)   = round(condMat(:,15)/ifi);    %Auditory stim onset in frms
condMat(:,18)   = round(condMat(:,16)/ifi);    %Visual stim onset in frms
condMat(:,19)   = condMat(:,18)+visStimFrames; %Visual stim offset in frms

[xCenter,yCenter] = RectCenter(windowRect); %Get center coordinates
fixCrossDimPix    = 30;                     %Size of each arm of fixation cross in pixels
allCoords         = fixCrossCoord(fixCrossDimPix);
lineWidthPix      = 4;                      %Line width of cross
lineColorRGB      = [0.4,0.4,0.4];          %Color of fixation cross

[trigHandle,trigAdd] = triggerInit(MEGLab); %initiate triggers
%% Main Experiment

% Start KbQueu routine -- needs modification for Nata box
[expDev,partDev] = KbQueueStarterRoutine(MEGLab);

Screen('Flip',window);
vbl = getReadyTextPresenter(window,black,expDev,condMat); %Waits for experimenter's command and gets baseline VBL

% Play auditory frequency tagging tone
% play(playerRFT)
PsychPortAudio('Start',stimpahandle,1,inf);
PsychPortAudio('Start',noStimpahandle,1,inf);

% Countdown to start
countDownToBegin(3,window,black)

trilAud = 1;  trilVis = 1; trlVisCntr = 0; visRFTPhase = 0;
for blk = 1 %(numBlock*length(blockInd))  %total nr of blocks = block types (3) * repetition of each block
    
    %Beginig of blocks fixation cross
    triggerSend(trigHandle,trigAdd,trigStart,MEGLab); 
    Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
    condMat(trilAud,13) = Screen('Flip',window);
    
    beforeWhile=GetSecs;
    for frmsInBlk = 1:max(condMat(:,19))+1 %maximum nr of frames is 12/ifi (duration of each block is 12 secs)
        % Listen to keyboard inputs
        if trilAud>1
        [pressed,firstPress,~,lastPress] = KbQueueCheck(partDev); 
        if pressed, condMat = responseCollector(condMat,trilAud-1,firstPress,lastPress); end
        end
        
        %Calculate upcoming brightness
        [visRFTPhase,upcmPhase] = RFTPhaseCalculator(visRFTPhase,frmPhaseStep);
        upcmBrghtnss = RFTBrghtnssCalculator(upcmPhase);
        
        %Calculate color for RFT
        clrByQuad = RFTColorCalculator(upcmBrghtnss);
        
  %Start an event 
        %Visual stimulus + frequency tagging
        for quadCntr = 1:4
            if frmsInBlk >= condMat(trilVis,18) && frmsInBlk <= condMat(trilVis,19)
                %Visual on
                Screen('DrawTexture',window,presentingVisStim{trilVis},[],destRectRFT{quadCntr});
                Screen('DrawLines',window,allCoords,lineWidthPix,clrByQuad(:,quadCntr),destCoordRFT{quadCntr},2);
                Screen('FillRect',window,clrByQuad(:,quadCntr),photoDiodePatch);
                trlVisCntr = trlVisCntr+1;
            else
                %Visual off-Fixation cross
                Screen('DrawLines',window,allCoords,lineWidthPix,clrByQuad(:,quadCntr),destCoordRFT{quadCntr},2);
                Screen('FillRect',window,clrByQuad(:,quadCntr),photoDiodePatch);
            end
        end
        if trlVisCntr==1,      triggerSend(trigHandle,trigAdd,trigVisOn,MEGLab); 
        elseif trlVisCntr==16, triggerSend(trigHandle,trigAdd,trigVisOff,MEGLab); end  
        vblVisFrms(frmsInBlk,1) = Screen('Flip',window); %Flip the screen every frame
        if trlVisCntr==16, trilVis = trilVis+1; trlVisCntr = 0;  end
        
        %Auditory stimulus
        if frmsInBlk == condMat(trilAud,17) 
            audOnset = GetSecs;
            triggerSend(trigHandle,trigAdd,trigAud,MEGLab); 
            condMat(trilAud,14)  = PsychPortAudio('RescheduleStart',condMat(trilAud,10),audOnset,1);
            audStatus{trilAud,1} = PsychPortAudio('GetStatus',condMat(trilAud,10));  %Can be removed after debugging
            afterAud(trilAud,1)  = GetSecs-audOnset; %should be removed after debugging
            trilAud = trilAud+1;
        end
    end
    afterWhile(blk)=GetSecs-beforeWhile; %should be removed after debugging
    triggerSend(trigHandle,trigAdd,trigOff,MEGLab); %clear trigger
        
    %Thank you messeage at the end
    if blk == 2 %numBlock*length(blockInd)
        endTextPresenter(window,black)
        PsychPortAudio('Stop',stimpahandle);
        PsychPortAudio('Stop',noStimpahandle);
        KbQueueStop(partDev);
        sca
        break
    end            
    
    %Rest after each block
    [blckHistory,~] = restTextPresenter(blckHistory,blk,playerRFT,window,black,expDev,numTrial,trilAud,condMat,0);
end

PsychPortAudio('Close');
stop(playerRFT)
sca

%% Saving data
condCell=cell(size(condMat,1),5); 
condCell(condMat(:,1)==1)={'audReg'};     condCell(condMat(:,1)==2)={'visReg'}; condCell(condMat(:,1)==3)={'noReg'};
condCell(condMat(:,5)==0,2)={'audIrreg'}; condCell(condMat(:,5)==1,2)={'audReg'};
condCell(condMat(:,7)==0,3)={'visIrreg'}; condCell(condMat(:,7)==1,3)={'visReg'};
condCell(condMat(:,8)==0,4)={'noTarget'}; condCell(condMat(:,8)==1,4)={'Target'};
condCell(condMat(:,11)==0,5)={'noResp'};  condCell(condMat(:,11)==1,5)={'Resp'};

condMatTbl = array2table(condMat,'VariableNames',{'blockType','blockNm','trilNm','audSOA','aud_reg/irreg','visSOA','vis_reg/irreg','target_presence'...
    ,'face_img_ix','aud_handle','key_pressed','RT','IBI_time','aud_SOA_check','aud_in_elapsed','vis_in_elapsed','aud_onset_frms',...
    'vis_onset_frms','vis_offset_frms','last_key_pressed','last_key_time'});  
%Clear unnecessary files
% clear ...
% save([fileDirRes, 'Sub' answer{1} filesep 'BehavioralData' filesep])
