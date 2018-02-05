 (
var sec = 3;
~b = Buffer.alloc(s,44100*sec,1);
)
(
SynthDef.new(\bufwr, {
	arg in, bufnum, amp=0.5, rate=1;
	//in = SinOsc.ar(LFNoise1.kr(2, 300, 400), 0, 0.1);
	in = SoundIn.ar(1);
	BufWr.ar(in, bufnum,
		Phasor.ar(0,
			BufRateScale.kr(bufnum)*rate,
			0,
			BufFrames.kr(bufnum)
		)
	);
}).add;

SynthDef.new(\bufrd, {
	arg amp=1, out=0, buf, start, end, rate=1, freq=1;
	var sig, ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
	//ptr = LFDNoise1.ar(freq).range(start, end);
	//ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(1, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig!2);
}).add;
)
y.free;
y = Synth.new(\bufwr, [bufnum:~b.bufnum, rate: 1]);

x.free;
w.free;
q.free;

x = Synth.new(\bufrd, [buf: ~b.bufnum, start: ~b.numFrames, end: 0, out:0, rate: -0.5]);
w = Synth.new(\bufrd, [buf: ~b.bufnum, start: ~b.numFrames, end: 0, out:0, rate: -2]);
q = Synth.new(\bufrd, [buf: ~b.bufnum, start: ~b.numFrames, end: 0, out:0, rate: -1]);
)

(
z.free;
z = {[SoundIn.ar(0), SoundIn.ar(1)]}.play;
~b0 = z;
)
z.free
y.set(\ratio, -24)


y = Synth.new(\bufwr, [bufnum:~b0.bufnum, ratio: 0]);

(
y.free; x.free;
)



s.options.numOutputBusChannels = 8;