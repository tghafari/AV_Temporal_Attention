function triggerSend(handle, address, code, bTrigger)

if bTrigger == 1
  io64(handle, address, code); % send trigger code, e.g., 16 (pin 5)
end

end 