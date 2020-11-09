function vbl = restTextPresenter(soundPlayer,window,color,experDevCod,numTrial,trial,condMat)
%vbl = restTextPresenter(soundPlayer,window,color,experDevCod,numTrial,trial,condMat)
%   text is shown when the rest starts (end of each block)
%soundPlayer -> frequency tagging sound
%window -> output of PsychImaging('OpenWindow',...)
%color -> the color of text
%experDevCod -> experimenter's device code
%numTrial -> total number of trials (output of varIntro)
%trial -> the trial we are in
%condMat -> the main condition matrix

blockTypTxt={'Auditory Regular \n Visual Irregular','Auditory Irregular \n Visual Regular','Auditory Irregular \n Visual Irregular'};

restTxt=['Rest for a few minutes \n Remaining:' num2str(round((numTrial-trial)*100/numTrial)) '%'];
nxtBlockTxt=['Next block is: \n' blockTypTxt{condMat(trial,1)}];
contTxt='Let the experimenter know when you are ready';

WaitSecs(.5)
pause(soundPlayer) %Pause the auditory frequency tagging during rest
clear sound       
Screen('Flip',window);
DrawFormattedText(window,restTxt,'center','center',color); % Opens message
Screen('Flip',window);
WaitSecs(0.1*60);
Screen('Flip',window);
DrawFormattedText(window,nxtBlockTxt,'center','center',color); % Opens message
Screen('Flip',window);
WaitSecs(0.05*60);
vbl=Screen('Flip',window);
DrawFormattedText(window, contTxt, 'center', 'center', color); % Opens message
Screen('Flip', window);
KbStrokeWait(experDevCod);
WaitSecs(.1)
% resume(soundPlayer) %Resume auditory FT

end

