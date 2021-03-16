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
IN_MEG_LAB = False # Are you in the MEG lab?

import os
import numpy as np
import numpy.matlib
# import matplotlib.pyplot as plt # only for histogram
import random
import datetime
from psychopy import visual, core, data, event, monitors

# Custom modules
import refcheck
import dist_convert as dc
import simple_osc
import flicker as fl # Flickering stims on the Propixx projector
import eye_wrapper # Wrapper around pylink to interface with eye tracker

if IN_MEG_LAB:
    from psychopy import parallel
else:
    import dummy_parallel as parallel
    

############
# General Settings #
############

# Clocks
START_TIME = datetime.datetime.now().strftime('%Y-%m-%d-%H%M')
rt_clock = core.Clock() # response times

# Basic screen settings 
FULL_SCREEN = False
if FULL_SCREEN:
    SCREEN_RES = [1920, 1080] # Full res on the Propixx projector
else:
    SCREEN_RES = [800, 800]
    
# Dictionary of keypresses
KEYS = {'break': 'escape',
        'drift': 'return',
        'accept': 'space',
        'response': '7'}

# Parallel port triggers - Send triggers on individual channels
TRIGGERS = {'trial begin': 1,
            'visual_stim': 2,
            'auditory_noise': 4,
            'auditory_target': 8,
            'response': 16,
            'drift_correct_start': 32,
            'drift_correct_end': 64}
    
# Super collider initialization
print('Open SuperCollider')
ip_address = '127.0.0.1'
osc_port = 57120
OSC_SENDER = simple_osc.OSCSender((ip_address, osc_port))
osc_address = '/stimulus'
    
# Shift visual stimuli up for good data quality at occipital sensors
frame_center = (fl.FRAME_CENTER[0], fl.FRAME_CENTER[1] + 80) 
win_centre = (0, 0) # Only used for not flicker purposes

# Initialize external equipment and run MEG lab related functions
if IN_MEG_LAB:
    refresh_rate = 120.0    
    port = parallel.ParallelPort(address=0xBFF8)
    port.setData(0) # Reset the parallel port
    fl.close() # Make sure projector is in normal mode before starting
    el = eye_wrapper.SimpleEyelink(SCREEN_RES)
    el.startup()
    
    def eye_pos():
        """ Get the eye position. """
        pos = el.el.getNewestSample()
        pos = pos.getRightEye()
        pos = pos.getGaze() # eye position in pix (origin: bottom right)
        return pos

    def send_trigger(trig):
        """ Send triggers to the MEG acquisition computer
        and the EyeLink computer.
        """
        t = TRIGGERS[trig]
        port.setData(t)
        el.trigger(t)

    def reset_port():
        """ Reset the parallel port to avoid overlapping triggers. """
        wait_time = 0.003
        core.wait(wait_time)
        port.setData(0)
        core.wait(wait_time)

else: # Dummy functions for dry-runs on my office desktop
    refresh_rate = 60.0
    el = eye_wrapper.DummyEyelink()

    def eye_pos():
        pos = frame_center
        pos = np.int64(dc.origin_psychopy2eyelink(pos))
        return pos

    def send_trigger(trig):
        print('Trigger: {}'.format(trig))

    def reset_port():
        pass

fl.init(use_propixx=IN_MEG_LAB) #Propixx projector

# Directories 
stim_path = '../Stimuli/'
result_path = '../Results/'
instruction_dir = os.path.join(stim_path,'Instructions')
stim_dir = os.path.join(stim_path,'Visual/FaceRemovedBackgrounds')
result_dir = os.path.join(result_path,'')
assert os.path.exists(instruction_dir)
assert os.path.exists(stim_dir)
assert os.path.exists(result_dir)


############
# Setting functions #
############

def s2f(x):
    """ Convert seconds to frame flips. """
    x = np.array(x)
    return (x * fl.OUTPUT_FRAME_RATE).astype(int)

def f2s(x):
    """ Convert frame flips to seconds. """
    x = np.array(x)
    return (x * fl.OUTPUT_FRAME_RATE).astype(int)

def m2s(x):
    """ Convert milliseconds to seconds. """
    x = np.array(x)
    return (x * 0.001)

def rand_noncontiguous(reference, n_choices):
    """ Randomizes (no repolacement) inputs 
    without two same contiguous elements. 
    """
    list_choices = [] 
    for i in range(n_choices):
        last = np.random.choice(reference)
        next = np.random.choice(reference)
        if next != last and next != last+1:
          last = next
          list_choices.append(last)
          return list_choices
      
############
# Task-specific Settings #
############

# Load instructions
with open('{}/instruction100221.txt'.format(instruction_dir)) as f:
    instruct_text = f.readlines()

# Visual stimuli settings 
stim_size_deg = 3 # Size of faces (visual distractor) in degrees of visual angle
stim_size = int(dc.deg2pix(stim_size_deg)) # Size of faces in pixels
visual_stim_dur = 50 # Duration of visual presentation in ms
vis_stim_dur_frames = s2f(m2s(visual_stim_dur))
flicker_freq = 63. # Flicker frequency of flicker patch
flicker_path_size = round(1.5*stim_size/2)
photodiode_size = 40

# Auditory settings  
individual_amper = 0.33 # each subject's amplitude - output of staircase
beep_freq = 1000 #Hz

# General task settings
n_stimuli = 12 # Number of stimuli in each trial
n_trials_main = 9 # Number of trials in the main task
n_trials_staircase = 2 # Number of trials in the thresholding phase
target_prob = .2 # Probability of target in each trial
n_targets_per_trial = int(target_prob * n_stimuli)
trial_length = 12.0 + 2 * m2s(visual_stim_dur)
n_frames_per_trial = s2f((trial_length)) # Number of frames per trial
rec_length = 15 * 60 # Length of each MEG recording (in seconds)

# Timings
first_foreperiod = 1000 # Duration of first foreperiod, always fixed (=1000ms)
foreperiod_reference = np.matlib.repmat(np.arange(500,1600,100),1,
                                        int((n_stimuli-1)/11)).transpose()
response_cutoff = 1.0 # Respond within this time
staircase_thresh = .9 # What percent of the correct responses should be accepted
fix_dur = 0.5 # Hold fixation for X seconds before starting trial
fix_thresh_deg = 1.0 # Subject must fixate w/in this distance to start trial
fix_thresh = int(dc.deg2pix(fix_thresh_deg))
END_EXPERIMENT = 9999 # Numeric tag signals stopping expt early

TRIAL_TYPES = ['aud_reg','vis_reg','both_irreg']
TRIAL_TYPES *= int(n_trials_main/3)
assert n_trials_main % 3 == 0

######################
# Window and Stimuli #
######################

COLORS = {'cs': 'rgb', # ColorSpace
          'white': [1., 1., 1.],
          'grey': [0., 0., 0.],
          'black': [-1., -1., -1.]}

win = visual.Window(fl.FULL_RES, 
                    monitor='testMonitor',
                    fullscr=IN_MEG_LAB,
                    color=COLORS['grey'], colorSpace=COLORS['cs'],
                    allowGUI=False, units='pix')

# Common parameters used across stimuli
stim_params = {'win': win, 'units': 'pix'}
circle_params = {'fillColor': COLORS['white'],
                 'lineColor': COLORS['white'],
                 'fillColorSpace': COLORS['cs'],
                 'lineColorSpace': COLORS['cs'],
                 **stim_params}

text_stim = fl.QuadStim(visual.TextStim, pos=frame_center, # For instructions
                        color=COLORS['white'], colorSpace=COLORS['cs'],
                        height=30, **stim_params)

fixation = fl.QuadStim(visual.Circle, radius=3,
                       pos=frame_center, 
                       **circle_params)

drift_fixation = fl.QuadStim(visual.Circle,radius=5, 
                             pos=frame_center, 
                             **circle_params)


# Patch for measuring temporal characteristics with photo diode
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
                                  size=(flicker_path_size, flicker_path_size),
                                  **stim_params)
flicker_patch.flicker(flicker_freq)

# Build the list of test stimuli
file_names = ['{}/{}.tif'.format(stim_dir,n) 
              for n in range(1,(n_stimuli*n_trials_main)+1)]
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

###########################################
# Build the trial structure and staircase #
###########################################
    
"""1 trial includes 112 aud & 112 vis stimuli and 22 targets"""

trials_info = [] # One for each trial
for n in range(n_trials_main + n_trials_staircase):
    d={}
    # Define the quest trials 
    if n < n_trials_staircase:
        quest_thresholding = True
    else:
        quest_thresholding = False

    # Create foreperiods due to the trial type
    d['cond'] = TRIAL_TYPES.pop()        
    if d['cond'] == 'vis_reg':
        vis_time_elapsed = m2s(np.cumsum(n_stimuli*[first_foreperiod]))
        vis_trial_type = 'visual regular,'
        aud_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
                                0,first_foreperiod)))
        aud_trial_type = ' auditory irregular'
    elif d['cond'] == 'aud_reg':
        vis_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
                                0,first_foreperiod)))
        vis_trial_type = 'visual irregular,'
        aud_time_elapsed = m2s(np.cumsum(n_stimuli*[first_foreperiod]))
        aud_trial_type = ' auditory regular'
    else:
        vis_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
                                0,first_foreperiod)))
        vis_trial_type = 'visual irregular,'
        aud_time_elapsed = m2s(np.cumsum(np.insert(
                                np.random.permutation(foreperiod_reference),
                                0,first_foreperiod)))
        aud_trial_type = ' auditory irregular'
                  
    vis_frame_elapsed = s2f(vis_time_elapsed)
    aud_frame_elapsed = s2f(aud_time_elapsed)
    aud_target_idx = rand_noncontiguous(n_stimuli,n_targets_per_trial)
   
    d['vis_times'] = vis_time_elapsed
    d['vis_onset_frames'] = vis_frame_elapsed
    d['vis_trial_type'] = vis_trial_type
    d['aud_times'] = aud_time_elapsed
    d['aud_onset_frames'] = aud_frame_elapsed
    d['aud_targs'] = aud_target_idx
    d['t_targets'] = f2s(aud_frame_elapsed[aud_target_idx[:]])
    d['trial_type'] = vis_trial_type + aud_trial_type
    d['aud_trial_type'] = aud_trial_type
    d['vis_stim_img'] = pic_stims[(n * n_stimuli) : (n+1) * n_stimuli]
    d['quest'] = quest_thresholding
   
    trials_info.append(d)
     

trials = data.TrialHandler(trials_info, nReps=1, method='random')

# QUEST Adaptive procedure for titrating target opacity
guess_prob = 0.05 # P(trials) on which subject just guesses blindly
staircase = data.QuestHandler(startVal=0.4, startValSd=0.35,
                            pThreshold=0.5,
                            method='mean', # quantile, mean, or mode
                            beta=3.5, # Steepness of psychometric func
                            delta=guess_prob, # P(trials) S presses blindly
                            gamma=guess_prob/2, # P(corr) when intensity=-inf
                            minVal=0, maxVal=1, range=1)

###############################################
# Main definitions for running the experiment #
###############################################

def euc_dist(a, b):
    """ Euclidean distance between two (x,y) pairs
    """
    d = sum([(x1 - x2)**2 for x1,x2 in zip(a, b)]) ** (1/2)
    return d

def show_text(text):
    """ Show text at the center of the screen. """
    text_stim.set('text', text)
    text_stim.draw()
    win.flip()
    core.wait(.8)
    
def instructions(text):
    """ Show instructions and go on after pressing space. """
    show_text(text)
    event.waitKeys(keyList=['space'])
    win.flip(clearBuffer=True) # clear the screen
    core.wait(0.2)
    
def drift_correct():
    """ Eye-tracker drift correction.
    Press SPACE on the Eyelink machine to accept the current position.
    """
    reset_port()
    core.wait(0.2)
    # Draw a fixation dot
    drift_fixation.draw()
    win.flip()
    send_trigger('drift_correct_start')
    reset_port()
    # Do the drift correction
    fix_pos = np.int64(dc.origin_psychopy2eyelink(frame_center))
    el.drift_correct(fix_pos)
    send_trigger('drift_correct_end')
    reset_port()

def check_accuracy(t_target, t_response, threshold): 
    """ Checks accuracy, most porbably only for feedback. """
    if t_target is []: # No target was shown
        hit = None
        miss = None
        false_alarm = len(t_response)
    else: # There was a target shown
        if len(t_response) < len(t_target):
            miss = len(t_target) - len(t_response)           
        if t_response is []:
            hit = False
            false_alarm = False
        else:
            for n_resp in range(len(t_response)):
                if  t_response[n_resp] >= t_target[n_resp] + threshold:
                    hit[n_resp] = False 
                    false_alarm[n_resp] = True
                elif t_response[n_resp] < t_target[n_resp] + threshold:
                    hit[n_resp] = True
                    false_alarm[n_resp] = False
                else:
                    raise Exception('Failed to classify hits and false alarms')
        
    return hit, miss, false_alarm
    
def experimenter_control():
    """ Check for experimenter key-presses to pause/exit the experiment or
    correct drift in the eye-tracker.
    """
    r = event.getKeys(KEYS.values())
    if KEYS['break'] in r:
        show_text('End experiment? (y/n)')
        core.wait(1.0)
        event.clearEvents()
        r = event.waitKeys(keyList=['y', 'n'])
        if 'y' in r:
            return END_EXPERIMENT
    elif KEYS['drift'] in r:
        drift_correct()
        
def set_target_volume(trial): #use both update stair case and calculate hit definitions
    """ Set the amplitude of the auditory targets for each subject."""
    
    if trial['quest']:
        individual_amper = staircase.next()
    else:
        individual_amper = staircase.mean()
    return individual_amper

def update_staircase(trial): 
    """ Update the QUEST staircase given a hit if pressed a key after 
    target."""
    
    if trial['quest']:
        event.clearEvents()
        r_quest = event.getKeys()
        if np.size(r_quest) == 0:
            staircase.addResponse(0) # Hit=1, Miss=0
        else:
            staircase.addResponse(1) 
            send_trigger('response')
            reset_port()
            
def play_auditory_stimuli(trial,frame_n):
    if np.where(trial['aud_onset_frames']==frame_n)[0] in trial['aud_targs']:
        beep_amp = set_target_volume(trial)        
        send_trigger('auditory_target')
        update_staircase(trial)                    
    else:
        beep_amp = 0
        send_trigger('auditory_stim')
                
    # Message to supercollider
    msg = [beep_amp, beep_freq]
    OSC_SENDER.send(osc_address, msg)

def run_trial(trial):
    reset_port()
    event.clearEvents()

    # Wait for fixation and check for experimenter input
    fixation.draw()
    win.flip()
    send_trigger('fixation')
    reset_port()
    t_fix = core.monotonicClock.getTime() # Start a timer
    core.wait(0.2)
    while True:
        print('stuck')
        # Check for experimenter control to end or correct drift
        if experimenter_control() == END_EXPERIMENT:
            return END_EXPERIMENT
        d = euc_dist(dc.origin_eyelink2psychopy(eye_pos()), frame_center)
        t_now = core.monotonicClock.getTime()
        # Reset timer if not looking at fixation
        if (d > fix_thresh):
            t_fix = t_now
        # If they are looking at the fixation, and have looked long enough
        elif (t_now - t_fix) > fix_dur:
            break
        # If they are looking, but haven't held fixation long enough
        else:
            fixation.draw()
            win.flip()

    # Present the trial
    show_stimuli(trial)

    return experimenter_control()

def show_stimuli(trial):
    """ Show 12 visual and 12 auditory stims + 2 targets """
        
    vis_onsets = trial['vis_onset_frames']
    vis_offsets = vis_onsets + vis_stim_dur_frames
    vis_stimuli = trial['vis_stim_img']
    current_vis_stim = None # Keep track of the current visual stimulus object
    
    aud_onsets = trial['aud_onset_frames']
    show_text(trial['trial_type'])
    
    inter_frame_int = [] # Keep track of frame timing
    event.clearEvents()
    keypress =[]
    rt = []
    r = None

    for n_frame in range(n_frames_per_trial):
        
        # Check if we're at the first frame of the visual stim
        if n_frame in vis_onsets:
            current_vis_stim = vis_stimuli.pop(0)
            send_trigger('visual_stim')
        # Check if we're at the last frame of the visual stim
        elif (current_vis_stim is not None) and (n_frame in vis_offsets):
            current_vis_stim = None       
        
        # Check if we should present an auditory stim
        if n_frame in aud_onsets:
           play_auditory_stimuli(trial,n_frame)          
           rt_clock.reset() # Reset the RT clock after each auditory stim
            
        # Show the frequency tagging and photodioe patch
        flicker_patch.draw()
        photodiode_patch.draw()     
        
        # Show the stim if there's a stim to show
        if current_vis_stim is not None:
            current_vis_stim.draw()  
            
        fixation.draw()           
        inter_frame_int.append(rt_clock.getTime())       
        win.flip()
        
        # Collect if there is a key press
        if not trial['quest']:
            event.clearEvents()
            r = event.getKeys(keyList=[KEYS['response']],
                              timeStamped=rt_clock)

            if np.size(r) != 0:                        
                send_trigger('response')
                reset_port()
                keypress.append(r[0][0])
                rt.append(r[0][1])
            
        
    hit, false_alarm , miss = check_accuracy(trial['t_targets'], rt, threshold=response_cutoff)
    
    # Save all the responses of one trial together
    trials.addData('resp', keypress)
    trials.addData('rt', rt)
    trials.addData('hit', hit) 
    trials.addData('miss', miss)
    trials.addData('false alarm', false_alarm)

    show_text('press return to continue')
    event.waitKeys(keyList=['return'], maxWait=9999)
            
def run_experiment():
    """ Coordinate the different parts of the experiment"""

    # A few tests before beginning the experiment
    refcheck.check_refresh_rate(win, refresh_rate)
    
    # Instructions 
    for line in instruct_text:
        instructions(line)
    
    # Run the trials
    rec_start_time = core.monotonicClock.getTime()
    rec_number = 1 # Which recording number is this? 
    
    for trial in trials:
        status = run_trial(trial)
        if status == END_EXPERIMENT:
            break
        
        # Prompt to start a new MEG recording every so often
        trials.addData('rec_number', rec_number)
        curr_time = core.monotonicClock.getTime()
        if curr_time > (rec_start_time + rec_length):
            show_text(f"--- Save MEG recording {rec_number} ---")
            event.waitKeys(keyList=['return'], maxWait=9999)
            rec_start_time = curr_time # Reset the clock
            show_text('Ready?')
            event.waitKeys(keyList=['return'], maxWait=9999)
            drift_correct()
            rec_number += 1
    # Save the data
    trials.saveAsWideText('{}/{}.csv'.format(result_dir, START_TIME),
                          delim=',',
                          fileCollisionMethod='rename')
    # Show the end screen
    win.flip(clearBuffer=True)
    show_text('That was it -- thanks :-)')
    event.waitKeys(keyList=['escape'], maxWait=30)
    win.close()
    fl.close()
    if IN_MEG_LAB:
        el.shutdown()
    core.quit()
            










