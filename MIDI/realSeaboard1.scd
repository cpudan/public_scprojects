// Use this as a tool to listen for all incoming midi messages
MIDIIn.connectAll;


(
SynthDef(\simpler, {
	arg note, detune=0, atk, gate, release=0, lfofreq=1, out=0;
	var sig, env, freq;
	freq = note.midicps + detune;
	sig = SinOsc.ar(freq,mul: Saw.kr(lfofreq));
	env = EnvGen.ar(Env.adsr(atk,0.3,0.5,release), gate);
	sig = sig*env;
	sig = LPF.ar(sig, 1100);
	Out.ar(out, sig);
}).add;
)


(
MIDIdef.freeAll;
~chanMap = Dictionary.new();

MIDIdef(\noteOn, {// strike
	arg vel, note, channel;
	var out, synth;
	synth = ~chanMap[channel];
	if (synth != Nil, {	/*synth.free;*/ ~chanMap.removeAt(channel);});
    out = if(((note.mod(24)) < 12) == true, {0}, {1});
	~chanMap.put(channel, Synth(\simpler, [note: note, atk: vel.linlin(0,127,2,0), gate:1, out: out, detune: 0, lfofreq: 1]));
}, msgType: \noteOn);

MIDIdef(\noteOff, {// lift
	arg vel, note, channel;
	var synth = ~chanMap[channel];
	if(synth != Nil, {
		synth.set(\release, vel.linlin(0,127, 2, 0));
		synth.set(\gate, 0);
	});
}, msgType: \noteOff);

MIDIdef(\touch, {// press
	arg pressure, channel;
	var synth = ~chanMap[channel];
	if(synth != Nil, {
		synth.get(\note, {arg note;
			synth.set(\lfofreq, pressure.linexp(0,127,4,note));
		});
	});
}, msgType: \touch);

MIDIdef(\bend, {// Glide
	arg bend, channel;
	var synth = ~chanMap[channel];
	if(synth != Nil, {synth.set(\detune, bend/10)});
}, msgType: \bend);

MIDIdef(\control, {// Slide
	arg value, cc, channel;
	var synth = ~chanMap[channel];
	if(synth != Nil, {
		synth.get(\note, {arg note;
			synth.set(\lfofreq, value.linexp(0,127,4,note));
		});
	});
}, msgType: \control);
)
