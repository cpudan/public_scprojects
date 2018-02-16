(
SynthDef(\filter, { arg in, out, freq;
	var sig;
	sig = In.ar(in, 2);
	sig = LPF.ar(sig, In.kr(freq,1));
    Out.ar(out, sig);
}).add;

SynthDef(\noiseGen, {arg mul=0.1, out;
	Out.ar(out, WhiteNoise.ar(mul)!2);
}).add;

SynthDef(\monitor, {arg in, out;
	Out.ar(out, [SoundIn.ar(in), SoundIn.ar(in+1)]);
}).add;

SynthDef(\mouseX, {arg out, minval=0, maxval=1;
	Out.kr(out, MouseX.kr(minval,maxval));
}).add;
)

(
~sound = Group.new;
~effect = Group.after(~sound);
~control = Group.new;
)

(
b = Bus.audio(s,2);
d = Bus.control(s, 1);
Synth(\monitor, [in: 0, out: b],~sound);
Synth(\mouseX, [out: d, minval: 100, maxval: 500], ~control);
Synth(-\filter, [in: b, out: 0, freq: d], ~effect);
)
d.scope
