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
	sig = [BufRd.ar(0, buf, ptr), BufRd.ar(1, buf, ptr)];
	sig = sig * amp;
	//sig = LPF.ar(sig,1024);
	Out.ar(out, sig);
}).add;
)

(
~getBufMatrixRates = {arg inmatrix;
	var n = inmatrix.size;
	var m = inmatrix[0].size;
	var bufmatrix = inmatrix.collect({arg row;
		row = row.collect({arg r;
			var b = Buffer.alloc(s,44100*0.01);
			Synth.new(\bufwr, [bufnum: b, rate: r]);
			r = b;
		});
	});
	bufmatrix;
};

~getBufMatrixSecs = {arg inmatrix;
	var bufmatrix = inmatrix.collect({arg row;
		row = row.collect({arg sec;
			sec = Buffer.alloc(s,44100*sec*5,1);
		});
	});

	bufmatrix.collect({arg row;
		row.collect({arg b;
			Synth.new(\bufwr, [bufnum: b, rate: 1]);
		});
});

	bufmatrix;
};
)

(
 var brian = [ [1, 2, -1] ];
var bufmatrix = ~getBufMatrixRates.value(brian);
~synthmatrix = bufmatrix.collect({arg row;
	row = row.collect({arg b;
		Synth.new(\bufrd, [buf: b, start: 0, end: b.numFrames, out:0, rate: 1]);
	});
});
)

(
var bufmatrix = ~getBufMatrixSecs.value([
	[0.991044,   0.533355,  0.687772,  0.726641],
	[0.0367545,  0.402303,  0.889541,  0.00718102],
	[0.206444,   0.20997,   0.864955,  0.861565],
	[0.835312,   0.213683,  0.808653, 0.865407]]);
~synthmatrix = bufmatrix.collect({arg row;
	row = row.collect({arg b;
		Synth(\bufrd, [buf: b, end: 0, start: b.numFrames, out:0, rate: -1]);
	});
});
)

(
~synthmatrix.collect({arg row;
	row.collect({arg s;
		s.delete();
	})
});
)

(
var bufmatrix = ~getBufMatrix.value();

var sample = Synth.new(\bufwr, [buf: b, rate: 1]);

x = bufmatrix.copy.collect({arg b;
	Synth.new(\bufrd, [buf: b, start: b.numFrames, end: 0, out:0, rate: -0.5]);
});
)

w = bufmatrix.copy.collect({arg b;
	Synth.new(\bufrd, [buf: b, start: b.numFrames, end: 0, out:0, rate: -2]);
});
q = bufmatrix.copy.collect({arg b;
	Synth.new(\bufrd, [buf: b, start: b.numFrames, end: 0, out:0, rate: -1]);
});
)
(
z = {[SoundIn.ar(0), SoundIn.ar(1)]}.play;
~b0 = z;
)
z.free
y.set(\ratio, -24)


y = Synth.new(\bufwr, [buf:~b0, ratio: 1]);

(
y.free; x.free;
)



s.options.numOutputBusChannels = 8;