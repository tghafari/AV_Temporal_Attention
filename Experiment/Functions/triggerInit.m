function [handle, address] = triggerInit(bTrigger)

handle = [];
address = [];
if bTrigger == 1
  address = hex2dec('BFF8'); % check this port address 
  handle = io64;
  status = io64(handle);
  io64(handle, address, 0); % reset trigger
end
  
end
