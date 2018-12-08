/* License: Public Domain (www.unlicense.org)
  
   This is free and unencumbered software released into the public domain.
   Anyone is free to copy, modify, publish, use, compile, sell, or distribute this 
   software, either in source code form or as a compiled binary, for any purpose, 
   commercial or non-commercial, and by any means.
   In jurisdictions that recognize copyright laws, the author or authors of this 
   software dedicate any and all copyright interest in the software to the public 
   domain. We make this dedication for the benefit of the public at large and to 
   the detriment of our heirs and successors. We intend this dedication to be an 
   overt act of relinquishment in perpetuity of all present and future rights to 
   this software under copyright law.
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
   AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

s.quit;
s.boot;

(
SynthDef(\pluck, {
	arg freq = 440, amp = 0.1, gate = 1,
	atk = 0.001, dec = 1, sus = 1, rel = 0.05,
	filtRel = 0.1, filtScale = 8200, filtBias = 400,
	detuneRatio = 0.005, pan = 0, out = 0;

	var sig, env, detunes, ratios, phases, freqs, sigM, sigS;

	ratios = (([-37, 0, 31]/1000)*12).midiratio.sqrt;
	detunes = 1 + (detuneRatio * (ratios - 1));
	phases = [Rand(0, 1), 0, Rand(0, 1)];
	freqs = detunes * freq;

	env = EnvGen.ar(Env.adsr(atk, dec, sus, rel), gate, doneAction: 2);
	sig = Splay.ar(SawDPW.ar(freqs, phases), 1, 1, pan);
	sig = DFM1.ar(sig.clip2(1.0), EnvGen.ar(Env.perc(0.001, filtRel), 1, filtScale, filtBias), 0.0, 1).clip2(1.0) * amp;
	sig = HPF.ar(sig, 40).clip2(1.0);
	sig = LPF.ar(sig, 16000).clip2(1.0);
	sig = sig * env;

	sigM = sig[0] + sig[1];
	sigS = sig[0] - sig[1];
	sigS = HPF.ar(sigS, 300).clip2(1.0);

	sig = [(sigM + sigS), (sigM - sigS)]*0.5;

	Out.ar(out, sig);
}).add;
)

// DEMO
(
Pn(Pbind(
	\instrument, \pluck,
	\amp, 0.1875,
	\pan, [0, 0, 0, 0],
	\scale, Scale.chromatic,
	\detuneRatio, 0.15,
	\root, -4,
	\dur, 0.5,
	\legato, Pseq([
		0.95,
	], inf),
	\filtRel, Env([0.1, 0.1, 2, 0.1], [48, 24, 24]),
	\filtScale, Env([800, 8200, 8200, 800], [48, 46, 2]),
	\degree, Pseq([
		Pseq([
			Pseq([
				[-12, 3, 14],
				[-12, 3, 14],
				[-12, 3, 14],
				[-12, 3, 10],
				[-12, 3, 10],
				[-12, 3, 10],
				[-12, 3,  7],
				[-12, 3,  7],
			]),
			Pn([-12, 4, 11]-4, 8*2),
		], 4*2),
	]),
), inf).play(TempoClock(128/60));
)
