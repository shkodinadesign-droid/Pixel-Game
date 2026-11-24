"""Процедурные фоновые звуки (зацикленные): дождь, ночные сверчки, тихий шум леса.
Запуск: python3 tools/audio/ambience_gen.py  -> пишет wav в max_farm_demo/sounds/<name>/<name>.wav
"""
import numpy as np, wave, os

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "max_farm_demo", "sounds")
rng = np.random.default_rng(7)

def lowpass(x, a):            # однополюсный НЧ-фильтр, a в (0,1): больше = мягче
    y = np.empty_like(x); acc = 0.0
    for i, v in enumerate(x):
        acc += (1 - a) * (v - acc); y[i] = acc
    return y

def loopify(x, fade_s=1.0):   # бесшовная петля: хвост плавно перетекает в начало
    n = int(fade_s * SR)
    head, tail = x[:n], x[-n:]
    t = np.linspace(0, 1, n)
    mixed = tail * np.cos(t * np.pi / 2) + head * np.sin(t * np.pi / 2)
    return np.concatenate([mixed, x[n:-n]])

def save(name, x, peak):
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    d = os.path.join(OUT, name); os.makedirs(d, exist_ok=True)
    with wave.open(os.path.join(d, name + ".wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(name, round(len(x) / SR, 2), "s")

def rain(sec=14):
    n = (sec + 1) * SR
    white = rng.standard_normal(n)
    hiss = white - lowpass(white, 0.75)                 # шелест (высокие)
    body = lowpass(white, 0.93) * 0.9                   # мягкий «шум» дождя
    swell = 1 + 0.12 * np.sin(np.linspace(0, 2 * np.pi * 3, n) + rng.random())
    x = (hiss * 0.5 + body) * swell
    for _ in range(sec * 60):                           # отдельные капли
        p = rng.integers(0, n - 800); L = rng.integers(150, 600)
        env = np.exp(-np.linspace(0, 6, L))
        x[p:p + L] += rng.standard_normal(L) * env * rng.uniform(0.3, 1.2)
    return loopify(lowpass(x, 0.35))

def crickets(sec=12):
    n = (sec + 1) * SR
    x = np.zeros(n); t = np.arange(n) / SR
    for f0, rate, gain, ph in [(4300, 0.9, 1.0, 0.0), (4700, 1.3, 0.6, 0.4), (3900, 0.7, 0.45, 0.8)]:
        car = np.sin(2 * np.pi * f0 * t)
        pos = ph
        while pos < sec + 0.5:                           # трель: 3-4 импульса, потом пауза
            for k in range(rng.integers(3, 5)):
                s = int((pos + k * 0.045) * SR); L = int(0.03 * SR)
                if s + L >= n: break
                x[s:s + L] += car[s:s + L] * np.hanning(L) * gain
            pos += rate * rng.uniform(0.8, 1.25)
    x += rng.standard_normal(n) * 0.01
    return loopify(x)

def forest(sec=16):
    n = (sec + 1) * SR
    white = rng.standard_normal(n)
    wind = lowpass(lowpass(white, 0.985), 0.985)         # низкий ветер в кронах
    leaves = white - lowpass(white, 0.6)
    gust = 0.6 + 0.4 * np.sin(np.linspace(0, 2 * np.pi * 2, n)) ** 2
    lv = lowpass(np.abs(rng.standard_normal(n)), 0.9995) # редкий шорох листвы
    return loopify(wind * 8 * gust + leaves * 0.05 * lv * gust)

save("snd_rain", rain(), 0.6)
save("snd_night_crickets", crickets(), 0.5)
save("snd_forest_ambience", forest(), 0.6)
