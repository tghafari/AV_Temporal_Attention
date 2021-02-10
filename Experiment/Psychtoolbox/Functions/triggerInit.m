function [handle, address] = triggerInit(MEGLab)
%[handle, address] = triggerInit(MEGLab)
%Initiates sending triggers to MEG pc

handle = [];
address = [];
if MEGLab == 1
  address = hex2dec('BFF8'); % check this port address 
  handle = io64;
  status = io64(handle);
  io64(handle, address, 0); % reset trigger
end
  
end
