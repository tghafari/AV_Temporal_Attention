// Run this section to get Supercollider ready to play sounds
(
// Boot the server
s = Server.local;
s.boot;

// Make your synth definitions and OSC responders after the Supercollider server boots
s.waitForBoot{

	var rampDur = 0.005; // How long the noise takes to ramp up/down
	var soundDur = 0.05; // Total length of the sound
	var noiseAmp = 0.5; // Ampl of the white noise. Make sure it's < 0.5 to avoid clipping!

	// SynthDef: A burst of white noise
	SynthDef(\noiseburst, {
		var env, sig;

		// Make the envelope
		env = EnvGen.kr(Env.linen(
			attackTime: rampDur,
			sustainTime: soundDur - (2 * rampDur),
			releaseTime: rampDur,
			curve: \sine // Ramp the volume up/down as a sinusoid
		),
		doneAction: 2);
		// Make the sound
		sig = WhiteNoise.ar(mul: noiseAmp);
		sig = sig * env;
		Out.ar([0, 1], sig);
	}).add;


	// SynthDef: A beep
	SynthDef(\beep, {arg amp=1.0, freq=1000;
		// amp: Amplitude relative to the white noise
		var env, sig;

		// Make the envelope
		env = EnvGen.kr(Env.linen(
			attackTime: rampDur,
			sustainTime: soundDur - (2 * rampDur),
			releaseTime: rampDur,
			curve: \sine // Ramp the volume up/down as a sinusoid
		),
		doneAction: 2);

		// Make the sound
		sig = SinOsc.ar(freq: freq, mul: amp * noiseAmp);
		sig = sig * env;
		Out.ar([0, 1], sig);
	}).add;


	// Set up a responder that listens for incoming OSC messages
	OSCdef.new(
		\stim_responder,
		{|msg, time, addr, port|
			var params = [
				\amp, msg[1].clip(0, 1), // Limit amp from 0-1
				\freq, msg[2].clip(0, 10000) // Limit freq from 0-10 kHz
			];
			Synth(\noiseburst);
			Synth(\beep, params);
			params.postln;
		},
		'/stimulus',
		recvPort:57120
	);
}
)

/*
// Make a recording to test it out
s.prepareForRecord('/PATH/TO/SAVE/THE/FILE.aifc');
s.record;
s.stopRecording;
*/
