function countDownToBegin(toBegin,window,color)
%countDownToBegin(toBegin)
%   counts down to begin the program
%toBegin -> seconds to countdown
%window -> output of PsychImaging('OpenWindiw',...)
%color -> font color

cntdwnTxt={'Go','Set','Ready'};

for cntr = toBegin:-1:1
    DrawFormattedText(window,cntdwnTxt{cntr},'center','center',color); % Opens message
    Screen('Flip',window);
    WaitSecs(.95)
end
end
