function [SCTriggerSound,u] = superColliderStarter
%[SCTriggerSound,u] = superColliderStarter
% Connect to Supercollider

% Run this after executing supercollider_example.scd

if ~exist('udp', 'file')
    error('You need to install the "Instrument Control" package')
end

if ~exist('oscsend', 'file')
    msg = ['Make sure the file "oscsend.m" is in your search path' 10 ...
        'You can find it here:' 10 ...
        'https://uk.mathworks.com/matlabcentral/fileexchange/31400-send-open-sound-control-osc-messages'];
    error(msg)
end

ip_address = '127.0.0.1'; % When SC and Matlab are on the same machine
port = 57120; % Which port to connect to
u = udp(ip_address, port);
fopen(u);

% Define a helper function to trigger sounds to Super Collider: `triggerSound`
% It takes one arg: The amplitude of the beep relative to the noise (from 0-1)
beepFreq = 1000.0; % Frequency of the beep in Hz
oscpath = '/stimulus'; % Name of the OSC responded (specified in Supercollider)
argTypes = 'ff'; % Type of each argument. These are floats
SCTriggerSound = @(beepAmp) oscsend(u, oscpath, argTypes, beepAmp, beepFreq);

end

