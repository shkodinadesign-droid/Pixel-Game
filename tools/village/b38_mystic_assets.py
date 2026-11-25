# Партия 38 (ассеты): тайный лес и новая графика пещеры. Процедурно, временно — автор может заменить PNG.
#  - spr_mystic_tiles + tls_mystic: тайлсет леса (tls_forest), перекрашенный в тёмный, с фиолетовым оттенком;
#    тропинка темнее;
#  - пещера (вид сбоку): spr_cave_wall (камень с трещинами), spr_cave_earth_top / spr_cave_earth (коричневая земля),
#    spr_cave_ledge (каменная плита), spr_cave_backwall (дальняя стена, темнее);
#  - snd_owl — уханье совы.
# Запуск: python3 tools/village/b38_mystic_assets.py [папка_превью]
import os, sys, glob, random, colorsys, wave
import numpy as np
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gm_anim
P = os.path.join(HERE, '..', '..', 'max_farm_demo')
PREV = sys.argv[1] if len(sys.argv) > 1 else None
random.seed(38)

def reg(name, im, folder=('Tile Sets', 'folders/Tile Sets.yy')):
    px = im.load(); W, H = im.size
    gm_anim.sprite(P, name, [[[px[x, y] for x in range(W)] for y in range(H)]], (0, 0), (0, 0, W - 1, H - 1), 0, folder=folder)
    if PREV: im.resize((W * 4, H * 4), Image.NEAREST).save(os.path.join(PREV, name + '.png'))

# ---------- тайный лес: перекраска тайлсета ----------
src = Image.open(glob.glob(f'{P}/sprites/spr_forest_tiles/*.png')[0]).convert('RGBA')
out = src.copy(); px = out.load()
for y in range(out.height):
    for x in range(out.width):
        r, g, b, a = px[x, y]
        if a == 0: continue
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        hd = h * 360
        if 70 <= hd <= 170:            # трава -> тёмная сине-зелёная с фиолетовым
            nh, ns, nv = 0.47 + (hd - 120) / 900, s * 0.55, v * 0.52
        elif 15 <= hd < 50 and v > 0.7: # песчаная тропинка -> тёмная, буро-сиреневая
            nh, ns, nv = 0.9, s * 0.3, v * 0.3
        else:                           # земля под деревьями -> глубокая фиолетово-бурая
            nh, ns, nv = 0.86, max(0.25, s * 0.5), v * 0.6
        nr, ng, nb = colorsys.hsv_to_rgb(nh % 1, min(1, ns), min(1, nv))
        px[x, y] = (int(nr * 255), int(ng * 255), int(nb * 255), a)
reg('spr_mystic_tiles', out)
ts = open(f'{P}/tilesets/tls_forest/tls_forest.yy').read()
ts = ts.replace('tls_forest', 'tls_mystic').replace('"name":"spr_forest_tiles"', '"name":"spr_mystic_tiles"').replace('sprites/spr_forest_tiles/spr_forest_tiles.yy', 'sprites/spr_mystic_tiles/spr_mystic_tiles.yy')
os.makedirs(f'{P}/tilesets/tls_mystic', exist_ok=True)
open(f'{P}/tilesets/tls_mystic/tls_mystic.yy', 'w').write(ts)
yp = f'{P}/max_farm_demo.yyp'; s = open(yp).read()
if '"tls_mystic"' not in s:
    a = '    {"id":{"name":"tls_forest","path":"tilesets/tls_forest/tls_forest.yy",},},'
    assert a in s
    s = s.replace(a, a + '\n    {"id":{"name":"tls_mystic","path":"tilesets/tls_mystic/tls_mystic.yy",},},', 1)
    open(yp, 'w').write(s)

# ---------- пещера ----------
def stone_wall(size=64, base=(78, 76, 86), seed=1):
    random.seed(seed)
    im = Image.new('RGBA', (size, size), (50, 48, 56, 255)); d = ImageDraw.Draw(im)
    y = 0
    row = 0
    while y < size:
        h = random.choice([14, 16, 18])
        x = -random.randint(0, 14) if row % 2 else 0
        while x < size:
            w = random.randint(16, 28)
            _o = random.randint(-8, 14); _t = random.randint(-3, 3)
            c = (min(255, base[0] + _o + _t), min(255, base[1] + _o), min(255, base[2] + _o - _t), 255)   # серый, лёгкий оттенок
            d.rectangle((x + 1, y + 1, x + w - 2, min(size, y + h) - 2), fill=c)
            d.line((x + 2, y + 1, x + w - 3, y + 1), fill=tuple(min(255, c[i] + 22) for i in range(3)) + (255,))   # блик сверху
            d.line((x + 1, min(size, y + h) - 2, x + w - 2, min(size, y + h) - 2), fill=tuple(max(0, c[i] - 16) for i in range(3)) + (255,))
            for _ in range(2): d.point((x + random.randint(3, w - 4), y + random.randint(3, h - 4)), fill=tuple(max(0, c[i] - 10) for i in range(3)) + (255,))
            x += w
        y += h; row += 1
    for _ in range(3):                                  # трещины
        cx, cy = random.randint(4, size - 4), random.randint(4, size - 12)
        for k in range(random.randint(5, 9)):
            nx, ny = cx + random.choice([-1, 0, 1]), cy + 1
            d.point((cx, cy), fill=(34, 32, 38, 255)); cx, cy = nx % size, ny % size
    for _ in range(4):                                  # мох
        mx, my = random.randint(0, size - 4), random.randint(0, size - 3)
        d.rectangle((mx, my, mx + random.randint(1, 3), my + 1), fill=(70, 98, 70, 255))
    # бесшовность: края копируем (простая — повторяем сетку как есть)
    return im

reg('spr_cave_wall', stone_wall(64, (84, 82, 92), 5), folder=('characters', 'folders/Sprites/characters.yy'))
reg('spr_cave_backwall', stone_wall(64, (66, 64, 74), 9), folder=('characters', 'folders/Sprites/characters.yy'))

def earth(top):
    random.seed(11 if top else 12)
    im = Image.new('RGBA', (32, 32), (92, 64, 44, 255)); d = ImageDraw.Draw(im)
    for _ in range(40): d.point((random.randrange(32), random.randrange(32)), fill=random.choice([(80, 55, 38, 255), (104, 74, 52, 255)]))
    for _ in range(4):
        x, y = random.randrange(2, 29), random.randrange(6 if top else 2, 29)
        d.rectangle((x, y, x + 2, y + 1), fill=(124, 116, 112, 255)); d.line((x, y + 2, x + 2, y + 2), fill=(70, 50, 36, 255))
    if top:
        d.rectangle((0, 0, 31, 3), fill=(126, 92, 62, 255))       # светлая кромка тропы
        d.line((0, 4, 31, 4), fill=(74, 52, 36, 255))
        for x in range(0, 32, 3):
            if random.random() < 0.35: d.rectangle((x, 0, x + 1, 1), fill=(86, 110, 72, 255))   # травинки/мох
    else:
        d.line((random.randrange(4, 28), 0, random.randrange(4, 28), 10), fill=(70, 50, 34, 255))   # корешок
    return im
reg('spr_cave_earth_top', earth(True), folder=('characters', 'folders/Sprites/characters.yy'))
reg('spr_cave_earth', earth(False), folder=('characters', 'folders/Sprites/characters.yy'))

led = Image.new('RGBA', (32, 14), (112, 108, 120, 255)); d = ImageDraw.Draw(led)
d.rectangle((0, 0, 31, 2), fill=(156, 152, 164, 255)); d.rectangle((0, 11, 31, 13), fill=(70, 66, 78, 255))
d.line((10, 3, 12, 10), fill=(80, 76, 88, 255)); d.line((25, 4, 24, 9), fill=(80, 76, 88, 255))
d.rectangle((3, 0, 6, 0), fill=(86, 112, 76, 255)); d.rectangle((19, 0, 21, 0), fill=(86, 112, 76, 255))
reg('spr_cave_ledge', led, folder=('characters', 'folders/Sprites/characters.yy'))

# ---------- сова ----------
SR = 44100
def owl():
    sec = 2.4; n = int(sec * SR); x = np.zeros(n); t = np.arange(n) / SR
    for start, dur, f in [(0.05, 0.45, 390), (0.75, 0.22, 410), (1.05, 0.55, 380)]:
        s0, L = int(start * SR), int(dur * SR); tt = np.arange(L) / SR
        env = np.sin(np.pi * tt / dur) ** 1.5
        tone = np.sin(2 * np.pi * (f + 6 * np.sin(2 * np.pi * 5 * tt)) * tt) + 0.25 * np.sin(2 * np.pi * 2 * f * tt)
        x[s0:s0 + L] += tone * env
    x += np.random.default_rng(3).standard_normal(n) * 0.01
    for k, g in [(int(0.18 * SR), 0.25)]:              # лесное эхо
        x[k:] += x[:-k] * g
    return x / np.max(np.abs(x)) * 0.6
d0 = f'{P}/sounds/snd_owl'; os.makedirs(d0, exist_ok=True)
w = owl()
with wave.open(f'{d0}/snd_owl.wav', 'wb') as f:
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(SR); f.writeframes((w * 32767).astype(np.int16).tobytes())
open(f'{d0}/snd_owl.yy', 'w').write(open(f'{P}/sounds/snd_rock_land/snd_rock_land.yy').read().replace('snd_rock_land', 'snd_owl').replace('"duration":0.7', '"duration":2.4'))
s = open(yp).read()
if '"snd_owl"' not in s:
    a = '    {"id":{"name":"snd_rain","path":"sounds/snd_rain/snd_rain.yy",},},'
    s = s.replace(a, a + '\n    {"id":{"name":"snd_owl","path":"sounds/snd_owl/snd_owl.yy",},},', 1); open(yp, 'w').write(s)
print('ok')
