function answer = InputPrompt
%answer = InputPrompt
%  returns the details of subject and data collection in answer cell
%Sub #,MEG PC subjects code, MEG PC date format, MEGP=1 PC=0, OS-> mac=XOS
%win=Win

prompt     = {'Subject Numbed','Subject Code','Date','Training/Task','Testing PC','OS'}; 
dlgtitle   = 'Details';
dims       = [1,30;1,30;1,30;1,30;1,30;1,30];
defaultans = {'101','B51A','20201120','Task','PC','OSX'};
answer     = inputdlg(prompt,dlgtitle,dims,defaultans);

end

