function answer = InputPrompt
%answer = InputPrompt
%  returns the details of subject and data collection in answer cell

prompt     = {'Subject Numbed','Subject Code','Date','Training/Task','Testing PC','OS'}; %Sub #,MEG PC subjects code, MEG PC date format, MeG=1 PC=0, OS-> mac=[] win=1
dlgtitle   = 'Details';
dims       = [1,30;1,30;1,30;1,30;1,30;1,30];
defaultans = {'101','B51A','20201120','Task','0','OSX'};
answer     = inputdlg(prompt,dlgtitle,dims,defaultans);

end

