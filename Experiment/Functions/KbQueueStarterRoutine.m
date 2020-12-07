function [expDevCode,partDevCode] = KbQueueStarterRoutine(MEGLab)
%KbQueueStarterRoutine(MEGLab,expDev)
% Starts KbQueueRoutine for the keyboard to start listening
%expDev -> Experimenter's device code
%partDev -> Participant's device code (NATA box typically)
% A call to KbQueueCheck is still needed 

KbName('UnifyKeyNames');
% KB response: '4$' and '7&' are the left and right index fingers of the (5-button) NATA boxes
if MEGLab == 1, KB = KbName('7&'); expDevCode=-1; partDevCode=-1;
else, KB = KbName('LeftShift'); expDevCode=-1; partDevCode=-1; end

scanList = zeros(1,256);
scanList(KB) = 1;           

KbQueueCreate(expDevCode,scanList);  %Create queue
KbQueueStart;                        %Start listening to input
KbQueueFlush;                        %Clear all keyboard presses so far

end
