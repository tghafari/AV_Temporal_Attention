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
import eye_wrapper # Wrapper around pylink to interface with eye tracker

if IN_MEG_LAB:
    from psychopy import parallel
else:
    import dummy_parallel as parallel
    
############
# Functions to run on the experiment # Move to bottom
############

def send_trigger(trig):
    """ Send triggers to the MEG acquisition computer and the EyeLink computer.
    """
    port.setPin(trig, 1)
    el.trigger(trig)

fl.init(use_propixx=IN_MEG_LAB) #FIXME  move to the bottom
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

# LOG_DIR = '../logfiles/' # FIXME
# STIM_DIR = '../stimuli/' # FIXME
# assert os.path.exists(LOG_DIR)
# assert os.path.exists(STIM_DIR)

# Load instructions
# with open('lib/instruct.txt') as f:
#     instruct_text = f.readlines()
    
# Parallel port triggers - Send triggers on individual channels

port = parallel.ParallelPort(address=0xBFF8)
port.setData(0) # Reset the parallel port

TRIGGERS = {'trial begin': 1,
            'visual_stim': 2,
            'auditory_stim': 4,
            'response': 8,
            'drift_correct_start': 16,
            'drift_correct_end': 32}

# Screen settings #
# Shift visual stimuli up for good data quality at occipital sensors
frame_center = (fl.FRAME_CENTER[0], fl.FRAME_CENTER[1] + 80) 
COLORS = {'cs': 'rgb', # ColorSpace
          'white': [1., 1., 1.],
          'grey': [0., 0., 0.],
          'black': [-1., -1., -1.]}


# Visual stimuli settings #
# At what frequency do you wan to flicker the visual stimuli
flicker_freq = 63.
#stim_loc =  # Add if needed
stim_size_deg = 3 # Size of faces (visual distractor) in degrees of visual angle
stim_size = int(dc.deg2pix(stim_size_deg)) # Size of faces in pixels
visual_stim_dur = 50 # Duration of visual presentation in ms
vis_stim_dur_frames = s2f(m2s(visual_stim_dur))


# Auditory settings #
aud_stim_dur = 0.033 # Duration of auditory stimulus # FIXME
iti = random.uniform(1.5,2.0) # Blank screen between trials

# General task settings
n_stimuli = 12 # Number of stimuli in each trial
n_trials = 21 # Number of trials in total
trial_length = 12.0 + 2 * m2s(visual_stim_dur)
n_frames_per_trial = s2f((trial_length)) # Number of frames per trial
n_targets_per_trial = 2

first_foreperiod = 1000 # Duration of first foreperiod, always fixed (=1000ms)
foreperiod_reference = np.matlib.repmat(np.arange(500,1600,100),1,
                                        int((n_stimuli-1)/11)).transpose()


KEYS = {'break': 'escape',
        'drift': 'return',
        'accept': 'space',
        'response': '7'}

# Initialize and calibrate eye-tracker #
if IN_MEG_LAB:
    fl.close() # Make sure projector is in normal mode before starting
    el = eye_wrapper.SimpleEyelink(fl.FULL_RES)
    el.startup()

# Initialize the Propixx projector
# fl.init(use_propixx=IN_MEG_LAB)

# Initialize paddle buttonbox
paddle.init_labjack(dummy_run=(not IN_MEG_LAB))
buttonbox = paddle.Paddle(register=paddle.LEFT_BUTTON,
                          direction=paddle.DOWN,
                          clock=RT_CLOCK)

# Keep track of responses within each trial
RESP_COUNTER = {'hit':0, 'miss':0, 'fa':0}

######################
# Window and Stimuli #
######################

win = visual.Window(fl.FULL_RES, 
                    monitor='testMonitor',
                    fullscr=IN_MEG_LAB,
                    color=COLORS['grey'], colorSpace=COLORS['cs'],
                    allowGUI=False, units='pix')

# Common parameters used across stimuli
stim_params = {'win': win, 'units': 'pix'}

text_stim = fl.QuadStim(visual.TextStim, pos=frame_center, # For instructions
                           color=COLORS['white'], colorSpace=COLORS['cs'],
                           height=30, **stim_params)

fixation = fl.QuadStim(visual.Circle, radius=3,
                       fillColor=COLORS['white'],
                       lineColor=COLORS['white'],
                       fillColorSpace=COLORS['cs'], 
                       lineColorSpace=COLORS['cs'],
                       pos=frame_center, **stim_params)

# Patch for measuring temporal characteristics with photo diode
photodiode_size = 40
photodiode_pos = (frame_center[0] - frame_center[0] - photodiode_size/2,
                  frame_center[1] - frame_center[1] + photodiode_size/2)
photodiode_patch = fl.BrightnessFlickerStim(visual.ImageStim,
                                  image=np.array([[1.,1.],[1.,1.]]),
                                  colorSpace=COLORS['cs'],
                                  pos=photodiode_pos,
                                  size=(photodiode_size, photodiode_size),
                                  **stim_params)
photodiode_patch.flicker(flicker_freq)

flicker_patch = fl.BrightnessFlickerStim(visual.ImageStim,
                                  image=np.array([[1.,1.],[1.,1.]]),
                                  colorSpace=COLORS['cs'],
                                  pos=frame_center,
                                  size=(stim_size, stim_size),
                                  **stim_params)
flicker_patch.flicker(flicker_freq)

# Build the list of test stimuli
file_names = ['/Users/Tara/Documents/MATLAB/MATLAB-Programs/CHBH-Programs/AVTemporal-Attention/Stimuli/Stimuli/FaceRemovedBackgrounds/{}.tif'.format(n) 
              for n in range(1,(n_stimuli*n_trials)+1)]
pic_stims = []
for fname in file_names: 
    s = fl.QuadStim(visual.ImageStim,
                    image=fname,
                    colorSpace=COLORS['cs'],
                    pos=frame_center,
                    size=(stim_size, stim_size),
                    **stim_params)
    pic_stims.append(s)

random.shuffle(pic_stims)

#############################
# Build the trial structure #
#############################
    
"""1 block includes 12 aud & 12 vis stimuli and 2 targets
"""

trials_info = [] # One for each block
for n in range(n_trials):
    d={}
    if n <= int(2*n_trials/3):
        vis_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
                                0,first_foreperiod)))
        vis_trial_type = 'visual irregular,'
        aud_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
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
    
    inter_frame_int = [] # Keep track of frame timing
    for n_frame in range(n_frames_per_trial):
        RT_CLOCK.reset()
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
        
        flicker_patch.draw()
        photodiode_patch.draw()
        
        # Show the stim if there's a stim to show
        if current_vis_stim is not None:
            current_vis_stim.draw()    
            
        fixation.draw()   
        
        inter_frame_int.append(RT_CLOCK.getTime())
        
        win.flip()
        
    show_text('press any key to continue')
    event.waitKeys(keyList=['return'], maxWait=9999)
    
# Show a blank screen
win.flip(clearBuffer=True)
core.wait(0.5)
win.close()
fl.close()
paddle.close_labjack()
if IN_MEG_LAB:
    el.shutdown()
core.quit()










