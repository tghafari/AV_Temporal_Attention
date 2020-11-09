function removingBackGrounds(imgFileName,fileDirStim)

% Break down and mask the planes
img=imread([fileDirStim 'Stimuli/Face GreyScale/' num2str(imgFileName) '.tif']);
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
%Changing any white index to gray
r((r>225))=128;
g((g>225))=128;
b((b>225))=128;
% Reconstruct the RGB image:
img = cat(3,r,g,b);
saveas(imshow(img),[fileDirStim 'Stimuli/Face Removed Backgrounds/' num2str(imgFileName)],'tif')
end

% img = imread('596.tif'); %load a greyscale image
% SE  = strel('Disk',1,4);
% morphologicalGradient = imsubtract(imdilate(img, SE),imerode(img, SE));
% mask = im2bw(morphologicalGradient,0.03);
% SE  = strel('Disk',3,4);
% mask = imclose(mask, SE);
% mask = imfill(mask,'holes');
% mask = bwareafilt(mask,1);
% notMask = ~mask;
% mask = mask | bwpropfilt(notMask,'Area',[-Inf, 5000 - eps(5000)]);
% showMaskAsOverlay(0.5,mask,'r',img);
% r = img(:,:,1);
% g = img(:,:,2);
% b = img(:,:,3);
% %Using mask to remove back ground
% r(~mask) = 128;
% g(~mask) = 128;
% b(~mask) = 128;
% h = impoly(imgca,'closed',false);    %For manually selecting the image and separating it from bach ground
% % Reconstruct the RGB image:
% img = cat(3,r,g,b);
% imshow(img)