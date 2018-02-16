// Use this as a tool to listen for all incoming midi messages
MIDIIn.connectAll;



(
SynthDef(\simpler, {
	arg note, detune=0, atk, gate, release=0, lfofreq=1, out=0;
	var sig, env, freq;
	freq = note.midicps + ~bend;
	sig = SinOsc.ar(freq,mul: Saw.kr(lfofreq,2)	);
	// sig = sig + Saw.ar(lfofreq,1);
	// sig = PitchShift.kr(sig,0.2,In.kr(detune));
	env = EnvGen.kr(Env.asr(atk,0.3,release),gate);
	sig = LPF.ar(sig * env, 1100);
	// out = 0;
	Out.ar(out, sig);
}).add;

SynthDef(\hold, {
	arg val, out;
	Out.kr(out, EnvGen.kr(Env.new([val],[0])));
}).add;
)

(

~keys = Array.newClear(127);
~chanMap = Dictionary.new(127);
// ~bendBus = Dictionary.new(127);
// ~bendBus = Bus.control(s,1);
// ~bend = Synth(\hold, [val: 0, out: ~bendBus]);
~bend = 0;

MIDIdef(\noteOn, {// strike
	arg vel, note, channel, out, bendbus;
	if (~keys[note] != Nil, {~keys[note].free;});
    out = if(((note.mod(24)) < 12) == true, {0}, {1});
	~keys[note] = Synth(\simpler,
		[note: note, atk: vel.linlin(0,127,0.5,0), gate:1, out: out, detune: ~bend]);
	~chanMap.put(channel, note);
}, msgType: \noteOn);

MIDIdef(\noteOff, {// lift
	arg vel, note, channel;
	~keys[note].set(\release, vel.linlin(0,127, 2, 0));
	~keys[note].set(\gate, 0);
}, msgType: \noteOff);

MIDIdef(\touch, {// press
	arg pressure, channel;
	var note = ~chanMap[channel];
	~keys[note].set(\lfofreq, pressure.linexp(0,127,4,note));
}, msgType: \touch);

MIDIdef(\bend, {// Glide
	arg bend, channel;
	var note, bus;
	~bend = bend - 8192;
	// ~bend.set(\val, bend/8192);
}, msgType: \bend);
)
8192/2

Synth(\hold, [val: 2, out: ])

(
MIDIdef.freeAll;
)