#!/usr/bin/env python3
"""Generate original, deterministic prototype engine/tire loops. No sampled assets."""
from pathlib import Path
import math
import random
import struct
import wave
ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
ROOT.mkdir(parents=True, exist_ok=True)
RATE = 22050
rng = random.Random(4182)
for name in ("engine", "tires"):
    samples = []
    noise = 0.0
    for i in range(RATE):
        t = i / RATE
        if name == "engine":
            value = sum(gain * math.sin(math.tau * 80 * harmonic * t) for harmonic, gain in [(1,.38),(2,.22),(3,.12),(5,.05)])
            value *= .85 + .15 * math.sin(math.tau * 40 * t)
        else:
            noise = .65 * noise + .35 * rng.uniform(-1,1)
            value = .32 * noise + .09 * math.sin(math.tau * 830 * t + .9 * math.sin(math.tau * 13 * t))
            value *= min(1, i / 440, (RATE - 1 - i) / 440)
        samples.append(struct.pack("<h", round(max(-1,min(1,value)) * 32767)))
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1,2,RATE,0,"NONE","not compressed"))
        out.writeframes(b"".join(samples))
