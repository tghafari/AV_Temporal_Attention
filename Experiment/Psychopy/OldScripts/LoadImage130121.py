#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Audio-Visual temporal attention task
- Project name: 
- Project code: 
- Grant code: 
Winter 2020
t.ghafari@bham.ac.uk

Distances
Eyes to screen: 147.5 cm
Screen width: 70.3 cm (25.5 deg)
Screen height: 39.5 cm (14.3 deg)

@author: Tara
"""


# Change to False for testing on office desktop
IN_MEG_LAB = False

import os
import numpy as np
import numpy.matlib
import random
import datetime
from psychopy import visual, core, data, event, monitors

# Custom modules
import refcheck
import dist_convert as dc
import flicker as fl # Flickering stims on the Propixx projector
import paddle # MEG-compatible LED response box over LabJack

fl.init(use_propixx=False)

if IN_MEG_LAB:
    from psychopy import parallel
else:
    import dummy_parallel as parallel


def s2f(x):
    """ Convert seconds to frame flips. """
    return np.multiply(x,fl.OUTPUT_FRAME_RATE).astype(int)


def m2s(x):
    """ Convert milliseconds to seconds. """
    return np.multiply(x,0.001)


def show_text(text):
    """ Show text at the center of the screen
    """
    text_stim.text = text
    text_stim.draw()
    win.flip()
    core.wait(1)
    
############
# Settings #
############

# Clocks
START_TIME = datetime.datetime.now().strftime('%Y-%m-%d-%H%M')
RT_CLOCK = core.Clock() # response times

port = parallel.ParallelPort(address=0xBFF8)
port.setData(0) # Reset the parallel port

# LOG_DIR = '../logfiles/' # FIXME
# STIM_DIR = '../stimuli/' # FIXME
# assert os.path.exists(LOG_DIR)
# assert os.path.exists(STIM_DIR)

# Load instructions
# with open('lib/instruct.txt') as f:
#     instruct_text = f.readlines()
    
# Parallel port triggers - Send triggers on individual channels
# triggers = {'trial begin': 3,
#             'target': 4,
#             'response': 5}

# At what frequency do you wan to flicker the [visual auditory] stimuli
# flicker_freqs = [63., 78.] 

# Stimuli settings
stim_size_deg = 3 # Size of faces (visual distractor) in degrees of visual angle
stim_size = int(dc.deg2pix(stim_size_deg)) # Size of faces in pixels
n_stimuli = 12
n_trials = 21
visual_stim_dur = 50 #duration of visual presentation
vis_stim_dur_frames = s2f(m2s(visual_stim_dur))
trial_length = 12.0 + 2*m2s(visual_stim_dur)
n_frames_per_trial = s2f((trial_length))
first_foreperiod = 1000 #duration of first foreperiod, always fixed
foreperiod_ref = np.matlib.repmat(np.arange(500,1600,100),1,
                                 int((n_stimuli-1)/11)).transpose()


#Fixed variables
SCREEN_RES = [800,800]
FULL_SCREEN = False

# Location settings
# Shift visual stimuli up for good data quality at occipital sensors
frame_center = (fl.FRAME_CENTER[0], fl.FRAME_CENTER[1] + 80) 
#stim_loc =  # Add if needed

# Initialize paddle buttonbox
# paddle.init_labjack(dummy_run=(True))
# buttonbox = paddle.Paddle(register=paddle.LEFT_BUTTON,
#                           direction=paddle.DOWN,
#                           clock=RT_CLOCK)

refresh_rate = 60
ifi = fl.OUTPUT_FRAME_RATE/1000



COLORS = {'cs': 'rgb255', # ColorSpace
          'white': [255, 255, 255],
          'grey': [128, 128, 128],
          'black': [0, 0, 0],
          'pink': [225, 10, 130],
          'blue': [35, 170, 230]}

win_center = (0, 0)

win = visual.Window(SCREEN_RES,
                    monitor='testMonitor',
                    fullscr=FULL_SCREEN,
                    color=COLORS['grey'], colorSpace=COLORS['cs'],
                    allowGUI=False)

stim_params = {'win': win, 'units': 'pix'}

text_stim = visual.TextStim(pos=win_center, text='hello', # For instructions
                            color=COLORS['white'], colorSpace=COLORS['cs'],
                            height=32,
                            **stim_params)


refcheck.check_refresh_rate(win, fl.OUTPUT_FRAME_RATE, 0.001)

CS = 'rgb'  # ColorSpace

    
"""
1 block includes 12 aud & 12 vis stimuli and 2 targets
"""
# first visual and auditory stimulus should appear after 1sec

trials_info = [] # One for each block
n_targets_per_trial = 2

pic_stims = []
file_names = ['/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/AVTemporal-Attention/Stimuli/Stimuli/FaceRemovedBackgrounds/{}.tif'.format(n) 
              for n in range(1,(n_stimuli*n_trials)+1)]

for fname in file_names:
    s = visual.ImageStim(
                    image=fname,
                    size=stim_size,
                    **stim_params)
    pic_stims.append(s)

random.shuffle(pic_stims)

for n in range(n_trials):
    d={}
    if n <= int(2*n_trials/3):
        vis_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_ref),
                                0,first_foreperiod)))
        vis_trial_type = 'visual irregular,'
        aud_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_ref),
                                0,first_foreperiod)))
        aud_trial_type = ' auditory irregular'
    else:
        vis_time_elapsed = m2s(np.cumsum(n_stimuli*[first_foreperiod]))
        vis_trial_type = 'visual regular,'
        aud_time_elapsed = m2s(np.cumsum(n_stimuli*[first_foreperiod]))
        aud_trial_type = ' auditory regular'
      
    vis_frame_elapsed = s2f(vis_time_elapsed)
    aud_frame_elapsed = s2f(aud_time_elapsed)
    aud_target_idx = np.random.choice(n_stimuli, 
                                         np.random.choice(
                                         np.arange(1, n_targets_per_trial
                                         + 1)))
    
    d['vis_times'] = vis_time_elapsed
    d['vis_onset_frames'] = vis_frame_elapsed
    d['vis_trial_type'] = vis_trial_type
    d['aud_times'] = aud_time_elapsed
    d['aud_onset_frames'] = aud_frame_elapsed
    d['aud_targs'] = aud_target_idx
    d['trial_type'] = vis_trial_type + aud_trial_type
    d['aud_trial_type'] = aud_trial_type
    d['vis_stim_img'] = pic_stims[(n * n_stimuli) : (n+1) * n_stimuli]
    
    trials_info.append(d)
     

trials = data.TrialHandler(trials_info, nReps=1, method='random')


for trial in trials:
    
    vis_onsets = trial['vis_onset_frames']
    vis_offsets = vis_onsets + vis_stim_dur_frames
    vis_stimuli = trial['vis_stim_img']
    current_vis_stim = None # Keep track of the current visual stimulus object
    
    aud_onsets = trial['aud_onset_frames']
    show_text(trial['trial_type'])

    for n_frame in range(n_frames_per_trial):
        # Check if we're at the first frame of the visual stim
        if n_frame in vis_onsets:
            current_vis_stim = vis_stimuli.pop(0)
        # Check if we're at the last frame of the visual stim
        elif (current_vis_stim is not None) and (n_frame in vis_offsets):
            current_vis_stim = None       
        # Check if we should present an auditory stim
        if n_frame in aud_onsets:
            if np.where(aud_onsets==n_frame)[0] in trial['aud_targs']:
                print('beep + target') #FIXME
            else:
                print('beep')
        # Show the stim if there's a stim to show
        if current_vis_stim is not None:
            current_vis_stim.draw()
        win.flip()
        
    show_text('press any key to continue')
    event.waitKeys(keyList=['return'], maxWait=9999)
    
# Show a blank screen
win.flip(clearBuffer=True)
core.wait(0.5)
win.close()












