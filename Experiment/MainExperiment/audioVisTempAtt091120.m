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

[visStim,faceRand]       = visStimReader(fileDirStim,numTrial);                                                        %Bring visual stimuli from the function
[~,~,condMat,eventTimer] = condMatCreator(blockInd,numBlock,numTrial,numStim,SOARef,rhythmicSOA,faceRand,correctResp); %Conditions Matrix

%% Preallocation -- remove the unnecessaries

presentingVisStim = cell(numTrial,1);  %Visual stimuli for PTB
audStartTime      = zeros(numTrial,1); %PsychPortAudio start time
audStatus         = cell(numTrial,1);  %PsychPortAudio status cell
visPresCheck      = zeros(numTrial,1); %Start of each timer
visPresTime       = zeros(numTrial,1); %Flip time of visual stimulus
stimOnset         = zeros(numTrial,1); %Approximate visual onset time
vblVisFrms         = zeros(numTrial,1); %Flip time of fixation cross after visual stimulus

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

eventTimer(:,3) = eventTimer(:,1)/ifi;      %Convert trigger secs to frames
eventTimer(:,3) = round(eventTimer(:,3)); 
eventTimer(:,4) = eventTimer(:,3)+3;        %Visual offset
eventTimer(eventTimer(:,2)==1,4) = eventTimer(eventTimer(:,2)==1,4)-3;


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

afterWaitScs=zeros(max(eventTimer(:,3)),1); afterGetSecs=zeros(max(eventTimer(:,3)),1); afterBigIf=zeros(max(eventTimer(:,3)),1);
afterN1=zeros(3,1); afterWhile=zeros(3,1);
trilAud = 1;  trilVis = 1; timCntr = 1; rest = 1; 
for blk=1:3 %(numBlock*length(blockInd))  %total nr of blocks = block types (3) * repetition of each block
    beforeN1=GetSecs;
    %Beginig of blocks fixation cross
    if rest == 1
        restTrialsTime = GetSecs;
        Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
        fixPointVBL = Screen('Flip',window);
    end
    afterN1(blk,1)=GetSecs-beforeN1;
    beforeWhile=GetSecs;
    rest=0;
    for frmsInBlk = 1:max(eventTimer(:,3)) %maximum nr of frames is 12/ifi (duration of each block is 12 secs)
        %Listen to keyboard inputs
        beforeResp=GetSecs;
        if trilAud>1
        [pressed,firstPress,~,lastPress] = KbQueueCheck(partDev); 
        if pressed, condMat = responseCollector(condMat,trilAud-1,audStartTime,firstPress,lastPress); end
        end
        afterGetSecs(frmsInBlk,1)=GetSecs-beforeResp;
        %Trigger an event
        beforeBigIf=GetSecs;
        if frmsInBlk >= eventTimer(timCntr,3) && frmsInBlk <= eventTimer(timCntr,4)
            timeStart = GetSecs;
            if (eventTimer(timCntr,2) == 2 || eventTimer(timCntr,2) == 3) 
                %Visual on
                Screen('DrawTexture',window,presentingVisStim{trilVis},[],rectVisStim);
                Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
                trilVis = trilVis+1;
            elseif eventTimer(timCntr,2) == 1
                %Visual off-Fixation cross
                Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
            end
            vblVisFrms(trilVis,1) = Screen('Flip',window);
            if eventTimer(timCntr,2) == 1 || eventTimer(timCntr,2) == 2
                %Auditory on
                audStartTime(trilAud,1) = PsychPortAudio('RescheduleStart',condMat(trilAud,10),timeStart,1);
                audStatus{trilAud,1}    = PsychPortAudio('GetStatus',condMat(trilAud,10));  %Can be removed after debugging
                trilAud = trilAud+1; 
            end
            timCntr = timCntr+1; 
            %Break the while on rest trials
            if ismember(trilAud-1,restTrials) && ismember(trilVis-1,restTrials)
                restTextPresenter(playerRFT,window,black,expDev,numTrial,trilAud,condMat);
                rest=1;
                break
            end
        else
            %Visual off-Fixation cross
            Screen('DrawLines',window,allCoords,lineWidthPix,lineColorRGB,[xCenter,yCenter],2);
            vblVisFrms(trilVis,1) = Screen('Flip',window);
        end
        afterBigIf(frmsInBlk,1)=GetSecs-beforeBigIf;
    end
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