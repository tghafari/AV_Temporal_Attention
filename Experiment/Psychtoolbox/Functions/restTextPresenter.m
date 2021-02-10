function [blckHistory,vbl] = restTextPresenter(blckHistory,block,window,color,destCentreRFT,experDevCod,numTrial,trial,condMat)
%[blckHistory,vbl] = restTextPresenter(blckHistory,block,[soundPlayer],window,color,destCentreRFT,experDevCod,numTrial,trial,condMat,[RFT])
%   text is shown when the rest starts (end of each block)
%soundPlayer -> frequency tagging sound
%window -> output of PsychImaging('OpenWindow',...)
%color -> the color of text
%experDevCod -> experimenter's device code
%numTrial -> total number of trials (output of varIntro)
%trial -> the trial we are in
%condMat -> the main condition matrix
%RFT -> if 1: playing auditory RFT

blockTypTxt={'Auditory Regular \n Visual Irregular','Auditory Irregular \n Visual Regular','Auditory Irregular \n Visual Irregular'};

restTxt=['Rest for a few minutes \n Remaining:' num2str(round((numTrial-trial)*100/numTrial)) '%'];
nxtBlockTxt=['Next block is: \n' blockTypTxt{condMat(trial,1)}];
contTxt='Let the experimenter know when you are ready';

blckHistory{block}=blockTypTxt{condMat(trial-1,1)};

WaitSecs(.5)
% pause(soundPlayer) %Pause the auditory frequency tagging during rest
% clear sound    %check to see if can be deleted
Screen('Flip',window);
for quadCntr = 1:4
    DrawFormattedText(window,restTxt,destCentreRFT{quadCntr}(1),destCentreRFT{quadCntr}(2),color); % Opens message
end
Screen('Flip',window);
WaitSecs(0.1*60);

Screen('Flip',window);
for quadCntr = 1:4
    DrawFormattedText(window,nxtBlockTxt,destCentreRFT{quadCntr}(1),destCentreRFT{quadCntr}(2),color); % Opens message
end
Screen('Flip',window);
WaitSecs(0.05*60);

vbl=Screen('Flip',window);
for quadCntr = 1:4
    DrawFormattedText(window,contTxt,destCentreRFT{quadCntr}(1),destCentreRFT{quadCntr}(2),color); % Opens message
end
Screen('Flip',window);

KbStrokeWait(experDevCod);
WaitSecs(.1)
% %Resume auditory FT
% if RFT,resume(soundPlayer); end

end

