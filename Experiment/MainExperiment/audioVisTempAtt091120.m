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

%% Input

prompt     = {'Subject Code','Date','Training/Task','Testing PC','OS'}; %MEG PC subjects code, MEG PC date format, MeG=1 PC=0, OS-> mac=[] win=1
dlgtitle   = 'Details';
dims       = [1,30;1,30;1,30;1,30;1,30];
defaultans = {'B51A','20201120','Task','0','OSX'};
answer     = inputdlg(prompt,dlgtitle,dims,defaultans);

%% Introduce and Make Variables

% fileDirRes='Z:\MATLAB\AVTemporalProgram_MainLoc\Results\'; %For Windows
% fileDirStim='Z:\MATLAB\AVTemporalProgram_MainLoc\Stimuli\Stimuli\FaceRemovedBackgrounds\'; %For Windows
fileDirRes  = '/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/Results/'; %For Mac
fileDirStim = '/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/AVTemporal-Attention/Stimuli/Stimuli/FaceRemovedBackgrounds/'; %For Mac

[numStim,numBlock,blockInd,correctResp,SOARef,rhythmicSOA,numTrial,restTrials,respTimOut] = varIntro;

%% Matrix of images and conditions

[visStim,faceRand] = visStimReader(fileDirStim,numTrial);                                                        %Bring visual stimuli from the function
[~,~,condMat,~]    = condMatCreator(blockInd,numBlock,numTrial,numStim,SOARef,rhythmicSOA,faceRand,correctResp); %Conditions Matrix

%% Preallocation -- remove the unnecessaries

presentingVisStim = cell(numTrial,1);  %Visual stimuli for PTB
% audStartTime      = zeros(numTrial,1); %PsychPortAudio start time
% audStatus         = cell(numTrial,1);  %PsychPortAudio status cell
% visPresCheck      = zeros(numTrial,1); %Start of each timer
% visPresTime       = zeros(numTrial,1); %Flip time of visual stimulus
% stimOnset         = zeros(numTrial,1); %Approximate visual onset time
vblVisFrms        = zeros(725,1);      %Flip time of fixation cross after visual stimulus

%% Setup Auditory Variables
if strcmp(answer{5},'OSX'); deviceID=[]; else; deviceID=1; end

[toneSoundofRhythm,toneSoundofDetect,sampRate,FTpower,nrchannels,trigger,playerRFT] = audVars;
%Initializes Sound Driver- PTB
[condMat,stimpahandle,noStimpahandle] = PTBSoundSetuper(condMat,deviceID,sampRate,nrchannels,FTpower,toneSoundofRhythm,toneSoundofDetect);
%% Screen Setup

MEGLab = str2double(answer{4}); % MEG lab computer-> 1 PC->0
if MEGLab == 1, Screen('Preference', 'SkipSyncTests', 0); else, Screen('Preference', 'SkipSyncTests', 1); end % must be 0 during experiment

%Display distances and sizes -- adjust for the screen in use (Alex's
%tag_setup_projector)
display.dist       = 60; %cm -- laptop
display.width      = 28.65; %cm -- laptop
display.resolution = 2560; %pixel -- laptop

%Primary settings
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); %Draw to the external screen if avaliable
black        = BlackIndex(screenNumber);
white        = WhiteIndex(screenNumber);
grey         = white/2;
[window,windowRect] = PsychImaging('OpenWindow',screenNumber,grey,[100,100,1000,1000]); %Open an on screen window and color it grey

%Query the frame duration
ifi = Screen('GetFlipInterval',window);
FR  = Screen('NominalFrameRate',window); %Datapixx frame rate

%Retreive the maximum priority for this program
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

Screen('TextSize',window,50);
HideCursor();
%% Stimuli Introduction

for readImg = 1:size(condMat,1) %Create an openGL texture for face images
    presentingVisStim{readImg} = Screen('MakeTexture',window,visStim{readImg}(5:end,:,:));
end

%% Visual stimulus and fixation cross characteristics and hardware timing

visStimPresSecs = ms2sec(50);                              %Visual stimulus presentation time in secs
visStimFrames   = round(visStimPresSecs/ifi);
rectVisStim     = rectVisStimDest(5,5,display,windowRect); %Destination rectangle to present the stimulus

condMat(:,17) = round(condMat(:,15)/ifi);  %Auditory stim onset in frms
condMat(:,18) = round(condMat(:,16)/ifi);  %Visual stim onset in frms
condMat(:,19) = condMat(:,18)+3;            %Visual stim offset in frms

[xCenter,yCenter] = RectCenter(windowRect); %Get center coordinates
fixCrossDimPix    = 30; %Size of each arm of fixation cross in pixels
allCoords         = fixCrossCoord(fixCrossDimPix);
lineWidthPix      = 4; %Line width of cross
lineColorRGB      = [0.4,0.4,0.4]; %Color of fixation cross
Screen('BlendFunction',window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); %Blend funciton on

%% Main Experiment

% Start KbQueu routine
[expDev,partDev] = KbQueueStarterRoutine(MEGLab);

Screen('Flip',window);
vbl = getReadyTextPresenter(window,black,expDev,condMat); %Waits for experimenter's command and gets baseline VBL

% Play auditory frequency tagging tone
% play(playerRFT)
PsychPortAudio('Start',stimpahandle,1,inf);
PsychPortAudio('Start',noStimpahandle,1,inf);

% Countdown to start
countDownToBegin(3,window,black)

afterN1=zeros(3,1); afterWhile=zeros(3,1); afterAud=zeros(numTrial,1);
trilAud = 1;  trilVis = 1; trlVisCntr = 0; rest = 1; 
for blk=1 %(numBlock*length(blockInd))  %total nr of blocks = block types (3) * repetition of each block
    %Beginig of blocks fixation cross
%     if rest == 1
        restTrialsTime = GetSecs;
        Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
        condMat(trilAud,13) = Screen('Flip',window);
%     end
    beforeWhile=GetSecs;
    for frmsInBlk = 1:max(condMat(:,19))+1 %maximum nr of frames is 12/ifi (duration of each block is 12 secs)
%         Listen to keyboard inputs
        if trilAud>1
        [pressed,firstPress,~,lastPress] = KbQueueCheck(partDev); 
        if pressed, condMat = responseCollector(condMat,trilAud-1,firstPress,lastPress); end
        end
        %Trigger an event
        if frmsInBlk >= condMat(trilVis,18) && frmsInBlk <= condMat(trilVis,19)
                %Visual on
                Screen('DrawTexture',window,presentingVisStim{trilVis},[],rectVisStim);
                Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
                trlVisCntr = trlVisCntr+1;
        else
            %Visual off-Fixation cross
            Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
        end
        vblVisFrms(frmsInBlk,1) = Screen('Flip',window); %Flip the screen every frame
        if trlVisCntr==3; trilVis = trilVis+1; trlVisCntr = 0;  end

        if frmsInBlk == condMat(trilAud,17) 
            audOnset = GetSecs;
            %Auditory on
            condMat(trilAud,14) = PsychPortAudio('RescheduleStart',condMat(trilAud,10),audOnset,1);
%             audStatus{trilAud,1} = PsychPortAudio('GetStatus',condMat(trilAud,10));  %Can be removed after debugging
            afterAud(trilAud,1)=GetSecs-audOnset;
            trilAud = trilAud+1;
        end
    end
    
    %Rest after each block 
    restTextPresenter(playerRFT,window,black,expDev,numTrial,trilAud,condMat);
    
    afterWhile(blk)=GetSecs-beforeWhile;
    %Thank you messeage at the end
    if trilAud == 48  && trilVis == 48
        endTextPresenter(window,black)
        PsychPortAudio('Stop',stimpahandle);
        PsychPortAudio('Stop',noStimpahandle);
        KbQueueStop(partDev);
        sca
    end
end

PsychPortAudio('Close');
stop(playerRFT)
sca