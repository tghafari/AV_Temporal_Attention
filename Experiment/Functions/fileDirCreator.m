function [fileDirStim,fileDirRes] = fileDirCreator(answer)
%[fileDirStim,fileDirRes] = fileDirCreator(answer)
%   cd to and creates subject directory according to OS

if strcmp(answer{5},'Mac') %Mac
    fileDirRes  = '/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/Results/'; 
    fileDirStim = '/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/AVTemporal-Attention/Stimuli/Stimuli/FaceRemovedBackgrounds/'; 
elseif strcmp(answer{5},'Win') % Windows
    fileDirRes='Z:\MATLAB\AVTemporalProgram_MainLoc\Results\'; 
    fileDirStim='Z:\MATLAB\AVTemporalProgram_MainLoc\Stimuli\Stimuli\FaceRemovedBackgrounds\'; 
elseif strcmp(answer{5},'MEG')
    fileDirRes='Z:\MATLAB\AVTemporalProgram_MainLoc\Results\'; 
    fileDirStim='Z:\MATLAB\AVTemporalProgram_MainLoc\Stimuli\Stimuli\FaceRemovedBackgrounds\'; 
end

mkdir([fileDirRes, 'Sub' answer{1}]);

end

