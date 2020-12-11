%% Connect to Supercollider
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

% Define a helper function to trigger sounds: `trigger_sound`
% It takes one arg: The amplitude of the beep relative to the noise (from 0-1)
beep_freq = 1000.0; % Frequency of the beep in Hz
oscpath = '/stimulus'; % Name of the OSC responded (specified in Supercollider)
arg_types = 'ff'; % Type of each argument. These are floats
trigger_sound = @(beep_amp) oscsend(u, oscpath, arg_types, beep_amp, beep_freq);

%% Makse some noises

beep_amps = linspace(0, 1, 11); % Try out beeps at different volumes

for beep_amp = beep_amps
    trigger_sound(beep_amp)
    pause(1)
end
    
%% Close the connection
% Run this to clean up when you're finished
fclose(u);
