// Use this as a tool to listen for all incoming midi messages
MIDIIn.connectAll;

(// Globals
~typeValues = Dictionary.new;
~addFuncs = {arg type;
	MIDIdef.new(type,
		{arg ...args;
			([type]++args).postln;

		}, msgType: type
	);
};
~midiTypes = [\noteOn, \noteOff, \polytouch, \control, \program,
	          \touch, \bend, \sysex, \sysrt, \smpte, \invalid];
)

// 5D = noteOn, noteOff, touch, control (8), bend

( // Test incoming
~midiTypes.do({arg type;
	~addFuncs.value(type);
});
)

(
~osc1 = {
	arg type, freq, amp;
	var sig;
	if(type == 0, {FSinOsc.ar(freq, mul:amp)},
		{if(type == 1, {Saw.ar(freq, amp)},
			{Pulse.ar(freq,mul:amp)})});
};

SynthDef(\sea, {
	arg note, bend, velocity, type=0, gate, out=0;
	var sig, env, atk = 0.1, rel = 0.5;
	env = EnvGen.kr(Env.asr(atk,releaseTime:rel),gate,doneAction:0);
	sig = ~osc1.value(type,note.midicps,((velocity-128)/10).dbamp);
	// [\type, 0, \freq, note.midicps, \amp, (velocity-(127/2).dbamp)]
	Out.ar(out, sig!2*env);
}).add;
)

Synth(\sea, [note: 60, bend: 0, velocity: 40, type: 1, gate: 1])

(
~keys = Array.newClear(127);
MIDIdef(\noteOn, {
	arg vel, note, idk;
	if (~keys[note] != Nil, {~keys[note].free;});
	~keys[note] = Synth(\sea, [note: note, velocity: vel, type: idk.mod(3), gate: 1])
}, msgType: \noteOn);

MIDIdef(\noteOff, {
	arg vel, note;
	~keys[note].set(\gate, 0);
}, msgType: \noteOff);
)
(
MIDIdef.freeAll;
)


// Test with fake midi actions
MIDIIn.doNoteOnAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note off
MIDIIn.doBendAction(1, 1, 64, 64); // spoof a bend
