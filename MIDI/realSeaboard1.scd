// Use this as a tool to listen for all incoming midi messages
MIDIIn.connectAll;



(
SynthDef(\simpler, {
	arg note, detune=1, atk, gate, release=0, lfofreq=1;
	var sig, env;
	sig = SinOsc.ar(note.midicps,mul:1);
	sig = sig + Saw.ar(lfofreq,0);
	sig = PitchShift.ar(sig,0.2,detune);
	env = EnvGen.kr(Env.asr(atk,0.1,release),gate);
	sig = sig * env;
	Out.ar(0, sig!2);
}).add;
)

(

~keys = Array.newClear(127);
~chanMap = Dictionary.new(127);
MIDIdef(\noteOn, {// strike
	arg vel, note, channel;
	if (~keys[note] != Nil, {~keys[note].free;});
	~keys[note] = Synth(\simpler, [note: note, velocity: vel.linlin(0,127,2,0), gate:1]);
	~chanMap.put(channel, note);
}, msgType: \noteOn);

MIDIdef(\noteOff, {// lift
	arg vel, note, channel;
	~keys[note].set(\release, vel.linlin(0,127, 2, 0));
	~keys[note].set(\gate, 0);
}, msgType: \noteOff);


MIDIdef(\touch, {// press
	arg pressure, channel;
	// var note = ~chanMap[channel];
	// ~keys[note].set(\lfofreq, pressure.linexp(0,127,10,100));
}, msgType: \touch);

MIDIdef(\bend, {// Glide
	arg bend, channel;
	var note;
	note = ~chanMap.atFail(channel, {Nil});
	bend = (bend-8192).linlin(-500,500, 0.5,1.5);
	if (note != Nil, {
		~keys[note].set(\detune, bend);
	});
	bend.postln;
}, msgType: \bend);
)
8192/2


(
MIDIdef.freeAll;
)