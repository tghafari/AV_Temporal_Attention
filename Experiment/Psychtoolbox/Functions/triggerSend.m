function triggerSend(handle, address, code, MEGLab)
%triggerSend(handle, address, code, MEGLab)

if MEGLab == 1
  io64(handle, address, code); % send trigger code, e.g., 16 (pin 5)
end

end 