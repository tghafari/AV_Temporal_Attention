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

%% Send a message to Supercollider

beep_amps = linspace(0, 1, 11); % Try out beeps at different volumes
% Amplitude of the beep relative to the noise (0 - 1)

for beep_amp = beep_amps
    beep_freq = 1000.0; % Frequency of the beep in Hz
    oscpath = '/stimulus'; % Which OSC responder to send a message to
    arg_types = 'ff'; % Type of each argument. These are all floats
    oscsend(u, oscpath, arg_types, beep_amp, beep_freq);
    pause(1)
end
    
%% Close the connection
% Run this to clean up when you're finished
fclose(u);