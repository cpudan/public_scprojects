(
SynthDef.new(\basic, {
	arg out=0, freq=440, db=7.33;
	var sig = FSinOsc.ar(freq, mul:db.dbamp);
	Out.ar(out, sig!2);
}).add;
)

// Try 7.3 db

b = Bus.audio(s,1)
x = Synth(\basic, [\out, 0, \freq, 120])
x = Mix([x, Synth(\basic, [\out, 0, \freq, 800])])


c = Synth(\compressor, [\in, b, \out, 0, \db, 1])

({
	var in, chain, buf;
	in = AudioIn.ar([0,1]);
	chain = FFT(LocalBuf(2048,2), in);
	chain = PV_ConformalMap(chain, MouseX.kr(0.01,2.0, 'exponential'), MouseY.kr(0.01,10.0,'exponential'));

	Out.ar([0,1], [IFFT(chain[0]), IFFT(chain[1])]);
}.play
)

(
{
var in, chain;
    in = WhiteNoise.ar(0.1.dup);
    chain = FFT({LocalBuf(2048, 1)}.dup, in);
    //chain = PV_BrickWall(chain, SinOsc.kr([0.1, 0.11]));
    IFFT(chain) // inverse FFT
}.play;
)

// spawn some FFT based synths:
(
SynthDef(\fftgrain, { |out, sustain = 1, rate = 0.2|
    var in, chain;
    in = WhiteNoise.ar(0.1).dup;
    chain = FFT({LocalBuf(128, 1)}.dup, in);
    chain = PV_BrickWall(chain,
        SinOsc.kr(rate * XLine.kr(1, 15 * [1, 1.6], sustain), Rand(0, pi))
    );
    Out.ar(out, IFFT(chain) * XLine.kr(1, 0.001, sustain, doneAction: 2)) // inverse FFT
}).add;
)

Synth(\fftgrain)

// simple frequency-domain manipulation, square-rooting the magnitudes AND phases.
(
x = {
    var sig, chain, magsphases, b, mph, mags, phases;
    b = LocalBuf(1, 2048);
	sig = AudioIn.ar([0,1]);
    chain = FFT(b, sig);
    magsphases = UnpackFFT(chain, b.numFrames);
	mph = magsphases.clump(2);
	mags = mph[0];
	phases = mph[1];
	phases.postln;

    chain = PackFFT(chain, b.numFrames, magsphases,0,b.numFrames/2);
    Out.ar([0,1], [IFFT(chain[0]), IFFT(chain[1])]);
}.play
)
x.free

(
x = {
    var mags, phases, chain, sig, ogchain, emags, ephases, temp;
    // Create simple undulating magnitudes
	mags = { 0 }.dup(2048);
	// mags = {Pulse.kr(40,mul:10) }.dup(2048);
	// mags = { AudioIn.ar([0,1]) }.dup(100);

    // Then give them a "rolloff" to make the sound less unpleasant
	// mags = mags  * ((1, 0.99 .. 0.01).squared);

    // Let's ignore phase for now
	phases = { 0 }.dup(2048);

    // We need to create an FFT chain to feed our data in to.
	// Let's do an FFT on some signal which we then fuck with!
	chain = FFT(LocalBuf(2048), AudioIn.ar(1));
	temp = UnpackFFT(chain, 2048).clump(2);
	emags = temp[0];
	ephases = temp[1];

	// emags = emags.collect(_ * {Rand(0,1.9)}.value);
	chain = PackFFT(chain, 2048, [emags, ephases].flop.flatten, 0, 200);

	// Now we can do the packing
	// ogchain = PV_copy(chain, FFT(LocalBuf(2048),AudioIn.ar(1)));
	// chain = PackFFT(chain, 2048, [mags, phases].flop.flatten, 150, 200, 0);
	// chain = PackFFT(chain, 2048, [mags, phases].flop.flatten, 10, 20, 0);
	sig = IFFT(chain);

    sig.dup
}.play
)
x.free;

[1,2,3,4,5,6].clump(2).postln;



{SinOsc.ar(440,mul:0.2)}.play


