(
SynthDef(\guitar, {
	arg out = 0;
	var sig, env, delay;
	sig = SoundIn.ar(1);
	delay = AllpassC.ar(sig,0.1,0.1,1);
	delay = AllpassC.ar(delay,0.2,0.2,1);
	delay = AllpassC.ar(delay,0.02,0.02,1);
	Out.ar(out, [delay,delay]);
}).add;
// a.free();
a = Synth(\guitar);
)