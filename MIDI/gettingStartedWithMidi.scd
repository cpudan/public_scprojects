// Use this as a tool to listen for all incoming midi messages
MIDIIn.connectAll;

(// Globals
~addFuncs = {arg type;
	MIDIIn.addFuncTo(type, {arg ...args; ([type]++args).postln;});
};
~midiTypes = [\noteOn, \noteOff, \polytouch, \control, \program,
	          \touch, \bend, \sysex, \sysrt, \smpte, \invalid];
)

// 5D = noteOn, noteOff, touch, control (8), bend

(// Define a dictionary of midi functions as follows
~midiFuncs = Dictionary.new;
~midiTypes.do({arg type;
	~addFuncs.value(type);
	/*if(type == \touch, {
		~addFuncs.value(type);
	});*/
});
)


(// Remove all midi functions
~midiFuncs.keys.collect({arg type;
	MIDIIn.removeFunc(~midiFuncs.at(type));
});
)


// Test with fake midi actions
MIDIIn.doNoteOnAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note off
MIDIIn.doBendAction(1, 1, 64, 64); // spoof a bend
