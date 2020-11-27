function [display,screenNumber,black,white,grey] = visVars(answer)
%[display,visRFTFreq,screenNumber,black,white,grey] = visVars(answer)
%   visual stimulus and display variables

%Display distances and sizes -- adjust for the screen in use (Alex's
%tag_setup_projector)
if strcmp(answer{5},'MEG'), MEGLab = 1; else, MEGLab = 0; end
if MEGLab
    display.dist       = 60;    %cm -- MEGLab
    display.width      = 28.65; %cm -- MEGLab
    display.resolution = 2560;  %pixel -- MEGLab
else
    display.dist       = 60;    %cm -- laptop
    display.width      = 28.65; %cm -- laptop
    display.resolution = 2560;  %pixel -- laptop
end

%Primary settings
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); %Draw to the external screen if avaliable
black        = BlackIndex(screenNumber);
white        = WhiteIndex(screenNumber);
grey         = white/2;

end

