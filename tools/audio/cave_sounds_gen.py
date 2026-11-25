"""Процедурные звуки пещеры: фон (глухой сквозняк + редкие капли, петля), гул раскрутки глиняного шара,
удар упавшего камня, скрежет каменной плиты. Пишет wav + .yy в max_farm_demo/sounds и регистрирует в .yyp.
Запуск: python3 tools/audio/cave_sounds_gen.py
"""
import numpy as np, wave, os

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "max_farm_demo", "sounds")

def lowpass(x, a):            # однополюсный НЧ-фильтр (как в ambience_gen.py), через lfilter-подобный цикл numpy
    y = np.empty_like(x); acc = 0.0
    for i, v in enumerate(x):
        acc += (1 - a) * (v - acc); y[i] = acc
    return y

def loopify(x, fade_s=1.0):   # бесшовная петля
    n = int(fade_s * SR); t = np.linspace(0, 1, n)
    mixed = x[-n:] * np.cos(t * np.pi / 2) + x[:n] * np.sin(t * np.pi / 2)
    return np.concatenate([mixed, x[n:-n]])

def save(name, x, peak):
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    d = os.path.join(OUT, name); os.makedirs(d, exist_ok=True)
    with wave.open(os.path.join(d, name + ".wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(name, round(len(x) / SR, 2), "s")

rng = np.random.default_rng(36)

def cave_ambience(sec=16):
    n = (sec + 1) * SR
    white = rng.standard_normal(n)
    draft = lowpass(lowpass(white, 0.993), 0.993)                     # глухой низкий сквозняк
    swell = 0.55 + 0.45 * np.sin(np.linspace(0, 2 * np.pi * 2, n) + 0.7) ** 2
    x = draft * 14 * swell
    t = np.arange(int(0.25 * SR)) / SR
    for _ in range(sec * 2):                                          # капли: короткий «плинк» с эхом
        p = rng.integers(0, n - len(t) * 3)
        f = rng.uniform(900, 1700)
        drop = np.sin(2 * np.pi * (f + 600 * np.exp(-t * 40)) * t) * np.exp(-t * 22) * rng.uniform(0.25, 0.6)
        for k, g in enumerate([1.0, 0.35, 0.15]):                     # эхо пещеры
            s = p + int(k * 0.11 * SR)
            x[s:s + len(t)] += drop * g
    return loopify(x)

def clay_rumble(sec=1.6):
    n = int(sec * SR); t = np.arange(n) / SR
    env = np.minimum(1, t / (sec * 0.8)) * np.minimum(1, (sec - t) / 0.15)     # нарастает
    f = 45 + 50 * t / sec
    tone = np.sin(2 * np.pi * np.cumsum(f) / SR) + 0.5 * np.sin(2 * np.pi * np.cumsum(f * 2.01) / SR)
    grit = lowpass(rng.standard_normal(n), 0.9) * 0.6
    return (tone + grit) * env

def rock_land(sec=0.7):
    n = int(sec * SR); t = np.arange(n) / SR
    thud = np.sin(2 * np.pi * (70 + 60 * np.exp(-t * 18)) * t) * np.exp(-t * 9)
    crack = lowpass(rng.standard_normal(n), 0.55) * np.exp(-t * 26) * 0.8
    gravel = lowpass(rng.standard_normal(n), 0.7) * np.exp(-t * 6) * 0.25
    return thud + crack + gravel

def stone_slide(sec=1.3):
    n = int(sec * SR); t = np.arange(n) / SR
    env = np.minimum(1, t / 0.1) * np.minimum(1, (sec - t) / 0.25)
    grind = lowpass(rng.standard_normal(n), 0.8) * (0.7 + 0.3 * np.sin(2 * np.pi * 11 * t))
    low = np.sin(2 * np.pi * 55 * t) * 0.4
    return (grind + low) * env

YY = '''{{
  "$GMSound":"v2",
  "%Name":"{n}",
  "audioGroupId":{{
    "name":"audiogroup_default",
    "path":"audiogroups/audiogroup_default",
  }},
  "bitDepth":1,
  "channelFormat":0,
  "compression":0,
  "compressionQuality":1,
  "conversionMode":0,
  "duration":{d},
  "exportDir":"",
  "name":"{n}",
  "parent":{{
    "name":"Sounds",
    "path":"folders/Sounds.yy",
  }},
  "preload":false,
  "resourceType":"GMSound",
  "resourceVersion":"2.0",
  "sampleRate":44100,
  "soundFile":"{n}.wav",
  "volume":1.0,
}}'''

sounds = [("snd_cave_ambience", cave_ambience(), 0.55), ("snd_clay_rumble", clay_rumble(), 0.8),
          ("snd_rock_land", rock_land(), 0.8), ("snd_stone_slide", stone_slide(), 0.7)]
yyp_path = os.path.join(OUT, "..", "max_farm_demo.yyp"); yyp = open(yyp_path).read()
for name, x, peak in sounds:
    save(name, x, peak)
    open(os.path.join(OUT, name, name + ".yy"), "w").write(YY.format(n=name, d=round(len(x) / SR, 2)))
    if f'"{name}"' not in yyp:
        a = '    {"id":{"name":"snd_rain","path":"sounds/snd_rain/snd_rain.yy",},},'
        assert a in yyp
        yyp = yyp.replace(a, a + f'\n    {{"id":{{"name":"{name}","path":"sounds/{name}/{name}.yy",}},}},', 1)
open(yyp_path, "w").write(yyp)
