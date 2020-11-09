
function GreyingScalingFaces(fileDir,optSizePix)

fileDirStim=[fileDir 'Face Neutral\CFD Version 2.0.3\CFD 2.0.3 Images\'];
outFiles=dir(fileDirStim);

for ii=4:length(outFiles) %first 3 files are nonsense
    faceFiles=dir([fileDirStim outFiles(ii).name]); %Open containing folder
    for jj=3:length(faceFiles)
        imgFileName=[fileDirStim outFiles(ii).name '\' faceFiles(jj).name];
        if faceFiles(jj).name(end-4)=='N'
            RGBImage=imread(imgFileName); %Open RGB image
            greyImg=rgb2gray(RGBImage);
            squareFac=(size(greyImg,2)-size(greyImg,1))/2;
            greySquare=greyImg(:,squareFac+1:squareFac+size(greyImg,1));
            saveas(imshow(imresize(greySquare,optSizePix)),[fileDir 'Face GreyScale\' num2str(ii-3)],'tif')
        end
    end
end
end

% %inputs
% fileDir='Z:\MATLAB\Stimuli\Stimuli\Face Stimuli\';
% optSizePix=[200 200]; %Preferred size of image in pixels--to be modified for each screen


% %Add 0 before each number to reach 3 digit numbers for file names
% if floor(log10(ii))+1==1; imgNum=['00' num2str(ii)]; elseif floor(log10(ii))+1==2; imgNum=['0' num2str(ii)];end